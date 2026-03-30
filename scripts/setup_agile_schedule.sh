#!/bin/bash

# ==============================================================================
# GitHub Agile Schedule Setup Script (Sprint & Milestone Manager)
# 视角：高级项目管理专家
# 作用：在远程仓库中自动创建 Milestone（对应 Sprint），并创建带排期的关联 Issue。
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

# 仓库配置
REPO="$REPO_OWNER_AND_NAME"
API_URL="https://api.github.com/repos/$REPO"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
ACCEPT_HEADER="Accept: application/vnd.github.v3+json"

# ==========================================
# Function: Create Milestone
# Returns: Milestone Number (ID)
# ==========================================
create_milestone() {
    local title="$1"
    local description="$2"
    local due_on="$3"

    local json_payload=$(jq -n \
        --arg title "$title" \
        --arg description "$description" \
        --arg due_on "$due_on" \
        '{
            title: $title,
            description: $description,
            due_on: $due_on
        }')

    local response=$(curl -s -X POST \
        -H "$ACCEPT_HEADER" \
        -H "$AUTH_HEADER" \
        "$API_URL/milestones" \
        -d "$json_payload")

    # Extract the milestone number
    local milestone_number=$(echo "$response" | jq -r '.number')
    
    if [ "$milestone_number" == "null" ] || [ -z "$milestone_number" ]; then
        echo "❌ Failed to create milestone: $title"
        echo "$response"
        return 1
    else
        echo "$milestone_number"
    fi
}

# ==========================================
# Function: Create Issue Linked to Milestone
# ==========================================
create_issue_with_milestone() {
    local title="$1"
    local body="$2"
    local labels="$3"
    local milestone_number="$4"

    local json_payload=$(jq -n \
        --arg title "$title" \
        --arg body "$body" \
        --arg labels "$labels" \
        --argjson milestone "$milestone_number" \
        '{
            title: $title,
            body: $body,
            labels: ($labels | split(", ") | map(gsub("^ +| +$"; ""))),
            milestone: $milestone
        }')

    local response=$(curl -s -X POST \
        -H "$ACCEPT_HEADER" \
        -H "$AUTH_HEADER" \
        "$API_URL/issues" \
        -d "$json_payload")

    local issue_url=$(echo "$response" | jq -r '.html_url')
    
    if [ "$issue_url" == "null" ] || [ -z "$issue_url" ]; then
        echo "❌ Failed to create issue: $title"
        echo "$response"
    else
        echo "✅ Created Issue: $issue_url (Milestone: $milestone_number)"
    fi
}

echo "🚀 Setting up Agile Milestones and Scheduled Tasks for Smart Home Project..."

# ==========================================
# Phase 1: Create Milestones (Sprints)
# We set due dates relative to today
# ==========================================
echo "📅 Creating Milestones..."

# M1: 2 weeks from now
M1_DATE=$(date -v+14d +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -d "+14 days" +"%Y-%m-%dT%H:%M:%SZ")
M1_ID=$(create_milestone "Sprint 1: 核心智能底座 (M1)" "目标：跑通端侧大模型从加载、推见到结构化输出的链路。交付：0.5B模型加载，合法JSON输出，UI不卡顿。" "$M1_DATE")
echo "✅ Sprint 1 Milestone ID: $M1_ID (Due: $M1_DATE)"

# M2: 4 weeks from now
M2_DATE=$(date -v+28d +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -d "+28 days" +"%Y-%m-%dT%H:%M:%SZ")
M2_ID=$(create_milestone "Sprint 2: 场景感知与端云协同 (M2)" "目标：引入本地记忆与复杂指令的平滑降级，建立初版 Zero-UI。交付：Isar RAG，三层意图网关，基础物理UI。" "$M2_DATE")
echo "✅ Sprint 2 Milestone ID: $M2_ID (Due: $M2_DATE)"

# M3: 6 weeks from now
M3_DATE=$(date -v+42d +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -d "+42 days" +"%Y-%m-%dT%H:%M:%SZ")
M3_ID=$(create_milestone "Sprint 3: 主动智能与飞轮闭环 (M3)" "目标：建立数据安全回收通道与端侧性能防线。交付：合规授权，NER脱敏，模型OTA更新。" "$M3_DATE")
echo "✅ Sprint 3 Milestone ID: $M3_ID (Due: $M3_DATE)"


