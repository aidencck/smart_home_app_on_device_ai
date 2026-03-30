#!/bin/bash

# ==============================================================================
# GitHub Issues Deduplication & Consolidation Script
# 视角：高级项目管理专家
# 作用：扫描远程仓库，识别由不同脚本产生的重复/高度相似的 Issues。
# 将它们合并为一个“主 Issue (Primary Issue)”，关闭多余的，并在主 Issue 中追加补充信息。
# ==============================================================================

# Ensure GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN environment variable is not set."
    exit 1
fi

REPO="aidencck/smart_home_app_on_device_ai"
API_URL="https://api.github.com/repos/$REPO/issues"
AUTH_HEADER="Authorization: Bearer $GITHUB_TOKEN"
ACCEPT_HEADER="Accept: application/vnd.github.v3+json"

echo "🔍 Fetching all open issues for deduplication analysis..."

# 获取所有打开的 Issues（限制前100个以作演示）
ISSUES_JSON=$(curl -s -H "$AUTH_HEADER" "$API_URL?state=open&per_page=100")

# --- 核心合并簇定义 ---
# 格式: 簇名称|正则表达式关键字
# 凡是标题命中同一正则的 Issue，将被视为同一簇
declare -a CLUSTERS=(
    "Llama_FFI_Engine|FFI.*Llama.cpp|Llama.cpp 引擎|0延迟本地推理"
    "GBNF_Generation|GBNF.*语法|确定性输出"
    "Data_Synthesis|数据合成"
    "Model_Finetuning|微调.*量化|GGUF.*转换"
    "Intent_Routing|三层意图|长尾对话.*降级|兜底路由"
    "Privacy_NER|合规.*授权|NER脱敏"
    "Model_OTA|OTA.*热更新|OTA模型.*下发"
    "Performance_Monitor|端侧 AI 性能监控|可用内存精准获取"
    "Local_RAG|Isar.*上下文|时序数据库画像"
)

# 辅助函数：关闭 Issue 并留言
close_issue_as_duplicate() {
    local duplicate_num=$1
    local primary_num=$2
    
    # 留言告知原因
    local comment_body="### 🔀 项目管理评审 (PM Review)
This issue has been identified as a duplicate or highly overlapping task. 
It has been merged into the primary tracking issue: #$primary_num.
Closing this to maintain a single source of truth (SSoT)."
    
    curl -s -X POST -H "$AUTH_HEADER" -H "$ACCEPT_HEADER" \
        "$API_URL/$duplicate_num/comments" \
        -d "$(jq -n --arg body "$comment_body" '{body: $body}')" > /dev/null

    # 关闭 Issue
    curl -s -X PATCH -H "$AUTH_HEADER" -H "$ACCEPT_HEADER" \
        "$API_URL/$duplicate_num" \
        -d '{"state": "closed", "state_reason": "not_planned"}' > /dev/null
        
    echo "  🔒 Closed #$duplicate_num as duplicate of #$primary_num"
}

# 辅助函数：更新主 Issue
update_primary_issue() {
    local primary_num=$1
    local extra_notes=$2
    
    local comment_body="### 📌 项目管理评审合并日志 (Consolidation Log)
Following a PM review, overlapping issues have been merged into this primary task. 
Please ensure the following contexts are also considered during development:

$extra_notes"

    curl -s -X POST -H "$AUTH_HEADER" -H "$ACCEPT_HEADER" \
        "$API_URL/$primary_num/comments" \
        -d "$(jq -n --arg body "$comment_body" '{body: $body}')" > /dev/null
        
    echo "  ✅ Updated Primary Issue #$primary_num with merged context."
}

echo "🚀 Starting deduplication process..."

for CLUSTER in "${CLUSTERS[@]}"; do
    IFS="|" read -r CLUSTER_NAME REGEX <<< "$CLUSTER"
    echo "------------------------------------------------------"
    echo "🎯 Analyzing Cluster: $CLUSTER_NAME"
    
    # 提取匹配当前正则的 Issue 编号和标题
    # 使用 jq 结合 bash 过滤
    MATCHED_ISSUES=$(echo "$ISSUES_JSON" | jq -c '.[] | select(.pull_request == null)')
    
    declare -a CLUSTER_IDS=()
    declare -a CLUSTER_TITLES=()
    
    while read -r issue; do
        TITLE=$(echo "$issue" | jq -r '.title')
        NUM=$(echo "$issue" | jq -r '.number')
        
        # Bash 正则匹配
        if [[ "$TITLE" =~ $REGEX ]]; then
            # 排除 Epic 宏观任务
            if [[ ! "$TITLE" =~ "\[EPIC\]" && ! "$TITLE" =~ "\[PRODUCT EPIC\]" ]]; then
                CLUSTER_IDS+=("$NUM")
                CLUSTER_TITLES+=("$TITLE")
            fi
        fi
    done <<< "$MATCHED_ISSUES"
    
    COUNT=${#CLUSTER_IDS[@]}
    
    if [ "$COUNT" -gt 1 ]; then
        echo "⚠️ Found $COUNT overlapping issues in this cluster."
        
        # 选定第一个作为 Primary (通常是数字最小的，创建最早的，或者可以加入逻辑选信息最全的)
        # 这里我们简单选第一个匹配到的作为 Primary
        PRIMARY_ID="${CLUSTER_IDS[0]}"
        echo "  👑 Designating #$PRIMARY_ID (${CLUSTER_TITLES[0]}) as Primary."
        
        EXTRA_CONTEXT=""
        
        # 遍历其余的 Issue，进行合并关闭
        for (( i=1; i<$COUNT; i++ )); do
            DUP_ID="${CLUSTER_IDS[$i]}"
            DUP_TITLE="${CLUSTER_TITLES[$i]}"
            
            EXTRA_CONTEXT+="- Merged requirement from #$DUP_ID: $DUP_TITLE\n"
            
            close_issue_as_duplicate "$DUP_ID" "$PRIMARY_ID"
        done
        
        # 更新 Primary Issue
        update_primary_issue "$PRIMARY_ID" "$EXTRA_CONTEXT"
        
    elif [ "$COUNT" -eq 1 ]; then
        echo "  ✔️ Only 1 issue found (#${CLUSTER_IDS[0]}). No duplication."
    else
        echo "  ⚪ No issues found for this cluster."
    fi

done

echo "🎉 Deduplication and consolidation complete!"
echo "Your project backlog is now clean and SSoT compliant."
