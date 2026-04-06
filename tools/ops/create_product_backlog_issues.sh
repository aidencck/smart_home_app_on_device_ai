#!/bin/bash

# ==============================================================================
# GitHub Issues Batch Creation Script - Product Backlog Edition
# 视角：产品负责人
# 作用：将产品愿景、Epic和用户故事推送到远程仓库项目管理中
# ==============================================================================

# Ensure GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN environment variable is not set."
    echo "Please set it before running the script:"
    echo "export GITHUB_TOKEN='your_personal_access_token_here'"
    exit 1
fi

# 尝试自动从 git remote 中提取 REPO
if [ -z "$REPO" ]; then
    # 获取 origin 的 URL
    REMOTE_URL=$(git config --get remote.origin.url || echo "")
    if [ -n "$REMOTE_URL" ]; then
        # 从 HTTPS 或 SSH 格式的 URL 中提取 owner/repo
        EXTRACTED=$(echo "$REMOTE_URL" | sed -E 's/.*github\.com[:\/](.*)\.git/\1/' | sed -E 's/.*github\.com[:\/](.*)/\1/')
        if [ -n "$EXTRACTED" ] && [ "$EXTRACTED" != "$REMOTE_URL" ]; then
            REPO="$EXTRACTED"
            echo "🔍 自动检测到仓库: $REPO"
        fi
    fi
fi

if [ -z "$REPO" ]; then
    echo "❌ Error: Please set REPO environment variable (e.g., 'owner/repo')"
    exit 1
fi
API_URL="https://api.github.com/repos/$REPO/issues"

