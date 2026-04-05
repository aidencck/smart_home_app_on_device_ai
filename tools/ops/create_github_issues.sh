#!/bin/bash

# ==============================================================================
# GitHub Issues Batch Creation Script (Using standard curl)
# ==============================================================================

# Ensure GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN environment variable is not set."
    echo "Please set it before running the script:"
    echo "export GITHUB_TOKEN='your_personal_access_token_here'"
    exit 1
fi

REPO="aidencck/smart_home_app_on_device_ai"
API_URL="https://api.github.com/repos/$REPO/issues"

# Helper function to create an issue using curl and return its HTML URL
create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"

    # Use jq to properly escape the JSON payload to avoid quote hell
    local json_payload=$(jq -n \
        --arg title "$title" \
        --arg body "$body" \
        --arg labels "$labels" \
        '{
            title: $title,
            body: $body,
            labels: ($labels | split(", ") | map(gsub("^ +| +$"; "")))
        }')

    # Send POST request and extract html_url
    local response=$(curl -s -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token $GITHUB_TOKEN" \
        "$API_URL" \
        -d "$json_payload")

    local issue_url=$(echo "$response" | grep -o '"html_url": "[^"]*' | head -n 1 | cut -d'"' -f4)
    
    if [ -z "$issue_url" ]; then
        echo "❌ Failed to create issue: $title"
        echo "$response"
    else
        echo "$issue_url"
    fi
}

echo "🚀 Creating Epics and Issues for Smart Home On-Device AI Project..."

# --- Phase 1: FastAPI 端云协同底座搭建 ---
echo "📦 Creating Phase 1 Epic..."
BODY_1="## 🎯 Epic 概述
构建高可用、防并发竞态的云端微服务，作为端侧 Agent 的坚实后盾。

## 📋 包含的子任务
- [ ] 初始化 FastAPI 后端脚手架
- [ ] 基于 Redis Cluster 重构设备影子
- [ ] Flutter 端 Command ID 拦截器
- [ ] 安防高危设备 0s TTL MQTT 探针

## 验收标准
- [ ] 所有的子任务均已关闭
- [ ] 测试覆盖率达到要求
- [ ] 相关文档已更新至 Wiki"

PHASE1_EPIC=$(create_issue "[EPIC] Phase 1: FastAPI 端云协同底座搭建" "$BODY_1" "epic, roadmap")
echo "✅ Created: $PHASE1_EPIC"

create_issue "初始化 FastAPI 后端脚手架 (Pydantic v2 & JWT)" "包含 Pydantic v2 全局校验与 JWT 鉴权中间件。属于 Epic: $PHASE1_EPIC" "enhancement, good first issue" > /dev/null
create_issue "基于 Redis Cluster 重构设备影子 (Vector Clock 机制)" "基于 Redis Cluster 实现状态增量更新，引入 Vector Clock 时间戳校验机制。属于 Epic: $PHASE1_EPIC" "enhancement" > /dev/null
create_issue "Flutter 端 Command ID 拦截器 (防幽灵播报)" "在 Flutter 端实现 Command ID 拦截器，解决云端异步返回较慢导致的“幽灵播报”。属于 Epic: $PHASE1_EPIC" "bug, enhancement" > /dev/null
create_issue "安防高危设备 0s TTL MQTT 探针" "针对安防设备开发主动拉取状态的 MQTT 极速通道。属于 Epic: $PHASE1_EPIC" "enhancement" > /dev/null

# --- Phase 2: 隐私合规与大模型路由 ---
echo "📦 Creating Phase 2 Epic..."
BODY_2="## 🎯 Epic 概述
建立严格的数据脱敏管道与意图分发网络。

## 📋 包含的子任务
- [ ] 端侧轻量级 NER 前置脱敏引擎
- [ ] App 端合规授权墙 (Opt-in UI) 开发
- [ ] FastAPI 路由层 Semantic Cache
- [ ] vLLM 与商业 API 的 Structured Outputs 对齐

## 验收标准
- [ ] 所有的子任务均已关闭
- [ ] 测试覆盖率达到要求"

PHASE2_EPIC=$(create_issue "[EPIC] Phase 2: 隐私合规与大模型路由" "$BODY_2" "epic, roadmap")
echo "✅ Created: $PHASE2_EPIC"

