#!/bin/bash

# create_pm_optimization_issues.sh
# 此脚本用于将《项目管理与研发效能优化指南》中的核心提升项转化为 GitHub Issues，以便跟踪执行。
# 依赖: curl, jq, 并在环境变量中设置 GITHUB_TOKEN 和 REPO_OWNER_AND_NAME (例如 "your-org/smart_home_app")

set -e

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ 错误: 请设置 GITHUB_TOKEN 环境变量"
    echo "示例: export GITHUB_TOKEN='your_personal_access_token'"
    exit 1
fi

# 尝试自动从 git remote 中提取 REPO_OWNER_AND_NAME
if [ -z "$REPO_OWNER_AND_NAME" ]; then
    # 获取 origin 的 URL
    REMOTE_URL=$(git config --get remote.origin.url || echo "")
    if [ -n "$REMOTE_URL" ]; then
        # 从 HTTPS 或 SSH 格式的 URL 中提取 owner/repo
        # 例如 https://github.com/owner/repo.git 或 git@github.com:owner/repo.git
        EXTRACTED=$(echo "$REMOTE_URL" | sed -E 's/.*github\.com[:\/](.*)\.git/\1/' | sed -E 's/.*github\.com[:\/](.*)/\1/')
        if [ -n "$EXTRACTED" ] && [ "$EXTRACTED" != "$REMOTE_URL" ]; then
            REPO_OWNER_AND_NAME="$EXTRACTED"
            echo "🔍 自动检测到仓库: $REPO_OWNER_AND_NAME"
        fi
    fi
fi

if [ -z "$REPO_OWNER_AND_NAME" ]; then
    echo "❌ 错误: 无法自动检测到仓库名称，请设置 REPO_OWNER_AND_NAME 环境变量 (例如 'owner/repo')"
    exit 1
fi

API_URL="https://api.github.com/repos/$REPO_OWNER_AND_NAME/issues"

echo "🚀 开始将【研发效能优化项】推送到 GitHub Issues: $REPO_OWNER_AND_NAME"

