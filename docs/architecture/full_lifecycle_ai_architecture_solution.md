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
*   **Judge 自动化打分**：见 [`backend/app/worker/tasks.py`](../../backed_project/app/worker/tasks.py)。后台 Celery Worker 调用云端大模型（如 vLLM/OpenAI），作为“裁判 (Judge)”对脱敏日志进行二次隐私过滤、意图重构和质量打分。
*   **高质量负样本萃取**：打分合格的日志将被格式化为 `JSONL` 格式，自动存入云端对象存储，作为下一轮 SFT（监督微调）的优质负样本数据池。

---

## 3. 模型训练与微调 (Model Forge)

位于 [`model_forge/`](../../model_forge/training/) 的“模型造车间”是我们提炼行业壁垒的核心基建。

### 3.1 训练环境与技术栈
*   **硬件底座**：全面适配 Apple Silicon (Mac M4) 的统一内存架构，使用 MLX 框架大幅降低训练成本。
*   **数据工程**：通过 [`data_synthesis.py`](../../model_forge/training/notebooks/data_synthesis.py) 生成涵盖动态设备快照、模糊意图覆盖的黄金训练集。

### 3.2 自动化微调流水线 (QLoRA Pipeline)
*   **基础模型**：选用轻量级开源模型（如 Qwen-2.5-1.5B 或 Gemma-2B）作为底座。
*   **微调策略**：采用 **QLoRA (Quantized Low-Rank Adaptation)**，仅更新极少量的权重参数，大幅降低显存占用。
*   **执行脚本**：见 [`train.py`](../../model_forge/training/scripts/train.py)。支持一键执行，自动加载云端汇聚的 JSONL 数据池进行持续迭代。

---

## 4. 端云协同推理架构 (Inference Architecture)

这是支撑用户体验最核心的环节，实现了“快”与“智”的平衡。

### 4.1 端侧推理：零幻觉与极致响应
*   **Llama.cpp 引擎绑定**：见 [`llama_bindings.dart`](../../model_forge/inference/on_device_agent/lib/src/engine/llama_cpp/llama_bindings.dart)。通过 Dart FFI 直接调用底层 C++ 推理库。
*   **动态 GBNF 语法树**：在推理前，Agent 动态提取当前局域网内的真实设备 ID（如 `light_1`），将其编译为 C++ 采样约束。**从底层掐断了 AI 输出虚假设备的可能，实现 100% 的 JSON 格式命中率**。
*   **本地 RAG**：查询“今天谁开过门”时，直接在本地 Isar 数据库进行毫秒级检索，断网可用且物理隔绝隐私。

### 4.2 云端推理：语义缓存与防竞态
*   **防投毒语义缓存**：云端 FastAPI 拦截请求，基于 `Hashlib SHA-256` 计算意图哈希。高频复合指令直接命中缓存返回 0 延迟 JSON，阻断了 Prompt 注入攻击。
*   **分布式锁与状态探针**：利用 `Command ID + Redis SETNX` 防止重放攻击；利用 `Vector Clock + Lua 脚本` 确保设备影子更新时的原子性，彻底解决 TOCTOU（检查与执行间隙）漏洞。

---

## 5. 工程部署与模型分发 (Deployment & OTA)

训练好的模型如何安全、高效地送到用户设备上？

### 5.1 模型量化与打包
*   **极度量化**：微调后的模型经过 [`quantize.sh`](../../model_forge/training/scripts/quantize.sh) 处理，转换为 `GGUF` 格式。通常采用 `Q4_K_M`（4-bit 量化）或更激进的 `IQ2_XXS`（2-bit 量化），将 2B 模型的内存占用压缩至 1.5GB 以下。
*   **端侧 OTA 动态下发**：见 [`model_downloader.dart`](../../model_forge/inference/on_device_agent/lib/src/engine/model_downloader.dart)。App 启动时会校验本地模型版本，通过差异化下载 (Delta Update) 策略静默拉取最新的微调权重。

### 5.2 容器化云端基建
*   **Docker 编排**：云端微服务（FastAPI, PostgreSQL, Redis, Celery, RabbitMQ）通过 `docker-compose.yml` 统一部署，确保开发、测试与生产环境的一致性。

---

## 6. 端侧 AI 全生命周期核心指标体系 (On-Device AI Full-Lifecycle Metrics Framework)

