# 智能家居端侧 AI Agent：架构设计与落地任务开发指南

基于前期的《端侧 AI Agent 技术产品方案预研》，本文档从架构师视角出发，深度剖析如何在现有的 Flutter 智能家居项目 (`smart_home_app`) 中，将该技术方案拆解为可执行、高内聚、低耦合的开发任务（落地任务开发），确保项目稳步推进。

## 1. 整体架构设计 (Clean Architecture 适配)

为了保证端侧 AI 能力的引入不影响现有智能家居基础控制链路的稳定性，我们采用**模块化与分层架构**。将 AI Agent 作为独立的基础设施层（Infrastructure）与领域服务（Domain Service）进行集成。

### 1.1 核心模块划分
建议在 Flutter 项目中创建以下独立的 Package 或模块：
- `agent_inference_engine`: **底层推理模块**。封装 `llama.cpp` 或 `MediaPipe`，通过 FFI (Foreign Function Interface) 与 Dart 通信，完全屏蔽底层 C++ 和硬件加速（Metal/OpenCL）细节。
- `agent_context_provider`: **上下文感知模块**。负责监听和汇总当前家庭的设备状态（温湿度、开关状态）及系统状态（网络、电量）。
- `agent_action_executor`: **执行与安全模块**。负责解析模型输出的 JSON，进行 Schema 校验、越界拦截（Guardrails），并调用现有的 IoT 局域网控制模块。
- `agent_ui_components`: **交互组件库**。包含语音唤醒波纹、流式文本输出（打字机效果）、建议气泡等 UI 组件。

---

## 2. 落地任务拆解与开发计划 (Task Breakdown)

为了将庞大的 AI 方案平滑落地，我们将开发任务划分为四个里程碑（Milestones），以便团队按节奏交付。

### Milestone 1: 模型基建与引擎集成 (Infrastructure & Engine)
*目标：能在 App 内成功加载并运行端侧模型，输出毫无关联的文本也算成功。*

- **Task 1.1: 模型下载与存储管理器 (Model Downloader)**
  - 实现支持断点续传的大文件下载器（模型通常 1GB-2GB）。
  - 实现模型文件的完整性校验（MD5/SHA256）。
  - 实现存储空间检测，空间不足时给出清理引导。
- **Task 1.2: 推理引擎 FFI 绑定 (FFI Binding)**
  - 编译 iOS (Metal) 和 Android (OpenCL/Vulkan) 版本的 `llama.cpp` 动态库。
  - 使用 `ffigen` 生成 Dart 接口，建立 Flutter 与 C++ 的通信通道。
- **Task 1.3: 独立线程推理 (Isolate Inference)**
  - 封装 Dart Isolate，确保模型推理（高 CPU/GPU 负载）在独立线程运行，**绝对不能阻塞主线程 UI** (避免掉帧卡顿)。
  - 实现 Token 流式返回（Streaming）的回调机制。

### Milestone 2: 提示词工程与上下文注入 (Prompt & Context)
*目标：模型能够理解当前家庭环境，并根据指令生成格式正确的 JSON。*

- **Task 2.1: 设备状态快照聚合 (State Snapshot)**
  - 编写适配器，将当前家庭拓扑图和设备最新状态序列化为极简的 JSON 或 YAML 格式，减少 Token 消耗。
  - *示例*：`[{"id":"light_1","name":"客厅主灯","state":"off"},{"id":"ac_1","name":"主卧空调","temp":26}]`
- **Task 2.2: System Prompt 动态构建 (Prompt Engineering)**
  - 设计 Few-shot (少样本) Prompt 模板，教导小模型（SLM）如何输出标准 JSON。
  - 结合设备状态快照和 User Query 拼接完整的输入 Prompt。
- **Task 2.3: 意图对齐测试 (Intent Alignment)**
  - 构建 100 条常见的智能家居语料（如“有点冷”、“我要睡觉了”、“打开灯”），在本地运行单元测试，验证模型输出 JSON 的准确率。

### Milestone 3: 动作执行与安全拦截 (Execution & Guardrails)
*目标：将模型输出的 JSON 转化为真实的物理设备动作，并保证绝对安全。*

- **Task 3.1: 鲁棒的 JSON 提取器 (Robust JSON Parser)**
  - 端侧小模型偶尔会输出多余的解释文本（幻觉）。需编写正则表达式提取文本中的 `{...}` 核心 JSON 控制块。
- **Task 3.2: 安全校验拦截器 (Security Guardrails)**
  - **白名单校验**：检查 JSON 中的 `device_id` 是否真实存在于当前家庭。
  - **边界值校验**：检查 `value` 是否合法（如空调温度不得低于 16 度，灯光亮度 0-100）。
  - 触发拦截时，生成友好的兜底回复（如“抱歉，空调温度最低只能设置到16度”）。
- **Task 3.3: 本地控制链路对接 (Local IoT Control)**
  - 将校验通过的指令映射为现有的 IoT 控制命令（如 MQTT Publish 或 Matter Invoke），下发至设备。

### Milestone 4: 端云协同与交互打磨 (UX & Cloud Fallback)
*目标：提升用户体验，处理极端情况。*

- **Task 4.1: 端云协同降级策略 (Cloud Fallback)**
  - 编写环境检测逻辑：当手机电量 < 20%、开启省电模式，或设备性能评级过低时，自动切换到云端大模型 API（如阿里云百炼 / OpenAI API）。
- **Task 4.2: 流式交互 UI (Streaming UI)**
  - 实现类似 ChatGPT 的流式打字机效果，结合震动反馈（Haptic Feedback）提升质感。
- **Task 4.3: 语音 ASR 集成 (Voice Input)**
  - 接入系统原生 Speech-to-Text 或端侧 Whisper.cpp，实现“语音 -> 文本 -> 端侧模型 -> 动作”的全离线闭环。

---

## 3. 架构师重点关注的技术风险 (Technical Risks & Mitigation)

1. **OOM (Out of Memory) 崩溃风险**
   - *风险*：低端机型加载 2GB 模型会直接被操作系统杀后台。
   - *应对*：强依赖 `mmap`（内存映射）技术加载模型文件；在应用启动时获取系统剩余可用内存（`sysctl` / `ActivityManager`），若可用内存低于 2.5GB，则强制降级到云端方案。
2. **耗电与发热限制 (Thermal Throttling)**
   - *风险*：连续多轮对话导致手机发热降频，甚至触发 iOS 的温度警告。
   - *应对*：限制模型最大生成长度（`max_tokens = 64`），智能家居指令通常极短，生成完毕后立即释放计算资源；连续对话超过 5 轮后建议休眠。
3. **Flutter FFI 内存泄漏**
   - *风险*：C++ 侧分配的内存未被 Dart 侧正确回收。
   - *应对*：严格使用 Dart FFI 的 `NativeFinalizer` 或 `Arena` 进行内存管理，结合 Flutter DevTools 的 Memory Profiler 进行多轮压测。