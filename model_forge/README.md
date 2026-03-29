# 🧠 Model Forge (端侧模型铸造厂)

> **"Software is eating the world, but AI is eating software."**
> 这里是智能家居端侧大模型（On-Device LLM）的专属训练、量化与定制车间。

## 📚 核心文档
* 📖 **[端侧模型深度定制与全链路微调方案 (架构师视角)](on_device_model_customization_pipeline.md)**
* 🛠️ **[Mac M4 端侧模型微调与量化复现 SOP (标准作业程序)](mac_m4_reproduction_sop.md)**
* 🧪 **[数据评估体系与合成规则逆向推导](data_evaluation_and_synthesis_rules.md)**
* 📊 **[智能家居端侧模型：数据评估与验收体系指南](data_evaluation_and_acceptance_framework.md)**
* 🔄 **[智能家居端侧模型业务扩展与迭代 SOP](business_expansion_model_iteration_sop.md)**

## 🎯 目录定位 (Why this directory?)

`model_forge` 是一个与主 Flutter 项目**完全解耦**的 Python 生态空间。
Flutter 端 (`packages/on_device_agent`) 负责**“用模型”**（推理与执行），而这里负责**“造模型”**（数据合成、微调、量化）。通过将它们放在同一个 Monorepo 中，我们实现了从 AI 底层到 App 应用层的全栈管理。

## 📂 目录结构 (Directory Structure)

```text
model_forge/
├── data/           # 存放微调数据集 (JSONL/ShareGPT 格式)
│   ├── raw/        # 原始收集的 Bad Cases 和控制指令
│   └── processed/  # 经过清洗和格式化，可直接用于 SFT 的数据
├── notebooks/      # Jupyter Notebooks (用于数据探索、合成脚本和快速实验)
│   └── 01_data_synthesis.ipynb  # (示例) 调用大模型 API 合成智能家居指令数据集
├── scripts/        # 核心 Python 脚本 (自动化流水线)
│   ├── train.py          # 使用 Unsloth/LLaMA-Factory 触发 QLoRA 微调
│   ├── convert_gguf.py   # 将 HF 格式合并 LoRA 并转换为 GGUF 格式
│   └── quantize.sh       # 调用 llama.cpp 工具链进行 Q4_K_M 极限压缩
└── exports/        # 最终产出的模型文件 (如 .gguf)
    └── .gitignore  # 忽略 *.gguf，防止将 GB 级模型推送到 Git
```

## 🛠 核心工作流 (The Pipeline)

作为架构师或算法工程师，您在这个目录下需要完成以下闭环：

### 1. 数据工程 (Data Engineering) -> `notebooks/` & `data/`
*   **目标**：构建专属于智能家居的 SFT (Supervised Fine-Tuning) 数据集。
*   **行动**：编写 Python 脚本，根据 `lib/models/device.dart` 中的设备协议，合成涵盖“直接指令”、“模糊意图”和“多设备联动”的对话数据，确保模型学会输出严谨的 JSON 意图 (`AgentIntent`)。

### 2. 模型微调 (QLoRA Fine-Tuning) -> `scripts/train.py`
*   **目标**：将 0.5B ~ 2B 的开源基座模型（如 Qwen2.5-0.5B）注入家居领域知识。
*   **行动**：使用轻量级微调框架（推荐 [Unsloth](https://github.com/unslothai/unsloth)），在单张消费级显卡上训练模型。重点是教会模型“控制设备”以及“拒绝危险指令”。

### 3. 量化与打包 (Quantization & Export) -> `scripts/quantize.sh`
*   **目标**：将微调后的模型压缩到 1GB 以内，使其能塞进手机内存。
*   **行动**：依赖 `llama.cpp` 工具链，将模型转换为 FP16 的 GGUF，再进一步量化为 `Q4_K_M` 或更激进的 `IQ2_XXS`。
*   **产出**：将最终的 `*.gguf` 模型放入 `exports/`，随后通过网络下发或直接拖入 Flutter 项目的 `assets/models/` 供 App 测试。

## ⚠️ 注意事项 (Rules)

1. **环境隔离**：请在此目录下使用 `conda` 或 `venv` 创建独立的 Python 虚拟环境，不要污染系统环境。
2. **大文件管控**：`exports/` 和 `data/` 目录下的大文件（如 `.gguf`, `.safetensors`, 巨大的 `.jsonl`）必须被 `.gitignore` 忽略，**绝对禁止**将其 commit 到 Git 仓库中。
3. **依赖管理**：在开发过程中，请维护好 `requirements.txt`。

---
*Let's forge the brain of our Smart Home.*