#!/bin/bash
set -e

# This script clones the wiki repo, maps and copies documentation files, and pushes them back.

# Define the repository URL for the wiki
REPO_URL="https://x-access-token:${GH_PAT}@github.com/${GITHUB_REPOSITORY}.wiki.git"
WIKI_DIR="/tmp/wiki"

echo "Cloning wiki repository..."
git clone "$REPO_URL" "$WIKI_DIR" || {
  echo "Error: Failed to clone wiki repository. Please ensure the Wiki feature is enabled in your GitHub repository settings and you have created at least one page to initialize it."
  exit 1
}

cd "$WIKI_DIR"

# Configure git
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

# Copy and rename files from the main repo to the wiki
echo "Copying documentation files..."

# Root docs
cp "$GITHUB_WORKSPACE/README.md" Home.md || true
cp "$GITHUB_WORKSPACE/CONTRIBUTING.md" Contributing.md || true

# Docs directory - Product & Vision
cp "$GITHUB_WORKSPACE/docs/product/product_vision_ice.md" Product-Vision.md || true
cp "$GITHUB_WORKSPACE/docs/product/无感空间联动本功能开发/06.Luma_AI_无感智能全景规划与落地蓝图.md" Zero-UI-Holistic-Blueprint.md || true

# Docs directory - Architecture
cp "$GITHUB_WORKSPACE/docs/architecture/edge_cloud_collaborative_architecture.md" Architecture-Overview.md || true
cp "$GITHUB_WORKSPACE/docs/architecture/full_lifecycle_ai_architecture_solution.md" Full-Lifecycle-AI-Architecture.md || true
cp "$GITHUB_WORKSPACE/docs/architecture/full_lifecycle_core_data_flow_architecture.md" Core-Data-Flow-Architecture.md || true
cp "$GITHUB_WORKSPACE/docs/architecture/fastapi_edge_cloud_architecture.md" FastAPI-Backend-Design.md || true
cp "$GITHUB_WORKSPACE/docs/architecture/honest_architecture_reflection.md" Architecture-Reflection.md || true
cp "$GITHUB_WORKSPACE/docs/architecture/on_device_ai_architecture_review.md" On-Device-AI-Architecture-Review.md || true
cp "$GITHUB_WORKSPACE/docs/architecture/architecture_evolution_and_blind_spots.md" Architecture-Evolution.md || true
cp "$GITHUB_WORKSPACE/docs/architecture/matter_integration_project_schedule_and_task_breakdown.md" Matter-Delivery-Plan.md || true
cp "$GITHUB_WORKSPACE/docs/architecture/ecosystem_integration_strategy_apple_google_alexa.md" Ecosystem-Integration.md || true
cp "$GITHUB_WORKSPACE/docs/architecture/ai_privacy_compliance_guidelines.md" Privacy-Compliance.md || true
cp "$GITHUB_WORKSPACE/docs/architecture/data_map_and_qa_lineage.md" Data-Map-and-Lineage.md || true
cp "$GITHUB_WORKSPACE/docs/api/api_reference.md" API-Reference.md || true

# Docs directory - QA & Troubleshooting
cp "$GITHUB_WORKSPACE/docs/testing/testing_and_qa_guide.md" Testing-and-QA.md || true
cp "$GITHUB_WORKSPACE/docs/troubleshooting/faq_and_troubleshooting.md" Troubleshooting-and-FAQ.md || true
cp "$GITHUB_WORKSPACE/docs/user_manual/end_user_manual.md" End-User-Manual.md || true

# Check if ADR exists in the workspace
if [ -f "$GITHUB_WORKSPACE/.trae/documents/ADR_001_OnDevice_AI_Architecture.md" ]; then
    cp "$GITHUB_WORKSPACE/.trae/documents/ADR_001_OnDevice_AI_Architecture.md" "Architecture-Decision-Records-(ADR).md"
fi

# Docs directory - Delivery & Roadmap
cp "$GITHUB_WORKSPACE/docs/product/无感空间联动本功能开发/23.Luma_AI_Sprint_1_4_最终结案与验收报告.md" Sprint-1-4-Acceptance-Report.md || true
cp "$GITHUB_WORKSPACE/docs/product/无感空间联动本功能开发/25.Luma_AI_Sprint_5_细颗粒度拆分与并行开发计划.md" Sprint-5-Plan.md || true
cp "$GITHUB_WORKSPACE/docs/product/无感空间联动本功能开发/24.Luma_AI_端云设备数据联动与交互深度梳理.md" Device-Data-Interaction-Deep-Dive.md || true
cp "$GITHUB_WORKSPACE/docs/product/无感空间联动本功能开发/27.Luma_AI_下一阶段设备联动与微调深度设计.md" Next-Phase-Device-Linkage.md || true
cp "$GITHUB_WORKSPACE/docs/product/无感空间联动本功能开发/28.Luma_AI_多模态无感联动方案深度分析与设计.md" Multimodal-Zero-UI-Solution.md || true

