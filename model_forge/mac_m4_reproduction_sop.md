# 🍏 Mac M4 端侧模型微调与量化复现 SOP (标准作业程序)

本文档记录了在 Apple Silicon (M4) 架构上，基于 MLX 框架对 Qwen2.5-0.5B 进行微调并量化为端侧可用 GGUF 格式的完整操作流程。本流程可确保任何开发人员能在本地完美复现 `smarthome_qwen_0.5b_q4_k_m.gguf` 的构建过程。

---

## 🛠️ 第一步：环境准备 (Environment Setup)

在开始之前，确保您的设备是 Apple Silicon Mac，并且已经安装了 Python 3 (推荐 3.10+)。

1. **进入车间目录并创建虚拟环境：**
   ```bash
   cd model_forge
   python3 -m venv venv
   source venv/bin/activate
   ```

2. **安装核心依赖 (MLX & Transformers 等)：**
   `requirements.txt` 中已配置好所需的深度学习包。
   ```bash
   pip install --upgrade pip
   pip install -r requirements.txt
   ```
   > 💡 *关键依赖*：`mlx-lm` 是 Apple 官方提供的针对统一内存优化的轻量级大模型框架。

---

## 📊 第二步：数据合成 (Data Synthesis)

端侧模型能力的上限取决于数据质量。我们需要将领域知识（如家居设备控制、拒答机制）转化为模型能理解的格式。

1. **执行数据合成脚本：**
   ```bash
   cd notebooks
   python data_synthesis.py
   ```
2. **产出验证：**
   执行完毕后，检查 `data/processed/` 目录下是否成功生成了 `train.jsonl` 和 `valid.jsonl` 文件。数据格式必须遵循 ShareGPT 对话标准。

---

## 🚀 第三步：QLoRA 模型微调 (Fine-Tuning)

利用 Mac M4 芯片强大的统一内存架构，我们可以极速完成 QLoRA 微调。

1. **执行微调脚本：**
   ```bash
   cd ../scripts
   python train.py
   ```
2. **监控训练过程：**
   脚本会自动从 HuggingFace 拉取 `Qwen/Qwen2.5-0.5B-Instruct` 基础模型。在 M4 上，Tokens/sec 吞吐量极高。
3. **产出验证：**
   训练结束后，LoRA 适配器权重将保存在 `exports/adapters/` 目录中（包含 `adapters.safetensors`）。

---

## 🗜️ 第四步：模型融合与极限量化 (Fusion & Quantization)

这是最关键的一步：将微调后的模型转化为适合手机端侧运行的极小体积文件。

1. **一键执行自动化量化脚本：**
   ```bash
   # 在 scripts 目录下执行
   chmod +x quantize.sh
   ./quantize.sh
   ```

### 脚本内部执行流解析：
该脚本自动化了以下核心步骤：
*   **融合 (Fuse)**：使用 `mlx_lm.fuse` 将 `exports/adapters` 与基座模型融合，输出完整的 HuggingFace 格式到 `exports/fused_model/`。
*   **编译 (Build llama.cpp)**：拉取最新的 `llama.cpp` 仓库，并通过 CMake 在本地进行针对 ARM64 的极致优化编译。
*   **格式转换 (To GGUF)**：利用 `convert_hf_to_gguf.py` 将融合后的模型转换为 FP16 格式的 GGUF 文件 (`smarthome_qwen_0.5b_fp16.gguf`)，大小约 940MB。
*   **量化 (Quantize)**：调用编译好的 `llama-quantize` 工具，将 FP16 模型压制为 `Q4_K_M` 格式。

2. **最终产出验证：**
   量化完成后，您将在 `exports/` 目录下得到最终的端侧模型：
   👉 **`smarthome_qwen_0.5b_q4_k_m.gguf`** (体积约 **373 MB**)

---

## 🎯 第五步：端侧部署 (Deployment)

完成以上步骤后，即可将最终的 `.gguf` 文件移交至主 App 工程。

1. 将 `smarthome_qwen_0.5b_q4_k_m.gguf` 复制到 Flutter 项目的 `assets/models/` 目录下。
2. 确保 Flutter 端已集成 `LlamaCppEngine`，即可在真机上体验完全断网、隐私安全、极速响应的智能家居端侧 AI！
