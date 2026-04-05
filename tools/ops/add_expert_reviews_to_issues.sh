#!/bin/bash

# ==============================================================================
# GitHub Issues Expert Review Auto-Comment Script (Sprint 1)
# 视角：高级架构师 & 项目管理专家
# 作用：分析当前代码库现状，针对 Sprint 1 的核心 Issues 自动追加技术评审意见，指明避坑指南。
# ==============================================================================

# Ensure GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN environment variable is not set."
    exit 1
fi

REPO="aidencck/smart_home_app_on_device_ai"
API_URL="https://api.github.com/repos/$REPO"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
ACCEPT_HEADER="Accept: application/vnd.github.v3+json"

echo "🔍 Fetching Open Issues to append Expert Reviews..."

# 获取所有 Open Issues
ISSUES_JSON=$(curl -s -H "$AUTH_HEADER" "$API_URL/issues?state=open&per_page=100")

# 辅助函数：追加评论
add_comment() {
    local issue_num="$1"
    local comment_body="$2"

    local json_payload=$(jq -n \
        --arg body "$comment_body" \
        '{body: $body}')

    curl -s -X POST \
        -H "$AUTH_HEADER" \
        -H "$ACCEPT_HEADER" \
        "$API_URL/issues/$issue_num/comments" \
        -d "$json_payload" > /dev/null
        
    echo "✅ Added Expert Review to Issue #$issue_num"
}

# --- 准备专家评审内容 ---

REVIEW_FFI="### 👑 架构师评审意见 (Code Review & Advice)

通过对当前 \`llama_engine.dart\` 的分析，发现以下技术风险点，请在开发时重点关注：

1. **路径硬编码风险**：当前 C++ 动态库加载使用了 \`Directory.current.path\`。在 Release 模式下（尤其 iOS/Android），库文件会被打包到特定 bundle 目录下，直接调用会导致加载失败。**建议**：封装 \`DynamicLibraryLoader\` 根据 \`kReleaseMode\` 动态判定路径。
2. **C++ 内存泄漏隐患**：现有的 \`dispose\` 方法直接 kill 了 Isolate，这可能导致底层 \`llama_context\` 无法正常触发 C++ 的析构。**建议**：引入 \`NativeFinalizer\` 绑定资源，或者确保 Isolate 收到 'DISPOSE' 消息并完成 C++ 释放后再退出。
3. **流式输出 (Stream) 缺失**：端侧模型的首字响应 (TTFT) 极度影响体验，必须实现 \`inferStream\`。**技术难点**：跨 Isolate 的 SendPort 传递 token 时需要控制频率，避免压垮主线程的 Event Loop。"

REVIEW_GBNF="### 👑 架构师评审意见 (Code Review & Advice)

通过对当前 \`lib/models/device.dart\` 的分析，为了实现 100% 确定性的 GBNF 约束，建议如下：

1. **避免手动维护**：目前的 JSON 序列化是手动编写的。如果以此为基础硬编码 GBNF 规则，后续新增设备（如空调温度、扫地机器人模式）时极易引发“Schema 漂移”。
2. **元数据驱动**：建议引入 \`json_serializable\` 或自定义注解，在编译期提取设备的抽象描述（如：设备 A 支持开关，设备 B 支持 16-30 度的温度调节）。
3. **动态语法树**：GBNF 生成器必须是**动态的**。它应该读取当前家庭绑定的设备列表，生成仅包含这些 \`device_id\` 的语法树，彻底杜绝模型操作不存在的设备。"

REVIEW_SYNTHESIS="### 👑 架构师评审意见 (Code Review & Advice)

通过审查 \`model_forge/notebooks/data_synthesis.py\`，发现当前的数据合成逻辑过于单薄，无法支撑生产级模型：

1. **生成逻辑过于死板**：目前依赖 \`random.choice\` 拼接指令，这会导致模型只会处理极其生硬的命令（如“打开客厅的灯”）。对于“我有点热”这种隐式意图，模型将毫无对策。
2. **建议方案**：全面弃用随机拼接。引入 GPT-4 或 Qwen-Max 作为“教师模型”。将 \`device.dart\` 导出的 JSON Schema 作为系统提示词喂给教师模型，让其通过 Few-Shot 批量生成具有丰富语义变体的高质量指令。
3. **拒答数据 (Out-of-Domain) 比例**：必须强制注入至少 20% 的无关闲聊或危险指令，并要求模型输出固定的拒绝 JSON 格式，以防止端侧大模型在闲聊时胡言乱语。"

# --- 遍历并分发评论 ---

echo "$ISSUES_JSON" | jq -c '.[]' | while read -r issue; do
    ISSUE_NUM=$(echo "$issue" | jq -r '.number')
    ISSUE_TITLE=$(echo "$issue" | jq -r '.title')
    
    if [[ "$ISSUE_TITLE" =~ "基于 Dart FFI" && "$ISSUE_TITLE" =~ "Llama.cpp" ]]; then
        add_comment "$ISSUE_NUM" "$REVIEW_FFI"
    elif [[ "$ISSUE_TITLE" =~ "动态 GBNF" ]]; then
        add_comment "$ISSUE_NUM" "$REVIEW_GBNF"
    elif [[ "$ISSUE_TITLE" =~ "数据合成" ]]; then
        add_comment "$ISSUE_NUM" "$REVIEW_SYNTHESIS"
    fi
done

echo "🎉 Expert reviews have been successfully posted to Sprint 1 Issues!"
