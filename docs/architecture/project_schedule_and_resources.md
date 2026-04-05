# Smart Home On-Device AI - 敏捷研发排期与资源调度计划 (Project Schedule & Resource Allocation)

> **文档状态**: 活跃 (Active)
> **视角**: 高级项目管理专家 (Senior PM)
> **目标**: 基于已拆解的 WBS 和 Product Backlog，建立可执行的 Sprint 排期、资源分配矩阵以及依赖阻塞处理机制。

---

## 1. 资源分配矩阵 (Resource Allocation Matrix)

为确保“端云协同”架构的高效落地，项目团队分为三个核心 Feature Squads，进行跨职能协作：

| 职能角色 | 人员编制 | 核心职责域 (Tracks) | 关键产出/KPI |
| :--- | :--- | :--- | :--- |
| **端侧架构组 (Client Arch)** | 2x Flutter 资深开发 | Track 1 (基座), Track 3 (UI/UX) | FFI 多线程封装、Zero-UI 物理引擎实现、TTFT < 300ms |
| **AI 与数据组 (AI & Data)** | 1x AI 工程师, 1x 数据开发 | Track 2 (模型), Track 4 (数据飞轮) | SFT 数据合成、QLoRA 微调、NER 脱敏引擎、模型意图抽取率 > 95% |
| **工程与质量组 (QA/DevOps)** | 1x DevOps/后端, 1x QA | Track 1.4 (网关), Track 4 (监控) | FastAPI 兜底路由、OTA 模型分发、0 OOM 监控探针、自动化流水线 |

---

## 2. 迭代开发排期 (Sprint-based Schedule)

项目采取**双周一迭代 (Two-Week Sprint)** 机制。以下是未来 3 个 Sprints（共 6 周）的核心开发排期与甘特图里程碑。

### 🏃‍♂️ Sprint 1: 核心智能底座 (Weeks 1-2)
**战略目标**: 跑通端侧大模型从加载、推见到结构化输出的“任督二脉”。
**Milestone**: M1 - MVP Core Intelligence

*   **[Client Arch] 任务 1**: 基于 Dart FFI 封装 Llama.cpp 引擎，建立 Isolate 隔离池。(优先级: **Highest**)
*   **[Client Arch] 任务 2**: 基于 `device.dart` 协议开发动态 GBNF 语法生成器。(依赖任务 1)
*   **[AI & Data] 任务 3**: 构建 SmartHome 垂直领域自动化数据合成流水线 (GPT-4 辅助)。(优先级: **High**)
*   **[QA/DevOps] 任务 4**: 搭建 FastAPI 基础框架与 Redis Cluster 设备影子重构。
*   **Sprint 验收**: 在测试机上成功加载 0.5B GGUF 模型，生成合法的控制 JSON，且 UI 不卡顿。

### 🏃‍♂️ Sprint 2: 场景感知与端云协同 (Weeks 3-4)
**战略目标**: 引入本地记忆与复杂指令的平滑降级，建立初版 Zero-UI 体验。
**Milestone**: M2 - Context & Edge-Cloud

*   **[Client Arch] 任务 5**: 集成 Isar 数据库，打通本地 `BehaviorLog` 的 RAG 上下文注入。(优先级: **High**)
*   **[Client Arch] 任务 6**: 开发物理引擎驱动的设备状态 UI (制冰机、灯光动画)。
*   **[AI & Data] 任务 7**: 完善 M4/RTX4090 上的 QLoRA 微调脚本与 GGUF 量化 (Q4_K_M) 流水线。
*   **[QA/DevOps] 任务 8**: 开发三层意图路由分发网关，长尾闲聊无缝切换至云端兜底。(依赖任务 4)
*   **Sprint 验收**: 用户说“我很热”，端侧结合本地温湿度状态准确输出开空调指令；超出能力的问题隐式走云端。

### 🏃‍♂️ Sprint 3: 主动智能与飞轮闭环 (Weeks 5-6)
**战略目标**: 建立数据安全回收通道与端侧性能防线。
**Milestone**: M3 - Proactive & Flywheel

*   **[Client Arch] 任务 9**: 建立设备专属多模态感官闭环 (ASMR 音效 + CoreHaptics 触觉)。
*   **[AI & Data] 任务 10**: 开发 App 端显性合规授权墙 (Opt-in) 与前置轻量级 NER 脱敏引擎。(优先级: **Highest** - 法务合规阻点)
*   **[QA/DevOps] 任务 11**: 开发基于 Version Code 与可用 RAM 的模型 OTA 热更新及平滑降级策略。
*   **[QA/DevOps] 任务 12**: 部署端侧性能探针 (TTFT 监控与 OOM 防御拦截)。
*   **Sprint 验收**: 端侧成功剥离用户姓名并上传日志；低内存设备自动熔断本地推理并走纯云端。

---

## 3. 核心阻塞点与风险应对 (Risk Management)

项目推进过程中，必须严格管理以下阻塞性依赖（Blockers）：

| 风险/阻塞点 (Blocker) | 触发条件 | 应对策略 (Mitigation) | 责任人 |
| :--- | :--- | :--- | :--- |
| **设备协议阻点** | 业务新增设备，但 `device.dart` 协议未定 | GBNF 无法生成，模型无法控制。要求：**协议定义先于开发至少 3 天完成。** | PO / Arch |
| **合规与隐私红线** | 欲收集用户 Bad Case 优化模型 | 必须强依赖 `任务 10 (Opt-in & NER)` 完成，否则禁止任何非匿名数据出端。 | PM / AI |
| **FFI 接口崩溃** | OTA 下发了与当前 Flutter FFI 不兼容的模型版本 | 强依赖 `任务 11` 中的 Version Code 绑定下发逻辑，否则引发大规模 Crash。 | DevOps |
| **端侧算力挤兑** | 用户设备老旧，RAM < 2GB | 推理引擎启动前必须通过硬件探针评估，不足则静默降级为纯 FastAPI 云端模式。 | Arch |

---

## 4. 远程项目管理系统操作指南 (Jira/GitHub)

1.  **看板结构**: 请在 GitHub Projects/Jira 中建立标准的 `Todo -> In Progress -> In Review -> Done` 工作流。
2.  **里程碑绑定**: 将上述任务绑定到对应的 M1/M2/M3 Milestone 中，利用系统的 Burn-down Chart (燃尽图) 追踪进度。
3.  **状态流转**: 开发人员每日需更新 Issue 状态，提交 PR 时必须在描述中关联 Issue 号 (如 `Fixes #12`) 实现自动流转。
