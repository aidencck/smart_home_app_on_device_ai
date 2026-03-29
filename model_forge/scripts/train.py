import subprocess
import sys
import os
import platform

def ensure_env():
    try:
        __import__("mlx_lm")
        return sys.executable
    except Exception:
        root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
        venv_py = os.path.join(root, "venv", "bin", "python")
        if not os.path.exists(venv_py):
            subprocess.check_call(["python3", "-m", "venv", os.path.join(root, "venv")])
        subprocess.check_call([venv_py, "-m", "pip", "install", "--upgrade", "pip"])
        subprocess.check_call([venv_py, "-m", "pip", "install", "-r", os.path.join(root, "requirements.txt")])
        return venv_py

def analyze_env(base_model, data_dir, adapter_path):
    print("🔍 训练环境检查开始")
    os_ok = sys.platform == "darwin"
    arch_ok = platform.machine() == "arm64"
    py_ok = sys.version_info.major >= 3 and sys.version_info.minor >= 10
    try:
        __import__("mlx")
        __import__("mlx_lm")
        dep_ok = True
    except Exception:
        dep_ok = False
    train_path = os.path.join(data_dir, "train.jsonl")
    valid_path = os.path.join(data_dir, "valid.jsonl")
    data_ok = os.path.isfile(train_path) and os.path.isfile(valid_path)
    try:
        os.makedirs(adapter_path, exist_ok=True)
        with open(os.path.join(adapter_path, ".perm_check"), "w") as f:
            f.write("ok")
        os.remove(os.path.join(adapter_path, ".perm_check"))
        perm_ok = True
    except Exception:
        perm_ok = False
    mem_ok = True
    mem_available_mb = -1
    hf_endpoint = os.environ.get("HF_ENDPOINT", "https://hf-mirror.com")
    net_ok = False
    try:
        import urllib.request
        with urllib.request.urlopen(hf_endpoint, timeout=3) as resp:
            net_ok = resp.status < 500
    except Exception:
        net_ok = False
    mem_display = f"{mem_available_mb}MB" if mem_available_mb >= 0 else "未知"
    print(f"系统: {'macOS' if os_ok else '非macOS'} | 架构: {platform.machine()} | Python: {platform.python_version()}")
    print(f"依赖: {'OK' if dep_ok else '缺失(请安装 mlx/mlx-lm)'} | 数据集: {'OK' if data_ok else '缺失'}")
    print(f"目录权限: {'OK' if perm_ok else '失败'} | 可用内存: {mem_display} | 网络: {'OK' if net_ok else '异常'}")
    ok = os_ok and arch_ok and py_ok and dep_ok and data_ok and perm_ok and mem_ok
    if not ok:
        print("❌ 环境检查未通过")
    else:
        print("✅ 环境检查通过")
    return ok

def run_mlx_lora():
    """
    Run MLX-LM LoRA fine-tuning for Qwen2.5-0.5B on Apple Silicon.
    """
    print("🚀 Starting MLX-LM QLoRA Fine-Tuning for Apple M4...")
    
    # Define paths
    base_model = "Qwen/Qwen2.5-0.5B-Instruct"
    data_dir = "../data/processed"
    adapter_path = "../exports/adapters"
    
    # Ensure export dir exists
    os.makedirs(adapter_path, exist_ok=True)
    ok = analyze_env(base_model, data_dir, adapter_path)
    proceed = "n"
    try:
        proceed = input("是否继续执行微调? (y/N): ").strip().lower()
    except EOFError:
        proceed = "n"
    if not ok and proceed != "y":
        print("已取消执行")
        return
    if proceed != "y" and ok:
        print("已取消执行")
        return
    
    # MLX-LM LoRA command
    # We use a small number of iterations (e.g., 20) for demonstration purposes.
    py = ensure_env()
    cmd = [
        py, "-m", "mlx_lm.lora",
        "--model", base_model,
        "--data", data_dir,
        "--train",
        "--batch-size", "4",
        "--num-layers", "4",
        "--iters", "20", 
        "--adapter-path", adapter_path,
        "--save-every", "10"
    ]
    
    print(f"Executing: {' '.join(cmd)}")
    
    # Set HF Mirror for network connectivity
    env = os.environ.copy()
    env["HF_ENDPOINT"] = "https://hf-mirror.com"

    try:
        # Run the training
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, env=env)
        for line in process.stdout:
            print(line, end="")
        process.wait()
        
        if process.returncode == 0:
            print(f"✅ Training completed successfully! Adapters saved to {adapter_path}")
        else:
            print(f"❌ Training failed with return code {process.returncode}")
            
    except Exception as e:
        print(f"❌ Error during training: {e}")

if __name__ == "__main__":
    run_mlx_lora()
