# 🏠 Smart Home On-Device AI Agent (端侧大模型智能管家)

![Demo](docs/20260330004242_rec_.gif)

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg?logo=dart)
![llama.cpp](https://img.shields.io/badge/llama.cpp-Edge_AI-orange.svg)
![Isar DB](https://img.shields.io/badge/Isar-3.1-green.svg)
![License](https://img.shields.io/badge/License-MIT-success.svg)

## 📚 项目文档 (Documentation)

* [智能家居端侧 AI Agent 架构复盘与落地能力指南](docs/honest_architecture_reflection.md)
* [端侧模型深度定制与全链路微调方案 (架构师视角)](model_forge/on_device_model_customization_pipeline.md)
* [Mac M4 端侧模型微调与量化复现 SOP](model_forge/mac_m4_reproduction_sop.md)
* [数据评估体系与合成规则逆向推导](model_forge/data_evaluation_and_synthesis_rules.md)
* [智能家居端侧模型：数据评估与验收体系指南](model_forge/data_evaluation_and_acceptance_framework.md)
* [智能家居端侧模型业务扩展与迭代 SOP](model_forge/business_expansion_model_iteration_sop.md)
* [Model Forge 目录说明](model_forge/README.md)

A next-generation Smart Home application demonstrating the **production-ready implementation of On-Device AI + Agent architecture**. Powered by `llama.cpp` through Dart FFI and a lightweight local RAG (Retrieval-Augmented Generation) system.

这是一个致力于探索和展示 **“端侧大模型 + Agent” 真实落地能力** 的智能家居开源项目。它彻底抛弃了云端 API 的依赖，在移动设备本地完成了从自然语言理解、意图规划到 IoT 硬件控制的完整 Agent 闭环。

---

## 🌟 核心落地能力 (Why On-Device Agent?)

大模型直接控制物理世界的硬件，最大的阻碍是**延迟**、**隐私**和**幻觉**。本项目通过以下三大架构创新，完美解决了这些落地痛点：

### 1. 🎯 零幻觉的硬件控制 (Zero-Hallucination Determinism)
*   **痛点**：云端大模型容易产生幻觉，输出不存在的设备 ID 或错误的 JSON 格式，导致硬件控制崩溃。
*   **落地实现**：首创性地引入了 **动态 GBNF (GGML BNF) 语法树**。在每次推理前，Agent 会获取当前真实的家庭设备列表，动态生成底层 C++ 采样约束（如 `device_id ::= "\"light_1\"" | "\"ac_1\""`）。从概率分布的最底层掐断了 AI 输出非法字符的可能，实现了 **100% 的 JSON 解析成功率和实体准确率**。

### 2. 📚 纯本地的隐私级 RAG (Edge RAG for Privacy)
*   **痛点**：用户询问“今天谁开了大门”、“卧室监控有没有异常”等涉及极高隐私的数据，绝不能上传云端。
*   **落地实现**：利用 **Isar 本地对象数据库** 替代沉重的向量库。Agent 内部实现了轻量级的意图路由，拦截查询类指令后，在几毫秒内检索本地 `BehaviorLog`，并作为 Context 动态注入 Prompt。整个过程**完全断网可用**，实现了真正的“隐私级数据增强”。

### 3. ⚡ 异步隔离与毫秒级响应 (Isolate-Driven Edge Inference)
*   **痛点**：在手机上跑 2B 级别的模型，极易导致主线程阻塞，造成 App 卡顿甚至 ANR。
*   **落地实现**：基于 Dart 的 FFI 深度绑定 `llama.cpp` 源码，并将模型加载（Mmap）、Prompt 预处理和 Token 采样全部压入 **Dart Isolate (独立内存堆的后台线程)** 中。确保在进行繁重的张量计算时，Flutter UI 依然能保持丝滑的 60fps 帧率。

---

## ✨ 交互体验亮点 (UX Highlights)

*   **🧠 透明的“思维链”展示**：告别 AI 的黑盒。UI 实时渲染 Agent 的规划过程（意图识别 -> 本地 RAG 检索 -> 动态语法树生成 -> 指令执行）。
*   **🔄 操作前后状态对比**：精准捕捉 AI 控制前后的 IoT 设备状态（例如：空调 `[关闭] ➔ [开启 (22°C)]`），在聊天气泡中提供极具安全感的状态反馈。
*   **📊 极客性能看板**：在 Debug 模式下，每条指令下方会自动挂载性能追踪面板，展示 **端侧推理耗时** 和 **Tokens/s (生成吞吐量)**，为架构调优提供直观依据。



## 🏗 架构全景 (Architecture Overview)

项目被严格解耦为 **UI 表现层** 和 **端侧 Agent 内核包**，便于在任何 Flutter 项目中复用：

```text
lib/ (Flutter UI 层)
 ├── main.dart (App Entry, Chat UI & Metrics Panel)
 └── services/ (IoT 设备状态管理模拟)

packages/on_device_agent/ (端侧 Agent 内核)
 ├── lib/src/
 │    ├── engine/        # 基于 FFI 的 LlamaCppEngine & Isolate 调度
 │    ├── context/       # 环境感知、RAG 日志组装 & 动态 GBNF 生成器
 │    └── executor/      # 动作执行器 (含安全护栏 Guardrails & 行为落库)
 └── ios/Classes/llama_cpp_src/ # llama.cpp 底层 C++ 源码 (子模块)
```

## 🚀 快速开始 (Getting Started)

### Prerequisites
*   Flutter SDK `3.x`
*   Dart SDK `3.x`
*   (For iOS/macOS) Xcode and CocoaPods
*   (For Android) Android Studio & NDK

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/smart_home_app_on_device_ai.git
   cd smart_home_app_on_device_ai
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Isar database schemas:**
   ```bash
   cd packages/on_device_agent
   flutter pub run build_runner build
   cd ../..
   ```

4. **Run the App:**
   ```bash
   # Run in debug mode (Includes Performance Metrics UI)
   flutter run
   ```
   > **Note:** By default, running on Web or Simulator will use the `LlamaCppEngineMock` (fallback engine) since compiling C++ LLM inference requires real device hardware acceleration (Metal/Vulkan).

## 🛠 Advanced: Running Real LLMs on Device

To use real on-device inference instead of the mock engine:
1. Download a highly quantized `.gguf` model (e.g., `gemma-2b-it-q4_k_m.gguf`).
2. Place it in the `assets/models/` directory.
3. Update the initialization path in `main.dart`:
   ```dart
   await _agent.initialize(modelPath: "assets/models/your_model.gguf");
   ```
4. Ensure hardware acceleration is enabled in native builds (e.g., `GGML_METAL=1` for iOS).

---

## 🧩 Monorepo 结构与关键入口 (Project Layout & Key Entry Points)

- UI 入口与演示
  - [main.dart](file:///Users/aiden/Documents/macinit/smarthome%20APP/smart_home_app/lib/main.dart)
  - 设备模型：[device.dart](file:///Users/aiden/Documents/macinit/smarthome%20APP/smart_home_app/lib/models/device.dart)
  - 设备服务：[device_service.dart](file:///Users/aiden/Documents/macinit/smarthome%20APP/smart_home_app/lib/services/device_service.dart)
- 端侧 Agent 内核 (可复用包)
  - Llama.cpp 引擎入口：[llama_engine.dart](file:///Users/aiden/Documents/macinit/smarthome%20APP/smart_home_app/packages/on_device_agent/lib/src/engine/llama_cpp/llama_engine.dart)
  - FFI 绑定声明：[llama_bindings.dart](file:///Users/aiden/Documents/macinit/smarthome%20APP/smart_home_app/packages/on_device_agent/lib/src/engine/llama_cpp/llama_bindings.dart)
  - 意图结构体 (JSON Schema 对应)：[agent_intent.dart](file:///Users/aiden/Documents/macinit/smarthome%20APP/smart_home_app/packages/on_device_agent/lib/src/models/agent_intent.dart)
- Model Forge (造模型车间)
  - 数据合成脚本：[data_synthesis.py](file:///Users/aiden/Documents/macinit/smarthome%20APP/smart_home_app/model_forge/notebooks/data_synthesis.py)
  - 训练脚本 (MLX LoRA)：[train.py](file:///Users/aiden/Documents/macinit/smarthome%20APP/smart_home_app/model_forge/scripts/train.py)
  - 转换与量化流水线：[quantize.sh](file:///Users/aiden/Documents/macinit/smarthome%20APP/smart_home_app/model_forge/scripts/quantize.sh)
  - 目录说明与 SOP 索引：[Model Forge README](file:///Users/aiden/Documents/macinit/smarthome%20APP/smart_home_app/model_forge/README.md)

---

## 🧪 数据与模型：评估、复现与迭代 (Data & Model Ops)

- 评估指标与验收标准
  - 指标体系：FSR ≥ 99.5%，IEM ≥ 95%，OOD-R ≥ 98%，DCR ≥ 99%
  - 详见：[数据评估与验收体系指南](file:///Users/aiden/Documents/macinit/smarthome%20APP/smart_home_app/model_forge/data_evaluation_and_acceptance_framework.md)
- 数据合成黄金规则
  - 仅输出纯 JSON、动态设备快照、模糊意图覆盖、负样本边界测试、长尾语言分布
  - 详见：[数据评估体系与合成规则逆向推导](file:///Users/aiden/Documents/macinit/smarthome%20APP/smart_home_app/model_forge/data_evaluation_and_synthesis_rules.md)
- 端到端复现 (Apple M4)
  - 环境与命令全流程：从 venv、数据合成、QLoRA、GGUF 转换到 Q4_K_M 量化
  - 详见：[Mac M4 复现 SOP](file:///Users/aiden/Documents/macinit/smarthome%20APP/smart_home_app/model_forge/mac_m4_reproduction_sop.md)
- 端侧模型定制方案
  - 架构师视角的全链路方案与团队收益
  - 详见：[深度定制与全链路微调方案](file:///Users/aiden/Documents/macinit/smarthome%20APP/smart_home_app/model_forge/on_device_model_customization_pipeline.md)

---

## 📦 提交规范与忽略策略 (Commit Policy)

- 仅提交必要源码与配置，忽略大型模型文件、临时产物与平台构建输出
- 当前忽略规则参考：[.gitignore](file:///Users/aiden/Documents/macinit/smarthome%20APP/smart_home_app/.gitignore)
- Model Forge 关键忽略事项
  - 不提交 `exports/**/*.gguf`、`data/**/*.jsonl`、`venv/` 与 `scripts/llama.cpp/`
  - 大文件统一由外链或发布包下发

## 📝 Debugging & Performance Tracking

The application includes a built-in profiler available only in `kDebugMode`. When you send a command to the AI, it will output a dedicated metrics panel showing:
*   **Inference Time (ms)**: Pure C++ execution time.
*   **Total Latency (ms)**: From tapping "Send" to UI rendering.
*   **Throughput (Tokens/s)**: The generation speed of the LLM on your hardware.

## 🤝 Contributing

We welcome contributions! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