# Docs directory - UX
cp "$GITHUB_WORKSPACE/docs/product/无感空间联动本功能开发/26.Luma_AI_商业级无感交互UI_UX设计与架构规范.md" Commercial-UX-UI-Standard.md || true

# Docs directory - Privacy & Project Management
cp "$GITHUB_WORKSPACE/docs/architecture/ai_privacy_compliance_guidelines.md" Privacy-Compliance.md || true
cp "$GITHUB_WORKSPACE/docs/architecture/data_map_and_qa_lineage.md" Data-Map-and-Lineage.md || true
cp "$GITHUB_WORKSPACE/docs/product/agile_project_management.md" Agile-Project-Management.md || true

# Model Forge directory
cp "$GITHUB_WORKSPACE/model_forge/README.md" Model-Forge-Overview.md || true
cp "$GITHUB_WORKSPACE/model_forge/on_device_model_customization_pipeline.md" Customization-Pipeline.md || true
cp "$GITHUB_WORKSPACE/model_forge/data_evaluation_and_synthesis_rules.md" Data-Synthesis-Rules.md || true
cp "$GITHUB_WORKSPACE/model_forge/data_evaluation_and_acceptance_framework.md" Evaluation-Framework.md || true
cp "$GITHUB_WORKSPACE/model_forge/mac_m4_reproduction_sop.md" Reproduction-SOP.md || true

# Generate _Sidebar.md
echo "Generating _Sidebar.md..."
cat << 'EOF' > _Sidebar.md
### 🏠 欢迎
* [[项目概览与快速开始|Home]]
* [[产品愿景：Zero-UI|Product-Vision]]
* [[无感智能全景规划|Zero-UI-Holistic-Blueprint]]

### 🏗️ 核心架构 (Architecture)
* [[端云协同全局架构|Architecture-Overview]]
* [[全生命周期 AI 架构方案|Full-Lifecycle-AI-Architecture]]
* [[核心数据流架构|Core-Data-Flow-Architecture]]
* [[FastAPI 后端与并发防竞态|FastAPI-Backend-Design]]
* [[架构决策记录 (ADR)|Architecture-Decision-Records-(ADR)]]
* [[架构复盘与落地指南|Architecture-Reflection]]
* [[端侧 AI 架构评估|On-Device-AI-Architecture-Review]]
* [[架构演进与盲区攻坚|Architecture-Evolution]]
* [[API 接口参考|API-Reference]]

### 📦 交付与路线图 (Delivery & Roadmap)
* [[Matter 接入排期与任务分解|Matter-Delivery-Plan]]
* [[全球生态接入策略 (Apple/Google)|Ecosystem-Integration]]
* [[Sprint 1-4 结案与验收报告|Sprint-1-4-Acceptance-Report]]
* [[Sprint 5 详细计划|Sprint-5-Plan]]
* [[端云设备数据联动深度梳理|Device-Data-Interaction-Deep-Dive]]
* [[下一阶段设备联动与微调设计|Next-Phase-Device-Linkage]]
* [[多模态无感联动方案|Multimodal-Zero-UI-Solution]]

### 🛠️ 运维与测试 (Ops & QA)
* [[自动化测试与质量保障|Testing-and-QA]]
* [[故障排查与 FAQ|Troubleshooting-and-FAQ]]
* [[用户操作手册|End-User-Manual]]

### 🎨 体验与交互 (Experience & UX)
* [[商业级无感交互 UI/UX 规范|Commercial-UX-UI-Standard]]

### 🧠 模型工厂 (Model Forge)
* [[模型工厂概览|Model-Forge-Overview]]
* [[模型定制全链路方案|Customization-Pipeline]]
* [[数据合成黄金规则|Data-Synthesis-Rules]]
* [[评估指标与验收框架|Evaluation-Framework]]
* [[Mac M4 模型微调 SOP|Reproduction-SOP]]

### 🛡️ 隐私与数据 (Data & Security)
* [[端到端隐私合规指南|Privacy-Compliance]]
* [[数据地图与血缘追踪|Data-Map-and-Lineage]]

### 👨‍💻 开发者 (Developers)
* [[参与贡献|Contributing]]
* [[敏捷项目管理指南|Agile-Project-Management]]
EOF