# ==========================================
# Phase 2: Create Scheduled Tasks (Issues)
# ==========================================
echo "📦 Distributing Tasks to Sprints..."

if [ -n "$M1_ID" ]; then
    echo "--- Populating Sprint 1 ---"
    create_issue_with_milestone "[Client Arch] 基于 Dart FFI 封装 Llama.cpp 引擎，建立 Isolate 隔离池" "## 排期与资源\n- **负责人**: Client Arch 组\n- **优先级**: Highest\n\n## 验收标准\n- [ ] 成功加载 GGUF 格式模型并在设备上运行。\n- [ ] 推理期间 UI 帧率保持在 60fps。\n- [ ] 首字响应时间 (TTFT) < 300ms。" "architecture, enhancement" "$M1_ID"
    
    create_issue_with_milestone "[Client Arch] 开发动态 GBNF 语法树生成器实现确定性控制" "## 排期与资源\n- **负责人**: Client Arch 组\n- **依赖**: 必须先完成 Llama.cpp FFI 封装与 \`device.dart\` 协议定稿。\n\n## 验收标准\n- [ ] 模型输出必须是 100% 合法的 JSON。" "architecture, logic" "$M1_ID"

    create_issue_with_milestone "[AI & Data] 构建 SmartHome 领域自动化数据合成流水线" "## 排期与资源\n- **负责人**: AI & Data 组\n- **优先级**: High\n\n## 验收标准\n- [ ] 脚本可一键生成不少于 5000 条高质量多样化语料。" "model-forge, data-pipeline" "$M1_ID"
fi

if [ -n "$M2_ID" ]; then
    echo "--- Populating Sprint 2 ---"
    create_issue_with_milestone "[Client Arch] 集成 Isar 数据库，打通本地 BehaviorLog RAG 上下文注入" "## 排期与资源\n- **负责人**: Client Arch 组\n- **优先级**: High\n\n## 验收标准\n- [ ] 结合本地温湿度状态准确输出指令。" "architecture, enhancement" "$M2_ID"

    create_issue_with_milestone "[QA/DevOps] 开发三层意图路由分发网关 (本地/端侧/云端)" "## 排期与资源\n- **负责人**: QA/DevOps 组\n\n## 验收标准\n- [ ] 长尾闲聊无缝隐式切换至云端兜底。" "architecture, edge-cloud" "$M2_ID"
    
    create_issue_with_milestone "[AI & Data] 完善模型 QLoRA 微调与 GGUF 量化全自动脚本" "## 排期与资源\n- **负责人**: AI & Data 组\n\n## 验收标准\n- [ ] 微调后的 1.5B 模型，指令意图抽取准确率 > 95%。" "model-forge, automation" "$M2_ID"
fi

if [ -n "$M3_ID" ]; then
    echo "--- Populating Sprint 3 ---"
    create_issue_with_milestone "[AI & Data] 建立合规授权墙(Opt-in)与端侧前置 NER 脱敏引擎" "## 排期与资源\n- **负责人**: AI & Data 组\n- **优先级**: Highest (法务合规阻点)\n\n## 验收标准\n- [ ] 脱敏引擎对常见姓名/地点的拦截率 > 99%。" "privacy, security, legal" "$M3_ID"

    create_issue_with_milestone "[QA/DevOps] 开发基于 Version Code 和算力探针的模型 OTA 热更新服务" "## 排期与资源\n- **负责人**: QA/DevOps 组\n\n## 验收标准\n- [ ] 支持大文件断点续传。\n- [ ] 硬件探针识别到低内存设备（如 RAM < 2GB）时，自动中止并切换纯云端。" "architecture, infrastructure" "$M3_ID"

    create_issue_with_milestone "[QA/DevOps] 开发端侧 AI 性能监控探针 (OOM与降级)" "## 排期与资源\n- **负责人**: QA/DevOps 组\n\n## 验收标准\n- [ ] OOM 崩溃率控制在 0。" "qa, performance, monitoring" "$M3_ID"
fi

echo "🎉 Schedule Setup Complete!"
echo "All Tasks have been assigned to their respective Sprints (Milestones)."