# Helper function to create an issue using curl
create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"

    local json_payload=$(jq -n \
        --arg title "$title" \
        --arg body "$body" \
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

echo "🚀 Creating Product-Centric Epics and User Stories for Smart Home On-Device AI Project..."

# --- EPIC 1: Zero-UI 交互与视觉重构 ---
echo "📦 Creating Epic 1: Zero-UI..."
BODY_1="## 🎯 Epic 概述
打破传统 IoT 产品的工业化控制面板设计，通过物理映射和直觉手势建立“自然如呼吸”的差异化体验壁垒。

## 📋 包含的 User Stories
- [ ] 物理引擎驱动的设备状态映射
- [ ] 直觉式手势控制层开发
- [ ] 多模态感官反馈 (ASMR & Haptics) 集成"

EPIC1_URL=$(create_issue "[PRODUCT EPIC] Zero-UI 交互与视觉重构" "$BODY_1" "epic, product, ui/ux")
echo "✅ Created: $EPIC1_URL"

create_issue "[STORY] 物理引擎驱动的设备状态映射" "**作为**智能家居用户\n**我希望**告别繁琐的传统控制面板，通过极简的物理映射动画直观看到设备状态\n**以便于**我获得更直观、不被打扰的视觉体验。\n\n**验收标准**:\n- 接入 Flutter Impeller\n- 移除传统汉堡菜单，完成3款设备3D/Shader物理映射UI。\n\n属于 Epic: $EPIC1_URL" "story, ui/ux" > /dev/null
create_issue "[STORY] 直觉式手势控制层" "**作为**智能家居用户\n**我希望**通过直觉式手势直接控制设备\n**以便于**我不需要进入层层菜单寻找设置项。\n\n**验收标准**:\n- 开发通用手势映射中间件，将滑动/长按自动转化为底层 JSON 指令。\n\n属于 Epic: $EPIC1_URL" "story, enhancement" > /dev/null
create_issue "[STORY] 多模态感官反馈 (ASMR & Haptics)" "**作为**智能家居用户\n**我希望**在控制设备时能获得高保真的感官反馈\n**以便于**我的操作获得愉悦的非视觉确认。\n\n**验收标准**:\n- 建立并集成平台级 ASMR 音效库与 CoreHaptics 触觉反馈参数。\n\n属于 Epic: $EPIC1_URL" "story, enhancement" > /dev/null

# --- EPIC 2: 主动智能与场景模块进化 ---
echo "📦 Creating Epic 2: 主动智能与场景模块进化..."
BODY_2="## 🎯 Epic 概述
实现从“响应指令”到“预判需求”的跨越，提升用户粘性和产品“智能感”。

## 📋 包含的 User Stories
- [ ] 端侧习惯学习与主动推荐流
- [ ] 弹性场景：动态感知执行
- [ ] 自然语言极简创建场景"

EPIC2_URL=$(create_issue "[PRODUCT EPIC] 主动智能与场景模块进化" "$BODY_2" "epic, product, ai-agent")
echo "✅ Created: $EPIC2_URL"

create_issue "[STORY] 端侧习惯学习与主动推荐流" "**作为**智能家居用户\n**我希望**系统能默默学习我日常操作设备的规律，并在场景页面主动推荐卡片\n**以便于**我可以一键采纳，减少手动配置。\n\n**验收标准**:\n- 改造 ScenesPage，新增 AI 建议区域\n- 端侧模型根据 Isar 日志输出推荐。\n\n属于 Epic: $EPIC2_URL" "story, ai-agent" > /dev/null
create_issue "[STORY] 弹性场景：动态感知执行" "**作为**智能家居用户\n**我希望**触发场景时，系统能根据当前的环境因子（如室温、光照）动态微调设备参数\n**以便于**场景执行更符合当下真实需求。\n\n**验收标准**:\n- 场景引擎支持变量占位符\n- 前置调用 AI Agent 获取环境上下文并微调。\n\n属于 Epic: $EPIC2_URL" "story, enhancement" > /dev/null
create_issue "[STORY] 自然语言极简创建场景" "**作为**智能家居用户\n**我希望**可以直接用自然语言对话来创建场景\n**以便于**以最低门槛创建复杂的设备联动。\n\n**验收标准**:\n- 端侧模型解析实体和动作，生成配置表单。\n\n属于 Epic: $EPIC2_URL" "story, nlp" > /dev/null

# --- EPIC 3: 隐私优先的端侧计算闭环 ---
echo "📦 Creating Epic 3: 隐私优先计算闭环..."
BODY_3="## 🎯 Epic 概述
打消用户对全天候感知的隐私顾虑，使“主动智能”具备落地的绝对前提。

## 📋 包含的 User Stories
- [ ] 纯本地时序数据库画像
- [ ] 显性合规授权与数据飞轮开关"

EPIC3_URL=$(create_issue "[PRODUCT EPIC] 隐私优先的端侧计算闭环" "$BODY_3" "epic, product, privacy")
echo "✅ Created: $EPIC3_URL"

create_issue "[STORY] 纯本地时序数据库画像" "**作为**看重隐私的用户\n**我希望**所有的设备操作日志都在本地处理，绝对不上传云端\n**以便于**放心地让 AI 学习生活节律。\n\n**验收标准**:\n- 完善 Isar BehaviorLog，切断所有未经脱敏的日志上云。\n\n属于 Epic: $EPIC3_URL" "story, privacy, local-db" > /dev/null
create_issue "[STORY] 显性合规授权与数据飞轮开关" "**作为**智能家居用户\n**我希望**自主决定是否开启“体验改善计划”\n**以便于**对数据拥有100%的控制权。\n\n**验收标准**:\n- 强制合规授权墙（Opt-in）\n- 端侧 NER 剥离 PII 数据。\n\n属于 Epic: $EPIC3_URL" "story, privacy" > /dev/null

# --- EPIC 4: 极速且无缝的端云协同体验 ---
echo "📦 Creating Epic 4: 端云协同体验..."
BODY_4="## 🎯 Epic 概述
在本地算力与云端大模型之间建立完美平衡，兼顾响应速度与长尾能力。

## 📋 包含的 User Stories
- [ ] 0延迟本地推理控制
- [ ] 长尾对话无缝云端降级
- [ ] 多设备状态强一致性"

EPIC4_URL=$(create_issue "[PRODUCT EPIC] 极速且无缝的端云协同体验" "$BODY_4" "epic, product, architecture")
echo "✅ Created: $EPIC4_URL"

create_issue "[STORY] 0延迟本地推理控制" "**作为**智能家居用户\n**我希望**日常硬件控制做到极速响应（<300ms），且格式100%正确。\n\n**验收标准**:\n- 优化 Dart FFI Llama.cpp\n- 引入 GBNF 语法树杜绝幻觉。\n\n属于 Epic: $EPIC4_URL" "story, performance" > /dev/null
create_issue "[STORY] 长尾对话无缝云端降级" "**作为**智能家居用户\n**当我**提出超出本地控制范围的问题时\n**我希望**系统隐式切换到云端处理，不报错。\n\n**验收标准**:\n- 意图分类器 (Intent Splitting)\n- FastAPI 云端兜底路由。\n\n属于 Epic: $EPIC4_URL" "story, cloud" > /dev/null
create_issue "[STORY] 多设备状态强一致性" "**作为**智能家居用户\n**我希望**设备状态不会发生冲突或“幽灵跳动”。\n\n**验收标准**:\n- Redis Cluster Vector Clock\n- Flutter Command ID 拦截器。\n\n属于 Epic: $EPIC4_URL" "story, reliability" > /dev/null

echo "🎉 All Product Epics and Stories have been created!"
echo "They will automatically appear in your GitHub Project Board."