# Generate _Footer.md
echo "Generating _Footer.md..."
cat << 'EOF' > _Footer.md
---
> 💡 **提示**: 本 Wiki 由主仓库代码自动同步生成。如有文档错误或改进建议，请勿直接编辑 Wiki，请前往 [主仓库的 docs 目录](https://github.com/aidencck/smart_home_app_on_device_ai/tree/main) 提交 PR。
EOF

# Fix internal links in markdown files using sed
echo "Fixing internal links..."
# Docs/Product
sed -i 's|docs/product/product_vision_ice.md|Product-Vision|g' *.md || true
sed -i 's|docs/product/agile_project_management.md|Agile-Project-Management|g' *.md || true

# Docs/Architecture
sed -i 's|docs/architecture/edge_cloud_collaborative_architecture.md|Architecture-Overview|g' *.md || true
sed -i 's|docs/architecture/full_lifecycle_ai_architecture_solution.md|Full-Lifecycle-AI-Architecture|g' *.md || true
sed -i 's|docs/architecture/full_lifecycle_core_data_flow_architecture.md|Core-Data-Flow-Architecture|g' *.md || true
sed -i 's|docs/architecture/fastapi_edge_cloud_architecture.md|FastAPI-Backend-Design|g' *.md || true
sed -i 's|docs/architecture/honest_architecture_reflection.md|Architecture-Reflection|g' *.md || true
sed -i 's|docs/architecture/ai_privacy_compliance_guidelines.md|Privacy-Compliance|g' *.md || true
sed -i 's|docs/architecture/data_map_and_qa_lineage.md|Data-Map-and-Lineage|g' *.md || true
sed -i 's|docs/architecture/on_device_ai_architecture_review.md|On-Device-AI-Architecture-Review|g' *.md || true
sed -i 's|docs/architecture/architecture_evolution_and_blind_spots.md|Architecture-Evolution|g' *.md || true
sed -i 's|docs/architecture/matter_integration_project_schedule_and_task_breakdown.md|Matter-Delivery-Plan|g' *.md || true
sed -i 's|docs/architecture/ecosystem_integration_strategy_apple_google_alexa.md|Ecosystem-Integration|g' *.md || true
sed -i 's|docs/testing/testing_and_qa_guide.md|Testing-and-QA|g' *.md || true
sed -i 's|docs/troubleshooting/faq_and_troubleshooting.md|Troubleshooting-and-FAQ|g' *.md || true
sed -i 's|docs/user_manual/end_user_manual.md|End-User-Manual|g' *.md || true
sed -i 's|docs/api/api_reference.md|API-Reference|g' *.md || true

# Docs/Sprint & Features
sed -i 's|docs/product/无感空间联动本功能开发/06.Luma_AI_无感智能全景规划与落地蓝图.md|Zero-UI-Holistic-Blueprint|g' *.md || true
sed -i 's|docs/product/无感空间联动本功能开发/23.Luma_AI_Sprint_1_4_最终结案与验收报告.md|Sprint-1-4-Acceptance-Report|g' *.md || true
sed -i 's|docs/product/无感空间联动本功能开发/25.Luma_AI_Sprint_5_细颗粒度拆分与并行开发计划.md|Sprint-5-Plan|g' *.md || true
sed -i 's|docs/product/无感空间联动本功能开发/24.Luma_AI_端云设备数据联动与交互深度梳理.md|Device-Data-Interaction-Deep-Dive|g' *.md || true
sed -i 's|docs/product/无感空间联动本功能开发/27.Luma_AI_下一阶段设备联动与微调深度设计.md|Next-Phase-Device-Linkage|g' *.md || true
sed -i 's|docs/product/无感空间联动本功能开发/28.Luma_AI_多模态无感联动方案深度分析与设计.md|Multimodal-Zero-UI-Solution|g' *.md || true
sed -i 's|docs/product/无感空间联动本功能开发/26.Luma_AI_商业级无感交互UI_UX设计与架构规范.md|Commercial-UX-UI-Standard|g' *.md || true

# Model Forge
sed -i 's|model_forge/README.md|Model-Forge-Overview|g' *.md || true
sed -i 's|model_forge/on_device_model_customization_pipeline.md|Customization-Pipeline|g' *.md || true
sed -i 's|model_forge/data_evaluation_and_synthesis_rules.md|Data-Synthesis-Rules|g' *.md || true
sed -i 's|model_forge/data_evaluation_and_acceptance_framework.md|Evaluation-Framework|g' *.md || true
sed -i 's|model_forge/mac_m4_reproduction_sop.md|Reproduction-SOP|g' *.md || true

# Fix image links (convert docs/xxx.gif to raw github url) to prevent broken images
echo "Fixing image links..."
# This points directly to the main branch raw content for images
sed -i "s|docs/\([a-zA-Z0-9_.-]*\.\(png\|jpg\|jpeg\|gif\|svg\|webp\)\)|https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/main/docs/\1|g" *.md || true

# Commit and push changes
git add .
if git diff-index --quiet HEAD; then
  echo "No changes to sync to wiki."
else
  git commit -m "docs: refresh wiki with new sprint docs and architecture updates"
  git push origin HEAD:master || git push origin HEAD:main
  echo "Wiki sync completed successfully."
fi
