#!/bin/bash

# ==============================================================================
# GitHub Issues/Tasks Batch Creation Script - Project Management Edition
# 视角：项目管理专家
# 作用：将 WBS、技术依赖与验收标准转化为细粒度的研发任务，推送到远程仓库
# ==============================================================================

# Ensure GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN environment variable is not set."
    echo "Please set it before running the script:"
    echo "export GITHUB_TOKEN='your_personal_access_token_here'"
    exit 1
fi

# 尝试自动从 git remote 中提取 REPO_OWNER_AND_NAME
if [ -z "$REPO_OWNER_AND_NAME" ]; then
    # 获取 origin 的 URL
    REMOTE_URL=$(git config --get remote.origin.url || echo "")
    if [ -n "$REMOTE_URL" ]; then
        # 从 HTTPS 或 SSH 格式的 URL 中提取 owner/repo
        EXTRACTED=$(echo "$REMOTE_URL" | sed -E 's/.*github\.com[:\/](.*)\.git/\1/' | sed -E 's/.*github\.com[:\/](.*)/\1/')
        if [ -n "$EXTRACTED" ] && [ "$EXTRACTED" != "$REMOTE_URL" ]; then
            REPO_OWNER_AND_NAME="$EXTRACTED"
            echo "🔍 自动检测到仓库: $REPO_OWNER_AND_NAME"
        fi
    fi
fi

if [ -z "$REPO_OWNER_AND_NAME" ]; then
    echo "❌ 错误: 请设置 REPO_OWNER_AND_NAME 环境变量 (例如 'owner/repo')"
    exit 1
fi

REPO="$REPO_OWNER_AND_NAME"
API_URL="https://api.github.com/repos/$REPO/issues"

# Helper function to create an issue
create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"
    local milestone="$4"

    # Optional: If you have configured milestones in GitHub, you can add milestone handling here.
    # For now, we will include the Milestone info in the body text.

    local full_body="**📌 所属 Milestone**: $milestone\n\n$body"

    local json_payload=$(jq -n \
        --arg title "$title" \
        --arg body "$full_body" \
        --arg labels "$labels" \
        '{
            title: $title,
            body: $body,
            labels: ($labels | split(", ") | map(gsub("^ +| +$"; "")))
        }')

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

echo "🚀 Creating Technical & Management Tasks for Smart Home Project..."

# ==========================================
# Track 1: 基础设施与端侧架构底座
# ==========================================
echo "📦 Creating Track 1 Tasks (Architecture)..."

BODY_1_1="## 📝 任务描述
在 Flutter 侧通过 Dart FFI 深度封装 Llama.cpp 引擎，并利用 Isolate 实现完全隔离的异步计算，确保模型推理过程中主线程不卡顿。

## 🔗 依赖关系
- 前置依赖：无
- 阻塞后续任务：GBNF 注入、RAG 集成

## ✅ 验收标准 (DoD)
- [ ] 成功加载 GGUF 格式模型并在设备上运行。
- [ ] 推理期间 UI 帧率保持在 60fps。
- [ ] 首字响应时间 (TTFT) < 300ms。"
create_issue "[Task] 基于 Dart FFI 的多线程 Llama.cpp 引擎封装" "$BODY_1_1" "architecture, enhancement, high-priority" "M1: MVP Core Intelligence" > /dev/null

