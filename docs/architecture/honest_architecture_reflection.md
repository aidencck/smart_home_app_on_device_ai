# 诚实的架构复盘：端侧 AI Agent 的“理想”与“现实”

> 这是一份面向专业架构师和技术专家的内部复盘文档。在对外的 README 中，我们描绘了一个完美的“端侧 AI Agent”蓝图。但作为技术人，我们需要诚实地审视代码仓库的现状，剖析哪些是**已落地的真能力**，哪些是**通过 Mock 掩盖的技术债**，以及未来真正走向 Production 还需要跨越哪些深水区。

---

## 🟢 一、 理想与现实的交汇：我们在代码里真正做到了什么？

在当前的 `main` 分支中，我们确实将一些前沿理念转化为了一定程度的工程实现：

1. **架构分层是清晰的**：
   `on_device_agent` 被抽离成了一个独立的 package。我们定义了 `LlamaCppEngine` 的接口，定义了 `AgentContextProvider` 和 `AgentActionExecutor`。这使得 UI 层和 AI 逻辑层确实做到了解耦。
2. **防幻觉的 GBNF 理念是跑通的**：
   在 `on_device_agent.dart` 的 `handleUserQuery` 中，我们确实实现了根据 `availableDevices` 动态拼接 `deviceIdRule`，并将其组合成 GBNF 字符串（第 112-124 行）。这证明了“基于运行时状态约束模型输出”的逻辑闭环是存在的。
3. **端侧 RAG 的基建是存在的**：
   我们确实引入了 `isar` 数据库，并在 `ActionExecutor` 中编写了 `_logUserBehavior` (写入) 和 `getRecentLogs` (读取) 的逻辑。
4. **UI 层的状态感知体验做出来了**：
   `ExecutionResult` 确实包含了 `beforeState` 和 `afterState`，UI 气泡也能根据这些数据渲染出直观的变化对比和思维链。

---

## 🔴 二、 诚实的自我剖析：我们“吹的牛”里有多少水分？

如果一位资深 C++ / 移动端架构师 Clone 了我们的代码，他们会立刻发现我们在 README 中宣称的“纯本地推理”、“零延迟”、“异步隔离”等能力，目前很大程度上依赖于 **Mock (模拟) 和妥协**。

### 1. 所谓“基于 FFI 深度绑定 llama.cpp”
*   **现实骨感**：虽然 `packages/on_device_agent/ios/Classes/llama_cpp_src` 目录下有一大堆 C++ 源码，但如果您查看 `LlamaCppEngine` 的实现，会发现目前的 `infer` 方法**并没有真正调用底层的 FFI 接口**进行张量计算。
*   **技术债**：实际上我们退回到了 `LlamaCppEngineMock`。真正的 C++ FFI 绑定（处理模型 Mmap、Tokenize、KV Cache 管理、Logits 采样）在 Dart 侧是极其复杂的。我们目前绕过了跨语言内存管理和指针转换的深水区。
*   **专家拷问**：“你们说实现了端侧推理，那请问你们的 `llama_context` 指针在哪里维护？Flutter 热重载时内存泄漏怎么处理？iOS/Android 编译 CMakeLists 时如何链接 NPU/GPU 动态库？”

### 2. 所谓“毫秒级响应与 Isolate 异步隔离”
*   **现实骨感**：既然底层是 Mock 的 `Future.delayed(800)`，自然不会阻塞主线程。
*   **技术债**：在真实的端侧模型中，即使把推理放进 Isolate，由于模型参数极大（通常 > 1GB），在加载模型时如果直接把文件读进 RAM，瞬间的内存峰值极易被系统的 OOM-Killer 杀掉进程。
*   **专家拷问**：“2B 模型量化后也有 1.5GB，手机 RAM 峰值管控怎么做的？有没有用 `mmap`？如果用 `mmap`，你们的 Dart FFI 是怎么把文件句柄安全传给 C++ 的？”

### 3. 所谓“纯本地隐私级 RAG”
*   **现实骨感**：我们虽然用了 Isar 落库，但在意图路由上，仅仅写了几个 `if (query.contains("开过"))` 这种极为简陋的硬编码正则匹配。
*   **技术债**：这根本算不上智能的 RAG Intent Router。真实的场景下，用户的查询话术千变万化，仅靠几个关键词极易造成误拦截。
*   **专家拷问**：“这叫 RAG？这只是加了个 If-Else 查数据库而已。如果没有本地的 Embedding 模型（比如用 ONNX 跑一个小巧的 BGE 模型）做向量检索，当日志超过 1000 条时，你怎么知道该把哪 10 条塞进 Prompt 里？”

---

## 🚀 三、 面向高阶架构师：我们接下来的硬核技术演进图