create_issue "端侧轻量级 NER 前置脱敏引擎" "在 Flutter 端接入轻量级 NER 引擎，上云前剥离姓名、地址等个人标识符 (PII)。属于 Epic: $PHASE2_EPIC" "enhancement" > /dev/null
create_issue "App 端合规授权墙 (Opt-in UI) 开发" "App 端开发极显眼的“体验改善计划”授权弹窗（非默认勾选），控制日志上传阀门。属于 Epic: $PHASE2_EPIC" "enhancement, good first issue" > /dev/null
create_issue "FastAPI 路由层 Semantic Cache (Redis/Milvus)" "在 FastAPI 路由层接入 Redis/Milvus，拦截高频通用指令以降低大模型冷启动延迟。属于 Epic: $PHASE2_EPIC" "enhancement" > /dev/null
create_issue "vLLM 与商业 API 的 Structured Outputs 对齐" "确保 vLLM 开启 \`--guided-decoding-backend\`，商业 API 启用 Structured Outputs。属于 Epic: $PHASE2_EPIC" "enhancement" > /dev/null

# --- Phase 3: 数据飞轮与模型演进 ---
echo "📦 Creating Phase 3 Epic..."
BODY_3="## 🎯 Epic 概述
打造可持续进化的“主动智能”模型底座。

## 📋 包含的子任务
- [ ] LLM-as-a-Judge 脱敏日志二次清洗流水线
- [ ] 端侧意图解耦 (Intent Splitting) 与并行调度器
- [ ] 基于 Version Code 的 OTA 模型动态下发策略
- [ ] (预研) 端侧微调与联邦学习架构探索

## 验收标准
- [ ] 所有的子任务均已关闭"

PHASE3_EPIC=$(create_issue "[EPIC] Phase 3: 数据飞轮与模型演进" "$BODY_3" "epic, roadmap")
echo "✅ Created: $PHASE3_EPIC"

create_issue "LLM-as-a-Judge 脱敏日志二次清洗流水线 (Celery)" "开发 Celery Worker 消费脱敏日志，通过大模型进行二次隐私审查与质量打分。属于 Epic: $PHASE3_EPIC" "enhancement" > /dev/null
create_issue "端侧意图解耦 (Intent Splitting) 与并行调度器" "开发轻量级分类器，实现本地控制与云端长尾对话的并行调度。属于 Epic: $PHASE3_EPIC" "enhancement" > /dev/null
create_issue "基于 Version Code 的 OTA 模型动态下发策略" "开发基于 App Version Code 的模型强校验下发服务，杜绝跨版本模型导致推理 Crash。属于 Epic: $PHASE3_EPIC" "enhancement" > /dev/null
create_issue "(预研) 端侧微调与联邦学习架构探索" "探索将微调任务下发至端侧计算梯度的技术路径。属于 Epic: $PHASE3_EPIC" "documentation, enhancement" > /dev/null

