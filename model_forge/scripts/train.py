import subprocess
import sys
import os

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
    
    # MLX-LM LoRA command
    # We use a small number of iterations (e.g., 20) for demonstration purposes.
    cmd = [
        sys.executable, "-m", "mlx_lm.lora",
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
