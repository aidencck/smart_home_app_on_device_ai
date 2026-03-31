# 端云协同大模型 AI Agent：全链路数据与部署架构解决方案

> **Document Status**: Draft | **Role**: System Architect | **Date**: 2026-03-31

本文档旨在从架构师视角，全局梳理并规范化智能家居项目中端侧大模型（On-Device AI Agent）的**全生命周期解决方案**。涵盖从端侧行为感知、云端数据飞轮收集、模型训练与微调、端云协同推理架构到性能优化与工程部署的完整链路。

---

## 1. 架构愿景与全视角概览 (Architectural Vision)

本项目抛弃了传统的“被动响应式纯云端调用”，转而采用**“端侧主导、云端兜底、数据闭环”**的架构思想。
这套架构不是静态的软件系统，而是一个具备**“自我进化能力 (Data Flywheel)”**的有机体。我们通过以下五个环节实现这一目标：

1. **数据收集 (Data Collection)**：端侧无感感知与云端合规清洗。
2. **模型微调 (Model Fine-Tuning)**：Model Forge 车间的自动化 QLoRA 训练。
3. **协同推理 (Collaborative Inference)**：端侧 0 延迟控制与云端长尾兜底。
4. **工程部署 (Engineering Deployment)**：GGUF 量化与跨平台移动端集成。
5. **性能优化 (Performance Ops)**：Isolate 异步调度与内存管理。

---

## 2. 数据收集与清洗闭环 (Data Flywheel)

数据是 AI Agent 持续进化的燃料。由于智能家居场景对隐私极度敏感，我们设计了严格的“合规清洗与异步回收”机制。

### 2.1 端侧日志与反馈 (Edge Telemetry)
*   **Opt-in 强授权机制**：端侧（Flutter UI）在发生“控制失败 (Bad Case)”或“用户显式纠错”时，仅在用户开启“体验改善计划”授权后，才会触发日志上传。
*   **前置脱敏 (NER Anonymization)**：在数据离开设备前，本地引擎会剔除人名、具体位置等 PII（个人身份信息），只保留结构化的设备状态与用户意图。

### 2.2 云端异步清洗 (LLM-as-a-Judge)
*   **Celery + RabbitMQ 异步队列**：云端 FastAPI 接收到遥测日志后，迅速入队，防止主业务线程阻塞。
*   **Judge 自动化打分**：见 [`backend/app/worker/tasks.py`](../backend/app/worker/tasks.py)。后台 Celery Worker 调用云端大模型（如 vLLM/OpenAI），作为“裁判 (Judge)”对脱敏日志进行二次隐私过滤、意图重构和质量打分。
*   **高质量负样本萃取**：打分合格的日志将被格式化为 `JSONL` 格式，自动存入云端对象存储，作为下一轮 SFT（监督微调）的优质负样本数据池。

---

## 3. 模型训练与微调 (Model Forge)

位于 [`model_forge/`](../model_forge/) 的“模型造车间”是我们提炼行业壁垒的核心基建。

### 3.1 训练环境与技术栈
*   **硬件底座**：全面适配 Apple Silicon (Mac M4) 的统一内存架构，使用 MLX 框架大幅降低训练成本。
*   **数据工程**：通过 [`data_synthesis.py`](../model_forge/notebooks/data_synthesis.py) 生成涵盖动态设备快照、模糊意图覆盖的黄金训练集。

### 3.2 自动化微调流水线 (QLoRA Pipeline)
*   **基础模型**：选用轻量级开源模型（如 Qwen-2.5-1.5B 或 Gemma-2B）作为底座。
*   **微调策略**：采用 **QLoRA (Quantized Low-Rank Adaptation)**，仅更新极少量的权重参数，大幅降低显存占用。
*   **执行脚本**：见 [`train.py`](../model_forge/scripts/train.py)。支持一键执行，自动加载云端汇聚的 JSONL 数据池进行持续迭代。

---

## 4. 端云协同推理架构 (Inference Architecture)

这是支撑用户体验最核心的环节，实现了“快”与“智”的平衡。

