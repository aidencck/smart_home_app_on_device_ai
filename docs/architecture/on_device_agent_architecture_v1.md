# 🧠 智能家居端侧 AI Agent (On-Device Agent) 核心架构文档

> **Status**: Verified | **Version**: 1.0.0 | **Update**: 2026-04-14
> **Path**: `model_forge/inference/on_device_agent`

本项目的核心竞争力在于将大语言模型（LLM）能力深度下沉至移动端，实现了**完全离线、低延迟、高隐私**的智能家居意图理解与设备控制闭环。

---

## 一、 核心架构原则 (Architectural Principles)

1.  **隐私首位 (Privacy First)**：所有用户语音、对话文本及设备操作日志默认在本地 Isar 数据库加密存储，绝不离开局域网。
2.  **离线优先 (Offline First)**：核心控制逻辑不依赖云端，确保在家庭断网时，用户仍能通过自然语言控制设备。
3.  **UI 线程零阻塞 (Zero-Blocking UI)**：通过 Dart Isolate 和异步 FFI 机制，将重度推理负载与 UI 渲染彻底隔离。
4.  **确定性控制 (Deterministic Execution)**：摒弃不稳定的 Prompt Engineering，采用 **GBNF (Grammar-Based Network Format)** 强制模型输出符合物模型的 JSON 指令。

---

## 二、 核心模块详解 (Core Modules)

### 1. 推理引擎层 (Inference Engine)
*   **底层库**：基于 `llama.cpp`，利用 C++ 编写的高性能 GGUF 推理后端。
*   **FFI 绑定**：通过 Dart FFI (`llama_bindings.dart`) 建立 Dart 与 C++ 的低延迟通信通道。
*   **Isolate 调度**：[llama_engine.dart](file:///model_forge/inference/on_device_agent/lib/src/engine/llama_cpp/llama_engine.dart) 将模型加载（Mmap）和 Token 生成（Evaluate）置于独立的后台线程，确保主线程 60fps。

### 2. 上下文感知层 (Context Provider)
*   **状态快照**：实时监听 `DeviceManager`，在推理前自动组装包含当前所有设备状态（开关、温湿度、亮度）的系统 Prompt。
*   **动态 GBNF 生成**：根据当前在线的设备列表，动态生成 GBNF 语法树。
    *   *示例*：如果家里只有灯和空调，语法树会强制模型只能在 `{"light": ...}` 或 `{"ac": ...}` 中二选一。

### 3. 动作执行器 (Action Executor)
*   **Schema 校验**：解析模型输出的 JSON，通过预设的物模型（TSL）进行 Schema 验证。
*   **安全护栏 (Guardrails)**：拦截越界指令（如：将空调设为 100 度或在凌晨 3 点大声播放音乐）。
*   **局域网分发**：调用 `LocalControlService` 通过 Matter、MQTT 或 HTTP 直接向物理/虚拟设备下达指令。

### 4. 表现层组件 (UI Components)
*   **思维链透明化**：在聊天气泡中可选展示 Agent 的思考过程（意图识别 -> 本地 RAG -> 指令生成）。
*   **性能看板**：Debug 模式下实时展示 TTFT（首字延迟）、TPS（推理速度）和内存占用。

---

## 三、 数据流转闭环 (The Data Loop)

1.  **输入感知**：语音/文本输入 -> Whisper/Speech-to-Text。
2.  **上下文增强**：Query + 设备状态快照 + 用户历史习惯 (Isar RAG)。
3.  **受限推理**：注入动态 GBNF -> LlamaCppEngine (Isolate) 推理 -> 输出结构化 JSON。
4.  **安全执行**：ActionExecutor 校验 -> 局域网下发指令。
5.  **反馈记录**：执行结果 + 用户纠错 -> 存入 `BehaviorLog` -> 作为 **Data Flywheel** 的负样本源。

---

## 四、 性能约束与关键指标 (SLA & Constraints)

| 指标维度 | 目标值 (2B 模型) | 技术手段 |
| :--- | :--- | :--- |
| **首字延迟 (TTFT)** | ≤ 300ms | 预加载模型 + GPU (Metal/Vulkan) 卸载。 |
| **推理速度 (TPS)** | ≥ 15 tokens/s | 4-bit 量化 (Q4_K_M) + 矩阵运算优化。 |
| **内存峰值 (RAM)** | ≤ 1.5GB | 基于 Mmap 的按需加载 + 内存池管理。 |
| **离线可用性** | 100% | 核心逻辑与 API 全部置于端侧 package。 |

---

## 五、 未来演进方向 (Evolution)

*   **模型按需分发 (Model OTA)**：根据设备算力动态下载 0.5B (低端机) 或 3B (高端机) 模型。
*   **多模态增强**：支持通过摄像头画面（本地视觉模型）理解环境（如：看到用户在看书，自动调亮台灯）。
*   **跨设备联邦学习**：在不泄露原始数据的前提下，实现多家庭间的习惯预测模型协同进化。

---

> *注：端侧 Agent 是整个智能家居系统的“大脑”，其稳定性和响应速度直接决定了用户对“无感智能”的体感。*