# 定义要创建的 Issues (标题 | 描述 | 标签)
# 使用 | 作为分隔符
ISSUES=(
    "【效能提升】配置并启用全仓库的 CI/CD 自动化门禁|### 🎯 目标\n当前代码提交缺乏自动校验，增加了 Code Review 的人工成本。需要启用和完善 CI/CD 流程。\n\n### 📋 执行清单\n- [x] 在 \`.github/workflows/flutter_ci.yml\` 中配置 Flutter 自动化测试与静态检查。\n- [ ] 在 GitHub 仓库设置中开启 Branch Protection，要求 PR 必须通过 CI 检查才能合并。\n- [ ] 确保测试覆盖率报告可以自动附加到 PR 评论中。\n\n### 💡 验收标准\n任何对主分支的 PR 都会自动触发 Action，且未通过检查无法 Merge。|type: enhancement,module: devops,priority: high"
    
    "【效能提升】实施 CODEOWNERS 自动代码审查分发机制|### 🎯 目标\n当前端云协同的混合架构缺乏明确的审查责任人边界，导致 PR 滞留。需要强制执行 CODEOWNERS 规则。\n\n### 📋 执行清单\n- [x] 创建 \`.github/CODEOWNERS\` 文件并按技术栈（Flutter, AI, DevOps）划分目录责任人。\n- [ ] 在仓库的 Branch Protection 规则中，勾选 \"Require review from Code Owners\"。\n- [ ] 确保相关 GitHub Teams（如 \`@flutter-team\`）已在组织内正确创建并分配成员。\n\n### 💡 验收标准\n提交修改特定目录（如 \`/lib/\`）的 PR 时，GitHub 自动指派对应的 Team 进行 Review 且必须通过。|type: enhancement,module: devops,priority: medium"
    
    "【效能提升】初始化并推行标准化的 GitHub Label 体系|### 🎯 目标\n缺乏统一的标签体系导致项目经理无法高效过滤和排期，看板管理混乱。需要统一标签标准。\n\n### 📋 执行清单\n- [x] 编写 \`scripts/setup_github_labels.sh\` 脚本。\n- [ ] 运行该脚本，将优先级、任务类型、模块和状态等标准标签注入到远程仓库。\n- [ ] 清理仓库中历史遗留的、不规范的废弃标签。\n- [ ] 要求团队在提交 Issue 和 PR 时必须打上至少一个 \`type\` 和 \`module\` 标签。\n\n### 💡 验收标准\n远程仓库的 Labels 列表整洁且结构化，项目看板可以通过标签实现精确筛选。|type: enhancement,module: devops,priority: high"
    
    "【效能提升】启用 Stale 机器人自动清理僵尸任务|### 🎯 目标\nBacklog 中积压了大量长期无进展的 Issue 和 PR，干扰项目视线，需要自动化清理机制。\n\n### 📋 执行清单\n- [x] 增加 \`.github/workflows/stale.yml\` 配置文件。\n- [ ] 监控首次运行结果，确保机器人正确对 30 天无活动的 Issue 打上 \`stale\` 标签。\n- [ ] 团队内宣贯：如果任务确实需要延期，应主动移除 stale 标签或补充进度评论。\n\n### 💡 验收标准\n僵尸任务能够被系统自动识别并关闭，保持 Backlog 健康度。|type: enhancement,module: devops,priority: low"
    
    "【效能提升】规范化 Git 工作流与 PR 自动关联机制|### 🎯 目标\n目前 Issue 状态流转仍需人工干预，效率低下。需要推行 Git Flow 与 Issue 强关联。\n\n### 📋 执行清单\n- [ ] 禁用对 \`main\` 分支的直接 Push 权限。\n- [ ] 更新 \`CONTRIBUTING.md\`，要求所有开发必须基于 Issue 创建 \`feature/xxx\` 或 \`bugfix/xxx\` 分支。\n- [ ] 强制要求 PR 描述中必须包含 \`Closes #Issue编号\`。\n\n### 💡 验收标准\nPR 合并后，对应的 Issue 自动关闭，且 GitHub Projects 看板中的状态自动流转到 \"Done\"。|type: documentation,module: devops,priority: medium"
)

for ISSUE_INFO in "${ISSUES[@]}"; do
    # 使用 awk 解析，避免内容中包含换行符导致 IFS 解析失败
    TITLE=$(echo "$ISSUE_INFO" | awk -F'|' '{print $1}')
    BODY=$(echo "$ISSUE_INFO" | awk -F'|' '{print $2}' | sed 's/\\n/\n/g')
    LABELS=$(echo "$ISSUE_INFO" | awk -F'|' '{print $3}')
    
    # 将标签字符串转换为 JSON 数组格式格式: "label1","label2"
    JSON_LABELS=$(echo "$LABELS" | awk -F',' '{
        for(i=1;i<=NF;i++) {
            printf "\"%s\"", $i;
            if(i<NF) printf ","
        }
    }')
    
    echo "------------------------------------------------------"
    echo "📝 准备创建 Issue: $TITLE"
    
    # 构建 JSON Payload，使用 jq 确保格式正确，特别是处理换行符
    PAYLOAD=$(jq -n \
        --arg title "$TITLE" \
        --arg body "$BODY" \
        --argjson labels "[$JSON_LABELS]" \
        '{title: $title, body: $body, labels: $labels}')
        
    # 调用 API 创建 Issue
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -d "$PAYLOAD" \
        "$API_URL")
        
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY_RESP=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" -eq 201 ]; then
        ISSUE_URL=$(echo "$BODY_RESP" | jq -r .html_url)
        echo "✅ 创建成功: $ISSUE_URL"
    else
        echo "❌ 创建失败 (HTTP $HTTP_CODE)"
        echo "$BODY_RESP" | jq .message || echo "$BODY_RESP"
    fi
    
    # 避免触发 API 速率限制
    sleep 1
done

echo "======================================================"
echo "🎉 所有效能提升 Issues 处理完毕！"