端侧 AI 的成败取决于能否在算力受限的设备上流畅运行，且在业务上产生实质价值。我们建立了一套覆盖“数据准备 -> 模型微调 -> 工程推理 -> 商业变现”的全视角指标体系。该体系是所有 AI 研发和测试工作的“北极星”。

### 6.1 阶段一：数据质量与训练指标 (Data & Training Metrics)
本阶段决定了模型“吃进去的粮”和“消化能力”，是整个数据飞轮的起点。

*   **Data Purity (数据纯净度) = 100%**：进入 SFT 训练集前，必须通过 Judge 清洗，彻底剥离所有 PII（个人身份信息），确保隐私绝对安全。
*   **Data Synthesis Yield (数据合成有效率) ≥ 90%**：基于业务指标逆向推导生成的合成数据，能通过云端 LLM-as-a-Judge 验证并入库的比例。
*   **Benchmark Coverage (测试集维度覆盖率)**：Golden Dataset 必须包含 40% 直接指令、30% 模糊推理、20% 越界负样本、10% 上下文陷阱，确保评估无死角。
*   **Loss Convergence (收敛稳定性)**：QLoRA 训练过程中的 Loss 曲线平滑下降，验证集 Loss 无回弹（防止过拟合与灾难性遗忘）。

### 6.2 阶段二：模型能力验收指标 (Model Acceptance KPIs)
这是模型能否从 `Model Forge` 车间毕业的硬性标准。根据 [`data_evaluation_and_acceptance_framework.md`](../../model_forge/training/data_evaluation_and_acceptance_framework.md)，我们在 Golden Benchmark 上自动评测：

*   **FSR (Format Strictness Rate / 刚性解析率) ≥ 99.5%**：模型输出必须能被 `json.loads()` 无错解析，绝不包含任何解释性废话或多余 Markdown 标记。
*   **IEM (Intent Exact Match / 意图精确匹配率) ≥ 95.0%**：解析后的 JSON 中，`device_id`、`action` 与 Ground Truth 完全一致（涵盖模糊意图的精确路由）。
*   **OOD-R (Out-of-Domain Rejection / 越界拦截率) ≥ 98.0%**：面对非智能家居指令（如写代码、闲聊、诱导违规），必须稳定输出 `{"action": "none"}`。
*   **DCR (Dynamic Context Resilience / 抗干扰率) ≥ 99.0%**：当传入的设备列表变化或出现不存在的同名设备时，模型不产生幻觉调用。

### 6.3 阶段三：工程与推理性能指标 (Engineering & Inference Metrics)
决定了用户在使用时的“体感流畅度”和手机的“健康度”，是端侧部署的红线。

*   **TTFT (Time To First Token / 首字延迟) ≤ 300ms**：从用户点击发送到 UI 渲染出第一个状态变化的时间（得益于 Isolate 异步调度）。
*   **End-to-End Latency (端到端控制延迟) ≤ 800ms**：包含语音转写、意图网关分发、模型推理、局域网设备执行的全链路耗时。
*   **Throughput (生成吞吐量) ≥ 15 Tokens/s**：在 Apple M 系列 / 高通骁龙 8Gen2 级别芯片上的生成速度。
*   **RAM Peak (推理峰值内存) ≤ 1.5GB**：通过 GGUF (`Q4_K_M` 或 `IQ2_XXS`) 量化及 mmap 内存映射，确保在 3GB/4GB 内存低端机上 **0 OOM 崩溃率**。
*   **Model Size (模型分发体积) ≤ 500MB**：通过 OTA 动态下发时的极致压缩体积，降低用户等待与带宽成本。
*   **100% GBNF Format Hit (端侧语法树绝对命中)**：结合动态 GBNF 语法树注入，在实际推理中强行阻断非法 JSON 生成。

### 6.4 阶段四：商业与业务价值指标 (Business & ROI Metrics)
验证端出 AI 架构重构是否真正为企业带来了降本增效的护城河。

