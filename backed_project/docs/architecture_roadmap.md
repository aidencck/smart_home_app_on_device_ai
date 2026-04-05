# 智能家居端云协同架构：深度分析与后续开发 Roadmap

## 一、 核心目标与当前进展深度分析

智能家居项目的核心终局是实现**主动智能 (Proactive Intelligence)**与**无感交互 (Zero-UI)**。
为此，项目确立了“端侧优先、云端兜底、协同进化”的架构战略。端侧负责隐私闭环与基础响应，云端负责复杂长尾路由与数据飞轮（模型进化）。

### 当前已完成的架构基建 (What we have done)
1. **云端底座 (FastAPI + Docker)**：完成了完全隔离的容器化环境，实现了统一的依赖注入、日志追踪 (X-Request-ID)、异常拦截 (Throw as Return) 及 API 泛型响应规范。
2. **设备影子与强一致性 (Device Shadow)**：开发了基于 `Vector Clock (last_update_ts)` 的 Redis 缓存更新机制，彻底解决了弱网环境下的状态乱序与脏数据问题。
3. **AI 路由与防竞态机制 (AI Routing)**：开发了云端兜底的 API 骨架，并实现了基于 `Command ID` 的防竞态校验与设备状态过期的主动拦截机制。

---

## 二、 核心架构缺失与未完成任务深度剖析 (Gap Analysis)

作为架构师，经过对 `project_execution_plan.md` 和当前 `backend` 代码的深度比对，当前端云协同架构在云端仍有以下核心拼图缺失，这些是下一阶段的攻坚重点：

### 1. Semantic Cache (语义缓存层) 的缺失
- **现状**：目前 `/api/v1/ai/chat` 会直接将请求路由给大模型（模拟 `asyncio.sleep`），这在海量并发下会产生巨大的 Token 成本和长达数秒的冷启动延迟。
- **架构要求**：需要在真正调用大模型之前，引入基于 Redis 向量或轻量级本地缓存的 `Semantic Cache`。
- **开发任务**：如果端侧传来的 Query（如“帮我把灯调暗一点”）与缓存中已解析的意图（Cosine Similarity > 0.95）匹配，则直接返回结构化的 `CommandAction`，将云端响应时间从 1000ms 压缩至 50ms 以内。

### 2. LLM-as-a-Judge 与数据飞轮 (Data Flywheel) 的断层
- **现状**：目前的 `/api/v1/data/telemetry` 仅是一个空壳接口，没有接入任何消息队列，更没有数据清洗逻辑。
- **架构要求**：端侧产生的 Bad Case 日志绝不能直接喂给模型训练，必须经过清洗。
- **开发任务**：
  - 引入 **RabbitMQ** 或 Redis Stream 接收高并发的遥测日志。
  - 开发 **Celery Worker** 异步消费日志。
  - 在 Worker 中引入 `LLM-as-a-Judge` 机制，通过 Prompt 让大模型对日志进行打分，剔除纯噪音、方言、隐私数据，最终生成高质量的 SFT (JSONL) 数据集供 `model_forge` 微调使用。

### 3. 主动 MQTT 探针通道 (Active Probe)
- **现状**：目前在 `AIService` 中，当发现端侧设备状态快照过期时（> 60s），只是简单地抛出异常 `ErrorCode.STATE_STALE`。
- **架构要求**：云端不应完全依赖端侧的被动重试。对于高危设备（门锁），云端应具备主动穿透能力。
- **开发任务**：在后端集成 MQTT Client，当发现状态过期时，云端主动向 IoT 设备（或家庭网关）下发 QoS 1 的状态查询指令，阻塞等待响应后再进行大模型推理，实现对前端透明的“极速拉取”。

### 4. 模型 OTA 动态下发与鉴权 (Model Registry)
- **现状**：`/api/v1/ota/check` 接口未实现任何根据硬件算力下发不同模型的策略。
- **架构要求**：实现“千机千面”的模型分发。
- **开发任务**：设计 PostgreSQL 的表结构（包含 App Version, RAM Size, NPU Level 等字段）。基于这些参数，动态返回适合该设备的 GGUF 模型下载链接（支持 CDN 断点续传与 MD5 校验）。

---

## 三、 后续开发 Roadmap (Action Items)

为了将上述分析落地，建议团队按以下 Sprint 计划推进开发：

### Phase 1: 智能化提速与大模型接入 (ETA: 1 Week)
- [ ] **Task 1**: 真实接入 OpenAI / vLLM API，强制启用 `Structured Outputs` (JSON Schema) 以保证输出 100% 贴合 `CommandAction` 模型。
- [ ] **Task 2**: 引入 `redis.asyncio` 的向量匹配功能或集成轻量级向量库，完成 Semantic Cache 拦截层。

### Phase 2: 飞轮基建与异步解耦 (ETA: 2 Weeks)
- [ ] **Task 3**: 完善 `docker-compose.yml`，加入 RabbitMQ 容器。
- [ ] **Task 4**: 在 `backend/app/worker/` 下建立 Celery 异步清洗框架，实现 `LLM-as-a-Judge` 的过滤流水线。
- [ ] **Task 5**: 设计 PostgreSQL 的数据存储结构（使用 SQLAlchemy），持久化高质量微调语料。

### Phase 3: 硬件协同与双向通信 (ETA: 1 Week)
- [ ] **Task 6**: 建立 PostgreSQL 模型版本策略表，实现 OTA 检查逻辑。
- [ ] **Task 7**: 集成异步 MQTT 客户端，打通云端向局域网设备的“主动探针”通道。