### 4.1 端侧推理：零幻觉与极致响应
*   **Llama.cpp 引擎绑定**：见 [`llama_bindings.dart`](../packages/on_device_agent/lib/src/engine/llama_cpp/llama_bindings.dart)。通过 Dart FFI 直接调用底层 C++ 推理库。
*   **动态 GBNF 语法树**：在推理前，Agent 动态提取当前局域网内的真实设备 ID（如 `light_1`），将其编译为 C++ 采样约束。**从底层掐断了 AI 输出虚假设备的可能，实现 100% 的 JSON 格式命中率**。
*   **本地 RAG**：查询“今天谁开过门”时，直接在本地 Isar 数据库进行毫秒级检索，断网可用且物理隔绝隐私。

### 4.2 云端推理：语义缓存与防竞态
*   **防投毒语义缓存**：云端 FastAPI 拦截请求，基于 `Hashlib SHA-256` 计算意图哈希。高频复合指令直接命中缓存返回 0 延迟 JSON，阻断了 Prompt 注入攻击。
*   **分布式锁与状态探针**：利用 `Command ID + Redis SETNX` 防止重放攻击；利用 `Vector Clock + Lua 脚本` 确保设备影子更新时的原子性，彻底解决 TOCTOU（检查与执行间隙）漏洞。

---

## 5. 工程部署与模型分发 (Deployment & OTA)

训练好的模型如何安全、高效地送到用户设备上？

### 5.1 模型量化与打包
*   **极度量化**：微调后的模型经过 [`quantize.sh`](../model_forge/scripts/quantize.sh) 处理，转换为 `GGUF` 格式。通常采用 `Q4_K_M`（4-bit 量化）或更激进的 `IQ2_XXS`（2-bit 量化），将 2B 模型的内存占用压缩至 1.5GB 以下。
*   **端侧 OTA 动态下发**：见 [`model_downloader.dart`](../packages/on_device_agent/lib/src/engine/model_downloader.dart)。App 启动时会校验本地模型版本，通过差异化下载 (Delta Update) 策略静默拉取最新的微调权重。

### 5.2 容器化云端基建
*   **Docker 编排**：云端微服务（FastAPI, PostgreSQL, Redis, Celery, RabbitMQ）通过 `docker-compose.yml` 统一部署，确保开发、测试与生产环境的一致性。

---

## 6. 性能优化与核心指标 (Performance & Metrics)

端侧 AI 的成败取决于能否在算力受限的设备上流畅运行。

### 6.1 移动端异步调度优化
*   **Dart Isolate 隔离**：由于 2B 模型的张量计算极度消耗 CPU/GPU，直接在主线程运行会导致 Flutter UI 严重掉帧甚至 ANR。
*   **实现策略**：模型加载（Mmap）、Prompt Tokenize 和推理解码循环全部压入独立的 Dart Isolate。通过异步端口 (SendPort/ReceivePort) 与主线程通信，确保在输出 Token 流时，UI 依然保持丝滑的 60fps。

### 6.2 关键验收指标体系 (KPIs)
根据 [`data_evaluation_and_acceptance_framework.md`](../model_forge/data_evaluation_and_acceptance_framework.md)，每次微调与部署必须满足以下硬性指标：
1. **FSR (Format Success Rate) ≥ 99.5%**：得益于 GBNF，端侧输出 JSON 格式的成功率必须近乎完美。
2. **推理内存 (RAM Peak) ≤ 1.5GB**：防止触发 iOS/Android 的 OOM (Out Of Memory) 杀后台机制。
3. **生成吞吐量 (Tokens/s)**：在 Apple M 系列/高通骁龙 8Gen2 级别芯片上，至少达到 15-20 Tokens/s，保证“打字机”效果的体感流畅度。

---

## 7. 总结

本解决方案打通了从“硬件感知 → 本地推理 → 云端脱敏清洗 → 模型自动化微调 → GGUF 量化分发 → 端侧渲染执行”的完整技术脉络。这不仅仅是一个工程实践，更是构建智能家居行业**数据飞轮壁垒**的核心蓝图。