*   **Edge Routing Ratio (端侧拦截率) ≥ 80%**：在本地闭环处理，未向云端发起大模型请求的指令占比（大幅降低云端并发压力）。
*   **Cloud Token Cost Reduction (云端 Token 降本率)**：相比纯云端方案，通过本地拦截和云端 Semantic Cache，节省的 API 账单费用估算。
*   **User Opt-in Rate (隐私授权转化率)**：用户愿意开启“体验改善计划”提供脱敏 Bad Case 反哺数据飞轮的比例。
*   **First AI Interaction Conversion (首次 AI 交互转化率)**：用户完成首个设备接入后，在 24 小时内完成首次 AI 控制的比例（体现端侧智能的上手门槛）。

---

## 7. 指标收集体系与监控看板模型搭建 (Telemetry & Dashboarding)

光有指标定义还不够，我们需要一套无侵入、低延迟的工程链路，将端侧散落的数据汇聚到云端，并构建直观的 BI 监控看板，支撑产品和研发团队的决策。

### 7.1 全链路指标采集架构 (Telemetry Pipeline)
为避免阻塞核心业务流，指标采集遵循**“异步、批量、弱网容错”**原则。

*   **端侧埋点与本地缓冲 (Edge Telemetry Agent)**：
    *   在 Flutter 层封装统一的 `TelemetryService`，将交互事件（意图命中、TTFT、内存峰值、路由选择）封装为结构化 Event。
    *   **Isar 本地缓冲池**：考虑到弱网环境，事件不直接发网，而是写入 Isar 数据库的 `telemetry_logs` 表，设定阈值（如每满 50 条或每 5 分钟）打包。
*   **云端接入与流处理 (Cloud Ingestion)**：
    *   **FastAPI 探针接口**：`/api/v1/telemetry/batch` 接收端侧的 GZIP 压缩上报数据。
    *   **Kafka/RabbitMQ 削峰**：数据落地后立刻发送 Ack 释放端侧连接，后端利用 Celery 或 Kafka 消费队列进行异步清洗和结构化转换。
*   **持久化与多维聚合 (Data Storage)**：
    *   **ClickHouse / TimescaleDB**：针对海量时序埋点，选用列式数据库存储，支持按设备型号、模型版本、时间维度的极速 OLAP 聚合查询。

### 7.2 监控看板模型设计 (Dashboard Modeling)
基于收集到的数据，我们建议使用 **Grafana (偏工程监控)** 结合 **Apache Superset (偏业务 BI)** 搭建三层看板模型：

#### 面板一：CEO / 产品大盘看板 (Business & ROI Dashboard)
*   **核心图表**：
    *   *全局端侧拦截率 (Gauge)*：直观展示当前多少比例的请求在本地完成（目标 80%）。
    *   *云端 API 成本节省估算 (Stat/Trend)*：基于 Semantic Cache 和本地拦截，动态折算节省的 Token 费用（美元）。
    *   *每日 Bad Case 自动化回收量 (Bar Chart)*：展示数据飞轮的运转健康度。

#### 面板二：AI 算法演进看板 (Model Quality Dashboard)
*   **核心图表**：
    *   *各版本模型 FSR 与 IEM 对比 (Radar/Bar)*：横向对比 v1.0 与 v1.1 模型在真实用户环境中的意图解析成功率。
    *   *Judge 清洗漏斗模型 (Funnel)*：展示端侧上报 -> Judge 初筛 -> 提取负样本 -> 进入 SFT 训练集的数据转化率。
    *   *幻觉拦截监控 (Time Series)*：统计 OOD-R 越界拦截和设备上下文报错的触发频次。

#### 面板三：工程稳定性与性能看板 (DevOps & Performance Dashboard)
*   **核心图表**：
    *   *TTFT 延迟分布热力图 (Heatmap)*：展示不同型号手机（如 iPhone 15 vs Android 低端机）的首次响应延迟分布。
    *   *端侧内存 OOM 崩溃率监控 (Time Series)*：监控 Isolate 引擎是否因模型内存泄露导致 App 崩溃。
    *   *FastAPI 与 Celery 队列积压水位 (Gauge/Graph)*：监控云端数据飞轮和 API 网关的并发健康度。

---

## 8. 总结

本解决方案打通了从“硬件感知 → 本地推理 → 云端脱敏清洗 → 模型自动化微调 → GGUF 量化分发 → 端侧渲染执行”的完整技术脉络。辅以完善的“指标采集与多维监控看板”，这不仅仅是一个工程实践，更是构建智能家居行业**数据飞轮壁垒**的核心蓝图。