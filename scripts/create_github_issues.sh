#!/bin/bash

# Ensure gh cli is installed and authenticated before running this script
# brew install gh
# gh auth login

echo "Creating Epics and Issues for Smart Home On-Device AI Project..."

# --- Phase 1: FastAPI 端云协同底座搭建 ---
echo "Creating Phase 1 Epic..."
PHASE1_EPIC=$(gh issue create --title "[EPIC] Phase 1: FastAPI 端云协同底座搭建" \
  --label "epic, roadmap" \
  --body "## 🎯 Epic 概述
构建高可用、防并发竞态的云端微服务，作为端侧 Agent 的坚实后盾。

## 📋 包含的子任务
- [ ] 初始化 FastAPI 后端脚手架
- [ ] 基于 Redis Cluster 重构设备影子
- [ ] Flutter 端 Command ID 拦截器
- [ ] 安防高危设备 0s TTL MQTT 探针

## 验收标准
- [ ] 所有的子任务均已关闭
- [ ] 测试覆盖率达到要求
- [ ] 相关文档已更新至 Wiki")
echo "Created: $PHASE1_EPIC"

gh issue create --title "初始化 FastAPI 后端脚手架 (Pydantic v2 & JWT)" --label "enhancement, good first issue" --body "包含 Pydantic v2 全局校验与 JWT 鉴权中间件。属于 Epic: $PHASE1_EPIC"
gh issue create --title "基于 Redis Cluster 重构设备影子 (Vector Clock 机制)" --label "enhancement" --body "基于 Redis Cluster 实现状态增量更新，引入 Vector Clock 时间戳校验机制。属于 Epic: $PHASE1_EPIC"
gh issue create --title "Flutter 端 Command ID 拦截器 (防幽灵播报)" --label "bug, enhancement" --body "在 Flutter 端实现 Command ID 拦截器，解决云端异步返回较慢导致的“幽灵播报”。属于 Epic: $PHASE1_EPIC"
gh issue create --title "安防高危设备 0s TTL MQTT 探针" --label "enhancement" --body "针对安防设备开发主动拉取状态的 MQTT 极速通道。属于 Epic: $PHASE1_EPIC"


# --- Phase 2: 隐私合规与大模型路由 ---
echo "Creating Phase 2 Epic..."
PHASE2_EPIC=$(gh issue create --title "[EPIC] Phase 2: 隐私合规与大模型路由" \
  --label "epic, roadmap" \
  --body "## 🎯 Epic 概述
建立严格的数据脱敏管道与意图分发网络。

## 📋 包含的子任务
- [ ] 端侧轻量级 NER 前置脱敏引擎
- [ ] App 端合规授权墙 (Opt-in UI) 开发
- [ ] FastAPI 路由层 Semantic Cache
- [ ] vLLM 与商业 API 的 Structured Outputs 对齐

## 验收标准
- [ ] 所有的子任务均已关闭
- [ ] 测试覆盖率达到要求")
echo "Created: $PHASE2_EPIC"

gh issue create --title "端侧轻量级 NER 前置脱敏引擎" --label "enhancement" --body "在 Flutter 端接入轻量级 NER 引擎，上云前剥离姓名、地址等个人标识符 (PII)。属于 Epic: $PHASE2_EPIC"
gh issue create --title "App 端合规授权墙 (Opt-in UI) 开发" --label "enhancement, good first issue" --body "App 端开发极显眼的“体验改善计划”授权弹窗（非默认勾选），控制日志上传阀门。属于 Epic: $PHASE2_EPIC"
gh issue create --title "FastAPI 路由层 Semantic Cache (Redis/Milvus)" --label "enhancement" --body "在 FastAPI 路由层接入 Redis/Milvus，拦截高频通用指令以降低大模型冷启动延迟。属于 Epic: $PHASE2_EPIC"
gh issue create --title "vLLM 与商业 API 的 Structured Outputs 对齐" --label "enhancement" --body "确保 vLLM 开启 \`--guided-decoding-backend\`，商业 API 启用 Structured Outputs。属于 Epic: $PHASE2_EPIC"


# --- Phase 3: 数据飞轮与模型演进 ---
echo "Creating Phase 3 Epic..."
PHASE3_EPIC=$(gh issue create --title "[EPIC] Phase 3: 数据飞轮与模型演进" \
  --label "epic, roadmap" \
  --body "## 🎯 Epic 概述
打造可持续进化的“主动智能”模型底座。

## 📋 包含的子任务
- [ ] LLM-as-a-Judge 脱敏日志二次清洗流水线
- [ ] 端侧意图解耦 (Intent Splitting) 与并行调度器
- [ ] 基于 Version Code 的 OTA 模型动态下发策略
- [ ] (预研) 端侧微调与联邦学习架构探索

## 验收标准
- [ ] 所有的子任务均已关闭")
echo "Created: $PHASE3_EPIC"

gh issue create --title "LLM-as-a-Judge 脱敏日志二次清洗流水线 (Celery)" --label "enhancement" --body "开发 Celery Worker 消费脱敏日志，通过大模型进行二次隐私审查与质量打分。属于 Epic: $PHASE3_EPIC"
gh issue create --title "端侧意图解耦 (Intent Splitting) 与并行调度器" --label "enhancement" --body "开发轻量级分类器，实现本地控制与云端长尾对话的并行调度。属于 Epic: $PHASE3_EPIC"
gh issue create --title "基于 Version Code 的 OTA 模型动态下发策略" --label "enhancement" --body "开发基于 App Version Code 的模型强校验下发服务，杜绝跨版本模型导致推理 Crash。属于 Epic: $PHASE3_EPIC"
gh issue create --title "(预研) 端侧微调与联邦学习架构探索" --label "documentation, enhancement" --body "探索将微调任务下发至端侧计算梯度的技术路径。属于 Epic: $PHASE3_EPIC"

# --- Phase 4: 端侧核心推理与 RAG 优化 (Architecture Docs) ---
echo "Creating Phase 4 Epic..."
PHASE4_EPIC=$(gh issue create --title "[EPIC] Phase 4: 端侧推理引擎与本地 RAG 深度优化" \
  --label "epic, roadmap" \
  --body "## 🎯 Epic 概述
根据 \`honest_architecture_reflection.md\`，深度优化 Flutter 端的 Llama.cpp 引擎调用机制、GGUF 模型约束采样以及本地 Isar RAG 检索流程，确保端侧 0 延迟、0 幻觉控制。

## 📋 包含的子任务
- [ ] 优化 Dart FFI 到 Llama.cpp 的多线程调用策略
- [ ] 引入 GBNF 语法树进行 100% 格式约束采样
- [ ] 优化基于 Isar 的本地向量数据库相似度计算
- [ ] 开发长尾对话的降级云端路由中间件

## 验收标准
- [ ] 端侧硬件控制指令响应时间 < 300ms
- [ ] 控制指令 JSON 格式正确率达到 100% (通过 GBNF)")
echo "Created: $PHASE4_EPIC"

gh issue create --title "优化 Dart FFI 到 Llama.cpp 的多线程调用策略" --label "enhancement, flutter" --body "解决当前 Flutter 隔离区 (Isolate) 与 C++ 推理引擎之间的数据拷贝开销，提升 token 生成速度。属于 Epic: $PHASE4_EPIC"
gh issue create --title "引入 GBNF 语法树进行 100% 格式约束采样" --label "enhancement, ai" --body "在端侧模型推理时，强制注入基于设备影子 Schema 的 GBNF 语法树，杜绝 AI 幻觉生成无效 JSON。属于 Epic: $PHASE4_EPIC"
gh issue create --title "优化基于 Isar 的本地向量数据库相似度计算" --label "enhancement, rag" --body "提升端侧 RAG (Retrieval-Augmented Generation) 检索本地设备状态和环境上下文的速度。属于 Epic: $PHASE4_EPIC"
gh issue create --title "开发长尾对话的降级云端路由中间件" --label "enhancement, architecture" --body "当用户指令超出本地小模型能力（如：'讲个笑话'）时，无缝且隐式地将请求路由至云端 vLLM 处理。属于 Epic: $PHASE4_EPIC"

# --- Phase 5: 数据合成与模型评估体系 (Model Forge) ---
echo "Creating Phase 5 Epic..."
PHASE5_EPIC=$(gh issue create --title "[EPIC] Phase 5: Model Forge 数据合成与模型评估体系建设" \
  --label "epic, roadmap" \
  --body "## 🎯 Epic 概述
根据 \`model_forge/data_evaluation_and_synthesis_rules.md\` 和验收框架，搭建端侧模型自动化微调与多维度的指标评测体系。

## 📋 包含的子任务
- [ ] 自动化运行数据合成脚本流水线
- [ ] 部署 FSR (Format Success Rate) 与 IEM (Intent Extraction Match) 评测脚本
- [ ] 完善 M4 Mac 上的 MLX/LoRA 自动化训练脚本
- [ ] 开发模型转 GGUF 格式及量化流水线

## 验收标准
- [ ] 训练后的 0.5B 模型 IEM 达到 95% 以上
- [ ] 数据合成流水线可一键生成 10k+ 高质量多轮对话数据")
echo "Created: $PHASE5_EPIC"

gh issue create --title "自动化运行数据合成脚本流水线" --label "enhancement, python" --body "基于业务场景，自动化运行大模型合成极端场景、多设备联动场景的高质量训练数据。属于 Epic: $PHASE5_EPIC"
gh issue create --title "部署 FSR 与 IEM 评测脚本" --label "enhancement, qa" --body "开发自动化测试脚本，计算 Format Success Rate (格式成功率) 和 Intent Extraction Match (意图提取匹配率)。属于 Epic: $PHASE5_EPIC"
gh issue create --title "完善 M4 Mac 上的 MLX/LoRA 自动化训练脚本" --label "enhancement, ai" --body "优化 \`run_train.sh\`，使其充分利用 Apple Silicon 的统一内存架构进行高效 LoRA 微调。属于 Epic: $PHASE5_EPIC"
gh issue create --title "开发模型转 GGUF 格式及量化流水线" --label "enhancement, ai" --body "将微调后的模型自动合并权重、转换为 GGUF 格式，并进行 q4_k_m 级别的量化，以供端侧使用。属于 Epic: $PHASE5_EPIC"

echo "✅ All Epics and Issues have been created! They should automatically appear in your GitHub Project Board."