# --- Phase 4: 端侧核心推理与 RAG 优化 ---
echo "📦 Creating Phase 4 Epic..."
BODY_4="## 🎯 Epic 概述
根据 \`honest_architecture_reflection.md\`，深度优化 Flutter 端的 Llama.cpp 引擎调用机制、GGUF 模型约束采样以及本地 Isar RAG 检索流程，确保端侧 0 延迟、0 幻觉控制。

## 📋 包含的子任务
- [ ] 优化 Dart FFI 到 Llama.cpp 的多线程调用策略
- [ ] 引入 GBNF 语法树进行 100% 格式约束采样
- [ ] 优化基于 Isar 的本地向量数据库相似度计算
- [ ] 开发长尾对话的降级云端路由中间件

## 验收标准
- [ ] 端侧硬件控制指令响应时间 < 300ms
- [ ] 控制指令 JSON 格式正确率达到 100% (通过 GBNF)"

PHASE4_EPIC=$(create_issue "[EPIC] Phase 4: 端侧推理引擎与本地 RAG 深度优化" "$BODY_4" "epic, roadmap")
echo "✅ Created: $PHASE4_EPIC"

create_issue "优化 Dart FFI 到 Llama.cpp 的多线程调用策略" "解决当前 Flutter 隔离区 (Isolate) 与 C++ 推理引擎之间的数据拷贝开销，提升 token 生成速度。属于 Epic: $PHASE4_EPIC" "enhancement" > /dev/null
create_issue "引入 GBNF 语法树进行 100% 格式约束采样" "在端侧模型推理时，强制注入基于设备影子 Schema 的 GBNF 语法树，杜绝 AI 幻觉生成无效 JSON。属于 Epic: $PHASE4_EPIC" "enhancement" > /dev/null
create_issue "优化基于 Isar 的本地向量数据库相似度计算" "提升端侧 RAG (Retrieval-Augmented Generation) 检索本地设备状态和环境上下文的速度。属于 Epic: $PHASE4_EPIC" "enhancement" > /dev/null
create_issue "开发长尾对话的降级云端路由中间件" "当用户指令超出本地小模型能力（如：'讲个笑话'）时，无缝且隐式地将请求路由至云端 vLLM 处理。属于 Epic: $PHASE4_EPIC" "enhancement" > /dev/null

# --- Phase 5: 数据合成与模型评估体系 ---
echo "📦 Creating Phase 5 Epic..."
BODY_5="## 🎯 Epic 概述
根据 \`model_forge/data_evaluation_and_synthesis_rules.md\` 和验收框架，搭建端侧模型自动化微调与多维度的指标评测体系。

## 📋 包含的子任务
- [ ] 自动化运行数据合成脚本流水线
- [ ] 部署 FSR (Format Success Rate) 与 IEM (Intent Extraction Match) 评测脚本
- [ ] 完善 M4 Mac 上的 MLX/LoRA 自动化训练脚本
- [ ] 开发模型转 GGUF 格式及量化流水线

## 验收标准
- [ ] 训练后的 0.5B 模型 IEM 达到 95% 以上
- [ ] 数据合成流水线可一键生成 10k+ 高质量多轮对话数据"

PHASE5_EPIC=$(create_issue "[EPIC] Phase 5: Model Forge 数据合成与模型评估体系建设" "$BODY_5" "epic, roadmap")
echo "✅ Created: $PHASE5_EPIC"

create_issue "自动化运行数据合成脚本流水线" "基于业务场景，自动化运行大模型合成极端场景、多设备联动场景的高质量训练数据。属于 Epic: $PHASE5_EPIC" "enhancement" > /dev/null
create_issue "部署 FSR 与 IEM 评测脚本" "开发自动化测试脚本，计算 Format Success Rate (格式成功率) 和 Intent Extraction Match (意图提取匹配率)。属于 Epic: $PHASE5_EPIC" "enhancement" > /dev/null
create_issue "完善 M4 Mac 上的 MLX/LoRA 自动化训练脚本" "优化 \`run_train.sh\`，使其充分利用 Apple Silicon 的统一内存架构进行高效 LoRA 微调。属于 Epic: $PHASE5_EPIC" "enhancement" > /dev/null
create_issue "开发模型转 GGUF 格式及量化流水线" "将微调后的模型自动合并权重、转换为 GGUF 格式，并进行 q4_k_m 级别的量化，以供端侧使用。属于 Epic: $PHASE5_EPIC" "enhancement" > /dev/null

# --- Phase 6: 代码库技术债清理与基础设施完善 ---
echo "📦 Creating Phase 6 Epic..."
BODY_6="## 🎯 Epic 概述
在核心代码库扫描中发现的遗留 TODOs 和未完全实现的模块闭环，主要集中在端侧引擎的降级处理和设备状态映射上。

## 📋 包含的子任务
- [ ] 完善 Llama.cpp Isolate 通信层中的流式 token callback 映射
- [ ] 补全端侧硬件探针降级时的可用内存精准获取逻辑
- [ ] 移除或修复 \`llama.cpp/src\` 中未解决的 C++ 内存泄漏 TODOs

## 验收标准
- [ ] \`llama_engine.dart\` 中的 \`TODO\` 和 \`print\` 调试语句被全部清理
- [ ] 异常情况下的兜底云端策略能够稳定触发"

PHASE6_EPIC=$(create_issue "[EPIC] Phase 6: 代码库技术债清理与基础设施完善" "$BODY_6" "epic, tech-debt")
echo "✅ Created: $PHASE6_EPIC"

create_issue "完善 Llama.cpp Isolate 通信层中的流式 token callback 映射" "在 \`packages/on_device_agent/lib/src/engine/llama_cpp/llama_engine.dart\` 中，真正的 Llama.cpp 支持 token by token 的流式回调。目前只是在模拟，需要将 C++ callback 通过 SendPort 实时传递给主线程以降低 TTFT。属于 Epic: $PHASE6_EPIC" "bug, enhancement" > /dev/null
create_issue "补全端侧硬件探针降级时的可用内存精准获取逻辑" "在 \`llama_engine.dart\` 的内存探针中，目前只写了简单的模拟阈值判断。需要接入 \`system_info\` 等插件，精准获取设备当前可用 RAM，并在不足时平滑降级到云端模型。属于 Epic: $PHASE6_EPIC" "enhancement" > /dev/null

echo "🎉 All Epics and Issues have been created via curl!"
echo "They will automatically appear in your GitHub Project Board thanks to the GitHub Actions workflow."
