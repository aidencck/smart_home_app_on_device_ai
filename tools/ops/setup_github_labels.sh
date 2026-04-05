#!/bin/bash

# setup_github_labels.sh
# 此脚本用于初始化和规范化 GitHub 仓库的 Issue/PR 标签体系
# 依赖: curl, jq, 并在环境变量中设置 GITHUB_TOKEN 和 REPO_OWNER_AND_NAME (例如 "your-org/smart_home_app")

set -e

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ 错误: 请设置 GITHUB_TOKEN 环境变量"
    echo "示例: export GITHUB_TOKEN='your_personal_access_token'"
    exit 1
fi

if [ -z "$REPO_OWNER_AND_NAME" ]; then
    echo "❌ 错误: 请设置 REPO_OWNER_AND_NAME 环境变量 (例如 'owner/repo')"
    exit 1
fi

API_URL="https://api.github.com/repos/$REPO_OWNER_AND_NAME/labels"

# 定义标签数组: "名称|颜色|描述"
# 颜色不带 '#'
LABELS=(
    # 优先级
    "priority: high|d93f0b|High priority task or bug"
    "priority: medium|fbca04|Medium priority"
    "priority: low|0e8a16|Low priority"
    
    # 任务类型
    "type: bug|d73a4a|Something isn't working"
    "type: feature|a2eeef|New feature or request"
    "type: enhancement|84b6eb|Improvement to existing feature"
    "type: documentation|0075ca|Improvements or additions to documentation"
    "type: refactor|e99695|Code refactoring without changing behavior"
    "type: test|5319e7|Adding or fixing tests"
    
    # 模块/领域
    "module: flutter|1d76db|Flutter mobile app related"
    "module: ai-engine|7057ff|On-device LLM / AI engine related"
    "module: devops|006b75|CI/CD, scripts, and repository management"
    "module: backend|c2e0c6|Cloud/FastAPI backend related"
    
    # 状态
    "status: blocked|b60205|Blocked by another task or dependency"
    "status: in-progress|fbca04|Currently being worked on"
    "status: review-needed|fef2c0|Needs code review or QA"
    "status: stale|ffffff|No activity for a long time"
)

echo "🚀 开始初始化 GitHub 标签体系: $REPO_OWNER_AND_NAME"

for LABEL_INFO in "${LABELS[@]}"; do
    IFS="|" read -r NAME COLOR DESCRIPTION <<< "$LABEL_INFO"
    
    echo "------------------------------------------------------"
    echo "🏷️ 处理标签: $NAME"
    
    # 检查标签是否存在
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "$API_URL/$NAME")
        
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "🔄 标签已存在，正在更新..."
        curl -s -X PATCH \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            -d "{\"new_name\":\"$NAME\", \"color\":\"$COLOR\", \"description\":\"$DESCRIPTION\"}" \
            "$API_URL/$NAME" > /dev/null
        echo "✅ 更新成功"
    else
        echo "➕ 标签不存在，正在创建..."
        curl -s -X POST \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            -d "{\"name\":\"$NAME\", \"color\":\"$COLOR\", \"description\":\"$DESCRIPTION\"}" \
            "$API_URL" > /dev/null
        echo "✅ 创建成功"
    fi
done

echo "🎉 所有标签初始化/更新完毕！"