谦虚地承认不足，是为了更好地前行。要让这个 Demo 变成一个真正让业界惊叹的 Production-ready 项目，我们还需要补充以下硬核技术栈：

### Phase 1: 攻克 C++ FFI 与硬件加速 (最难的一场硬仗)
*   **实现真正的 `ffi.dart` 绑定**：抛弃 Mock。我们需要编写 Dart 代码来声明 C 语言的 `llama_backend_init`、`llama_load_model_from_file`、`llama_decode` 等核心函数。
*   **打通异构计算 (Metal / Vulkan)**：
    *   在 iOS 的 `Podfile` / `build-xcframework.sh` 中强制开启 `GGML_METAL=1`，确保模型跑在苹果的 Neural Engine 或 GPU 上。
    *   在 Android 的 `CMakeLists.txt` 中配置 Vulkan 支持，否则纯 CPU 推理速度将慢到无法使用（可能只有 1~2 tokens/s）。

### Phase 2: 内存管理与模型下发架构
*   **实现内存探针与模型降级**：
    *   不能假设用户都有 8GB RAM。需要引入 Native Channel 获取设备可用物理内存。
    *   实现模型动态加载：低于 4GB 内存自动降级使用云端 API，或仅加载极小参数量的专门针对控制微调的模型。
*   **KV Cache 复用机制**：在多次连续对话中，不需要每次都重新 `eval` 前面的系统 Prompt 和上下文，需要实现 C++ 侧的 KV Cache 状态保留与自动过期回收。

### Phase 3: 语义级 RAG 与端云协同
*   **引入端侧 Embedding 模型**：利用 TensorFlow Lite (TFLite) 插件或 ONNX Runtime，在端侧运行一个极小的文本向量化模型（如 20MB 的 MiniLM）。
*   **向量化 Isar**：虽然 Isar 是对象数据库，但我们需要计算 Query 向量和日志向量的余弦相似度（Cosine Similarity），这需要我们在 Dart 层手写高效的 SIMD 矩阵运算，或者寻找支持向量检索的本地库（如 ObjectBox 的 Vector Search 特性）。

---

## 🚀 四、 架构演进最新突破：走向生产级的端云协同 (2026-03-30 更新)

在我们坦诚地面对了纯端侧算力与内存的物理限制后，项目在最新的架构迭代中完成了**从“纯端侧执念”到“务实端云协同”的重大跨越**。结合 `README.md` 与最新提交的架构文档，我们取得了以下实质性的设计突破：

### 1. 明确了端与云的边界 (Edge-Cloud Boundary)
不再强求端侧处理所有逻辑。端侧 0.5B 模型（拦截 80% 高频简单指令）与云端 FastAPI + vLLM/商业大模型（处理 20% 复杂长尾意图）形成了完美的梯队。
通过引入**复合指令切割引擎 (Intent Splitting)**，我们实现了端侧并发：本地能干的立刻做（极速响应），本地干不了的剥离后异步上云。

### 2. 构建了坚不可摧的隐私护城河 (Privacy by Design)
为了解决上云带来的隐私焦虑，我们从代码级设计了三道防线：
*   **端侧防线**：所有上云的长尾 Query 必须先经过轻量级 NER 引擎，剥离姓名、地址等个人标识符 (PII)。
*   **云端防线**：FastAPI 路由网关实行“内存阅后即焚”，绝不将包含用户明文指令的请求体持久化到关系型数据库中。
*   **飞轮防线**：收集 Bad Cases 优化模型是必须的，但我们引入了**非默认勾选的 Opt-in 强授权墙**，未授权数据直接静默丢弃，彻底规避了 GDPR/PIPL 的生死线。

### 3. 数据飞轮的闭环设计 (Data Flywheel Loop)
原本我们对模型的定制停留在手动写脚本，现在我们设计了完整的流水线：
脱敏日志上报 -> Celery 异步队列 -> **LLM-as-a-Judge 二次隐私过滤与质量打分** -> 提取 Hard Examples -> Model Forge 基于“5条黄金规则”合成训练集 -> LoRA 微调 -> 基于 App Version Code 的安全 OTA 下发。

## 💡 总结

目前的仓库，**在“Agent 逻辑流”和“UI 交互表现”上确实兑现了我们在 README 中的承诺**，它提供了一个极佳的“端侧大模型应用长什么样”的范本。

随着《FastAPI 端云协同架构落地方案》与《隐私合规体系》的加入，我们不仅有了一个极客的端侧玩具，更拥有了一套**经得起大厂内部研发评审、安全合规审计、以及高并发考验的 Production-Ready (生产可用) 架构蓝图**。

这也正是我们将其开源的目的：**吸引真正懂底层优化的极客，一起来填平这段从“应用层”到“硅层”的鸿沟。**