BODY_1_2="## 📝 任务描述
根据 \`lib/models/device.dart\` 中定义的设备协议，开发动态 GBNF 语法生成器。在模型推理时强制注入该语法树，消除模型输出格式幻觉。

## 🔗 依赖关系
- 前置依赖：[Task] 基于 Dart FFI 的多线程 Llama.cpp 引擎封装
- 数据依赖：设备控制 JSON Schema

## ✅ 验收标准 (DoD)
- [ ] 无论输入何种提示词，模型输出必须是 100% 合法的 JSON。
- [ ] 若解析失败，系统不能崩溃，需触发安全降级。"
create_issue "[Task] 开发动态 GBNF 语法树生成器实现确定性控制" "$BODY_1_2" "architecture, logic" "M1: MVP Core Intelligence" > /dev/null

BODY_1_3="## 📝 任务描述
构建本地规则(L1)、端侧模型(L2)与云端兜底(L3)的分流网关。开发一个轻量级意图分类器，识别超出端侧能力的指令（如查天气、复杂闲聊）并隐式转发给云端 FastAPI。

## 🔗 依赖关系
- 前置依赖：FastAPI 基础架构就绪

## ✅ 验收标准 (DoD)
- [ ] 分流决策耗时 < 50ms。
- [ ] 切换至云端兜底时，用户侧无报错感知。"
create_issue "[Task] 开发三层意图路由分发网关" "$BODY_1_3" "architecture, edge-cloud" "M2: Context & Edge-Cloud" > /dev/null


# ==========================================
# Track 2: 模型定制与数据工程管线
# ==========================================
echo "📦 Creating Track 2 Tasks (Model Forge)..."

BODY_2_1="## 📝 任务描述
建立自动化的数据合成脚本（利用 GPT-4 或 Claude API），根据业务定义的场景（正常指令、多设备联动、拒绝域）生成符合 ShareGPT 格式的 SFT 训练数据。

## 🔗 依赖关系
- 协议依赖：设备功能枚举完整

## ✅ 验收标准 (DoD)
- [ ] 脚本可一键生成不少于 5000 条高质量多样化语料。
- [ ] 语料中包含不少于 20% 的拒绝指令（Out-of-Domain）样本。"
create_issue "[Task] 构建 SmartHome 领域自动化数据合成流水线" "$BODY_2_1" "model-forge, data-pipeline" "M1: MVP Core Intelligence" > /dev/null

BODY_2_2="## 📝 任务描述
完善 \`model_forge\` 目录下的模型迭代脚本。包含基于 QLoRA 的轻量级微调，以及转换为 GGUF 格式并执行 Q4_K_M 极致量化的完整闭环。

## 🔗 依赖关系
- 前置依赖：[Task] 构建 SmartHome 领域自动化数据合成流水线

## ✅ 验收标准 (DoD)
- [ ] 脚本能在 Mac M2/M4 或单张 RTX 4090 上稳定运行。
- [ ] 微调后的 1.5B 模型，在业务测试集上的指令意图抽取准确率 > 95%。"
create_issue "[Task] 完善模型 QLoRA 微调与 GGUF 量化全自动脚本" "$BODY_2_2" "model-forge, automation" "M2: Context & Edge-Cloud" > /dev/null

BODY_2_3="## 📝 任务描述
搭建轻量级的云端模型分发中心 (Model Registry)。端侧应用启动时，检查当前 App Version Code 与硬件可用 RAM，动态下载并热替换匹配的 GGUF 模型文件。

## 🔗 依赖关系
- 约束依赖：必须强校验 App Version Code，防止 FFI 接口不兼容导致崩溃。

## ✅ 验收标准 (DoD)
- [ ] 支持大文件断点续传与 MD5 一致性校验。
- [ ] 硬件探针识别到低内存设备（如可用 RAM < 2GB）时，自动中止下载并切换纯云端模式。"
create_issue "[Task] 开发基于 Version Code 和算力探针的模型 OTA 热更新服务" "$BODY_2_3" "architecture, infrastructure" "M3: Proactive & Flywheel" > /dev/null


# ==========================================
# Track 4: 数据飞轮与质量保证 (QA)
# ==========================================
echo "📦 Creating Track 4 Tasks (Data Flywheel & QA)..."

BODY_4_1="## 📝 任务描述
在合规要求下，开发 App 端的显性授权弹窗 (Opt-in UI)。同时在 Flutter 端集成轻量级 NER 模型，在用户日志上传云端前，将姓名、住址等敏感信息 (PII) 替换为占位符。

## 🔗 依赖关系
- 阻塞业务：这是所有数据回收与飞轮业务的绝对前置条件，合规第一。

## ✅ 验收标准 (DoD)
- [ ] 授权选项不可默认勾选，需有明确的隐私政策链接。
- [ ] 脱敏引擎对常见姓名/地点的拦截率 > 99%。"
create_issue "[Task] 建立合规授权墙与端侧前置 NER 脱敏引擎" "$BODY_4_1" "privacy, security, legal" "M3: Proactive & Flywheel" > /dev/null

BODY_4_2="## 📝 任务描述
开发一系列端侧性能压测探针，监控端到端耗时、TTFT 耗时，并在出现 OOM (Out of Memory) 边缘或高温降频时，触发告警日志和优雅降级策略。

## 🔗 依赖关系
- 前置依赖：端侧引擎与路由网关均已就绪。

## ✅ 验收标准 (DoD)
- [ ] 能够准确捕获内存峰值。
- [ ] 系统 OOM 崩溃率控制在 0，能够在触发系统级杀进程前主动释放 Llama 实例并走云端兜底。"
create_issue "[Task] 开发端侧 AI 性能监控与自动降级探针" "$BODY_4_2" "qa, performance, monitoring" "M3: Proactive & Flywheel" > /dev/null

echo "🎉 All Project Management Tasks have been created successfully!"
echo "Execute this script to populate your GitHub/Jira backlog with detailed engineering tasks."
