# Smart Home On-Device AI - 敏捷项目管理与执行计划 (Project Execution Plan)

> **文档状态**: 活跃 (Active)
> **视角**: 项目管理专家 / 业务专家
> **目标**: 将“端云协同”与“主动智能”战略落地为可执行的工程任务，建立标准化的 WBS、依赖关系网络与迭代 Milestone，适用于导入 GitHub Projects / Jira 进行敏捷开发追踪。

---

## 1. 核心工作分解结构 (WBS)

根据项目技术架构与业务目标，我们将项目拆解为四个平行的工作流（Tracks），确保研发、数据、工程与业务拓展能够协同推进。

### Track 1: 基础设施与端侧架构底座 (Infrastructure & On-Device Architecture)
负责构建高性能的端侧计算闭环与云端兜底能力。
*   **1.1 高性能推理引擎封装**
    *   基于 Dart FFI 深度封装 Llama.cpp。
    *   实现多线程 Isolate 隔离，确保大模型推理不阻塞 UI 线程 (60fps)。
*   **1.2 确定性输出控制 (GBNF)**
    *   开发动态 GBNF (Grammar-Based Network Format) 语法生成器。
    *   根据当前设备影子状态，实时生成约束规则，确保模型输出 100% 合法的 JSON 指令。
*   **1.3 边缘 RAG 系统集成**
    *   引入 Isar 本地数据库作为时序知识库。
    *   实现 `BehaviorLog` 的上下文动态裁剪（按时间衰减或相关性），用于 Prompt 注入。
*   **1.4 动态三层意图路由网关**
    *   构建本地规则匹配层 (L1)、端侧小模型处理层 (L2) 与云端大模型兜底层 (L3) 的平滑切换机制。

### Track 2: 模型定制与数据工程管线 (Model Forge & Data Pipeline)
负责“端侧大脑”的持续训练与能力迭代。
*   **2.1 高质量数据集构建**
    *   建立 SmartHome 垂直领域的 SFT 数据集。
    *   利用 GPT-4/Claude 构建自动化的数据合成流水线（包含正常指令、复杂环境、拒绝指令等场景）。
*   **2.2 模型微调与量化流水线**
    *   基于 Qwen/Llama 架构建立 QLoRA 轻量级微调 SOP（如使用 Unsloth）。
    *   建立模型转换为 GGUF 格式及执行 Q4_K_M 极致量化的自动化脚本。
*   **2.3 模型云端分发与热插拔**
    *   搭建模型仓库 (Model Registry)，支持按 App 版本 (Version Code) 和硬件算力动态下发模型。
    *   实现静默下载、断点续传与内存热插拔。

### Track 3: 产品交互与场景模块 (Product UI/UX & Scene Module)
负责“无感智能”理念在用户端的最终呈现。
*   **3.1 物理引擎驱动 UI (Zero-UI)**
    *   引入 Flutter Impeller，将设备状态抽象为 3D/Shader 物理动画映射。
    *   废弃传统汉堡菜单，开发直觉式手势映射层。
*   **3.2 动态感知与推荐场景**
    *   开发基于本地习惯分析的主动推荐 UI 组件（横向滑动卡片）。
    *   实现支持环境变量（如当前光照、温度）动态注入的弹性场景执行引擎。
*   **3.3 多模态感官闭环**
    *   建立设备专属的 ASMR 音效与 CoreHaptics 线性马达震动反馈库。

### Track 4: 数据飞轮与质量保证 (Data Flywheel & QA)
负责系统的持续进化与稳定性保障。
*   **4.1 生产环境 Bad Case 回收闭环**
    *   在合规授权 (Opt-in) 前提下，建立端侧轻量级 NER 脱敏引擎，剥离 PII（个人身份信息）。
    *   实现云端 LLM-as-a-Judge 自动清洗流水线，反哺模型微调。
*   **4.2 性能压测与监控基建**
    *   建立端到端延迟监控打点（TTFT < 300ms, 总延迟 < 800ms）。
    *   开发内存泄漏监控探针（0 OOM 率保障）。

---

## 2. 里程碑规划 (Milestones & Sprints)

项目采用双周一个 Sprint 的敏捷节奏，以下为核心 Milestone 定义：

### Milestone 1: 最小可行性智能闭环 (MVP - Core Intelligence)
**目标**: 跑通端侧 Llama.cpp 推理与设备控制的完整链路。
*   完成端侧 Llama.cpp 引擎的 Dart FFI 封装。
*   完成初版 0.5B/1.5B GGUF 模型的加载与运行。
*   实现基于 GBNF 的 100% 格式约束输出。
*   **QA 验收**: 单设备控制指令 TTFT < 500ms，JSON 解析成功率 100%。

### Milestone 2: 动态感知与端云协同 (Context & Edge-Cloud)
**目标**: 引入本地记忆与复杂指令的云端降级能力。
*   完成 Isar 本地数据库集成，打通 RAG 上下文注入。
*   实现三层意图路由，长尾闲聊或复杂指令隐式切换至云端 FastAPI 处理。
*   完成基础物理映射 UI（如灯光、制冰机动画）与手势控制。
*   **QA 验收**: 场景推荐准确率达到 70%，云端兜底切换用户无感知（不报错）。

### Milestone 3: 主动智能与数据飞轮 (Proactive & Flywheel)
**目标**: 实现业务自增长闭环与极端场景下的稳定表现。
*   上线合规授权墙与脱敏日志回收机制。
*   打通云端自动清洗与 QLoRA 增量微调流水线。
*   完成模型按需下发 (OTA) 与热更新能力。
*   **QA 验收**: 0 OOM 崩溃率，新设备/新语料微调周期缩短至 4 小时内。

---

## 3. 关键项目依赖关系 (Critical Dependencies)

项目管理中需要重点关注以下阻塞性依赖（Blockers）：

1.  **架构层对齐约束**:
    *   `动态 GBNF 语法树` 强依赖于 `lib/models/device.dart` 中的设备定义。每次业务新增设备，必须先完成协议定义，才能推进端侧模型适配。
2.  **算力与内存约束**:
    *   端侧大模型的加载强依赖于移动设备的可用 RAM。在启动推理引擎前，必须依赖 `硬件探针` 评估资源，若资源不足（如低于 2GB）必须降级至纯云端模式。
3.  **合规流程约束**:
    *   任何涉及 `日志回收` 与 `数据飞轮` 的功能上线，必须前置依赖 `Opt-in 授权 UI` 和 `端侧 NER 脱敏引擎` 的完成，否则存在重大法务风险。
4.  **模型与 App 版本绑定**:
    *   GGUF 模型的 OTA 下发强依赖于 App 的 `Version Code` 校验。不匹配的模型可能导致 FFI 层面的 Crash。

---

## 4. 协作与流转规范 (Agile Workflow)

为了确保远程仓库管理的高效，团队应遵循以下原则：

*   **Issue 驱动**: 所有开发工作、Bug 修复、甚至文档更新，必须有对应的 GitHub/Jira Issue。
*   **Label 规范**: 使用 `epic`, `story`, `bug`, `tech-debt`, `model-forge`, `ui/ux` 等统一标签体系。
*   **DoD (Definition of Done)**:
    *   代码合并至 `main` 分支。
    *   通过 CI/CD 流水线（Lint, Unit Test）。
    *   满足该 Issue 设定的具体性能/准确性 QA 标准。
    *   如果是新设备接入，必须同步更新 `business_expansion_model_iteration_sop.md`。
