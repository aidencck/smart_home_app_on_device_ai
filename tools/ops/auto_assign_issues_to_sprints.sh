#!/bin/bash

# ==============================================================================
# GitHub Issues Sprint (Milestone) Auto-Assignment Script
# 视角：高级项目管理专家
# 作用：根据 Issue 的标题关键字，自动将其分配到对应的 Sprint 里程碑 (Milestone) 中。
# ==============================================================================

# Ensure GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN environment variable is not set."
    echo "Please set it before running the script:"
    echo "export GITHUB_TOKEN='your_personal_access_token_here'"
    exit 1
fi

REPO="aidencck/smart_home_app_on_device_ai"
API_URL="https://api.github.com/repos/$REPO"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
ACCEPT_HEADER="Accept: application/vnd.github.v3+json"

# --- Step 1: 获取所有的 Milestone 并提取其 Number ---
echo "🔍 Fetching Milestones..."
MILESTONES_JSON=$(curl -s -H "$AUTH_HEADER" "$API_URL/milestones?state=open")

M1_NUM=$(echo "$MILESTONES_JSON" | jq -r '.[] | select(.title | contains("Sprint 1")) | .number')
M2_NUM=$(echo "$MILESTONES_JSON" | jq -r '.[] | select(.title | contains("Sprint 2")) | .number')
M3_NUM=$(echo "$MILESTONES_JSON" | jq -r '.[] | select(.title | contains("Sprint 3")) | .number')

if [ -z "$M1_NUM" ] || [ -z "$M2_NUM" ] || [ -z "$M3_NUM" ]; then
    echo "❌ Could not find all Sprint Milestones. Please run setup_agile_schedule.sh first."
    exit 1
fi

echo "✅ Milestone Numbers Found: Sprint 1 (#$M1_NUM), Sprint 2 (#$M2_NUM), Sprint 3 (#$M3_NUM)"

# --- Step 2: 获取所有的 Open Issues ---
echo "🔍 Fetching Open Issues..."
ISSUES_JSON=$(curl -s -H "$AUTH_HEADER" "$API_URL/issues?state=open&per_page=100")

# --- Step 3: 循环处理每个 Issue 并根据关键字分配 ---
echo "🚀 Analyzing and Assigning Issues to Sprints..."

echo "$ISSUES_JSON" | jq -c '.[]' | while read -r issue; do
    ISSUE_NUM=$(echo "$issue" | jq -r '.number')
    ISSUE_TITLE=$(echo "$issue" | jq -r '.title')
    
    # 已经有里程碑的跳过 (可选，为了重新排期可以不跳过)
    # CURRENT_MILESTONE=$(echo "$issue" | jq -r '.milestone.number')
    # if [ "$CURRENT_MILESTONE" != "null" ]; then continue; fi

    TARGET_MILESTONE=""

    # --- 分类逻辑 (基于高级项目管理专家分析的 WBS) ---
    
    # Sprint 1 关键字：基础设施、M1、底层、FFI、GBNF、FastAPI 初始、数据合成
    if [[ "$ISSUE_TITLE" =~ "FFI" || "$ISSUE_TITLE" =~ "GBNF" || "$ISSUE_TITLE" =~ "M1" || "$ISSUE_TITLE" =~ "Llama.cpp" || "$ISSUE_TITLE" =~ "FastAPI 后端脚手架" || "$ISSUE_TITLE" =~ "Redis Cluster" || "$ISSUE_TITLE" =~ "数据合成" || "$ISSUE_TITLE" =~ "0 延迟" || "$ISSUE_TITLE" =~ "强一致性" ]]; then
        TARGET_MILESTONE=$M1_NUM
    
    # Sprint 3 关键字：隐私、合规、脱敏、NER、授权、M3、主动、预判、场景执行、飞轮、OTA、监控、降级
    elif [[ "$ISSUE_TITLE" =~ "隐私" || "$ISSUE_TITLE" =~ "合规" || "$ISSUE_TITLE" =~ "脱敏" || "$ISSUE_TITLE" =~ "NER" || "$ISSUE_TITLE" =~ "M3" || "$ISSUE_TITLE" =~ "授权" || "$ISSUE_TITLE" =~ "主动" || "$ISSUE_TITLE" =~ "预判" || "$ISSUE_TITLE" =~ "动态感知" || "$ISSUE_TITLE" =~ "飞轮" || "$ISSUE_TITLE" =~ "OTA" || "$ISSUE_TITLE" =~ "监控" || "$ISSUE_TITLE" =~ "降级" || "$ISSUE_TITLE" =~ "习惯学习" ]]; then
        TARGET_MILESTONE=$M3_NUM
    
    # Sprint 2 关键字：交互、M2、手势、3D、Shader、Semantic Cache、意图路由、微调脚本、量化流水线、RAG 检索、自然语言创建
    elif [[ "$ISSUE_TITLE" =~ "交互" || "$ISSUE_TITLE" =~ "M2" || "$ISSUE_TITLE" =~ "手势" || "$ISSUE_TITLE" =~ "3D" || "$ISSUE_TITLE" =~ "Shader" || "$ISSUE_TITLE" =~ "Semantic Cache" || "$ISSUE_TITLE" =~ "意图路由" || "$ISSUE_TITLE" =~ "微调脚本" || "$ISSUE_TITLE" =~ "量化流水线" || "$ISSUE_TITLE" =~ "RAG" || "$ISSUE_TITLE" =~ "自然语言" || "$ISSUE_TITLE" =~ "降级云端" ]]; then
        TARGET_MILESTONE=$M2_NUM
    
    # 默认兜底：如果没有匹配，根据其在脚本中出现的顺序进行模糊分配，或保留原样
    else
        # 排除掉 Epic 标题，Epic 通常跨 Sprint
        if [[ ! "$ISSUE_TITLE" =~ "[EPIC]" ]]; then
             # 默认分配到 Sprint 2 (开发高峰)
             TARGET_MILESTONE=$M2_NUM
        fi
    fi

    # --- 执行更新 ---
    if [ -n "$TARGET_MILESTONE" ]; then
        echo "Updating Issue #$ISSUE_NUM: '$ISSUE_TITLE' -> Sprint Milestone #$TARGET_MILESTONE"
        curl -s -X PATCH \
            -H "$AUTH_HEADER" \
            -H "$ACCEPT_HEADER" \
            "$API_URL/issues/$ISSUE_NUM" \
            -d "{\"milestone\": $TARGET_MILESTONE}" > /dev/null
    fi
done

echo "🎉 All Open Issues have been analyzed and assigned to corresponding Sprints!"
