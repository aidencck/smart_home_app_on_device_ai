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

# Docs directory
cp "$GITHUB_WORKSPACE/docs/product_vision_ice.md" Product-Vision.md || true
cp "$GITHUB_WORKSPACE/docs/edge_cloud_collaborative_architecture.md" Architecture-Overview.md || true
cp "$GITHUB_WORKSPACE/docs/fastapi_edge_cloud_architecture.md" FastAPI-Backend-Design.md || true
cp "$GITHUB_WORKSPACE/docs/honest_architecture_reflection.md" Architecture-Reflection.md || true
cp "$GITHUB_WORKSPACE/docs/ai_privacy_compliance_guidelines.md" Privacy-Compliance.md || true
cp "$GITHUB_WORKSPACE/docs/data_map_and_qa_lineage.md" Data-Map-and-Lineage.md || true

# Check if ADR exists in the workspace
if [ -f "$GITHUB_WORKSPACE/.trae/documents/ADR_001_OnDevice_AI_Architecture.md" ]; then
    cp "$GITHUB_WORKSPACE/.trae/documents/ADR_001_OnDevice_AI_Architecture.md" "Architecture-Decision-Records-(ADR).md"
fi

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

### 🏗️ 核心架构 (Architecture)
* [[端云协同全局架构|Architecture-Overview]]
* [[FastAPI 后端与并发防竞态|FastAPI-Backend-Design]]
* [[架构复盘与落地指南|Architecture-Reflection]]
* [[架构决策记录 (ADR)|Architecture-Decision-Records-(ADR)]]

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
EOF

# Generate _Footer.md
echo "Generating _Footer.md..."
cat << 'EOF' > _Footer.md
---
> 💡 **提示**: 本 Wiki 由主仓库代码自动同步生成。如有文档错误或改进建议，请勿直接编辑 Wiki，请前往 [主仓库的 docs 目录](https://github.com/aidencck/smart_home_app_on_device_ai/tree/main) 提交 PR。
EOF

# Fix internal links in markdown files using sed
echo "Fixing internal links..."
# We use standard sed, replacing links format [xxx](docs/xxx.md) -> [[xxx]] 
# Or just a simple text replace for known files
sed -i 's/docs\/product_vision_ice.md/Product-Vision/g' *.md || true
sed -i 's/docs\/fastapi_edge_cloud_architecture.md/FastAPI-Backend-Design/g' *.md || true
sed -i 's/docs\/honest_architecture_reflection.md/Architecture-Reflection/g' *.md || true
sed -i 's/docs\/ai_privacy_compliance_guidelines.md/Privacy-Compliance/g' *.md || true
sed -i 's/docs\/data_map_and_qa_lineage.md/Data-Map-and-Lineage/g' *.md || true
sed -i 's/docs\/edge_cloud_collaborative_architecture.md/Architecture-Overview/g' *.md || true
sed -i 's/model_forge\/on_device_model_customization_pipeline.md/Customization-Pipeline/g' *.md || true
sed -i 's/model_forge\/mac_m4_reproduction_sop.md/Reproduction-SOP/g' *.md || true
sed -i 's/model_forge\/data_evaluation_and_synthesis_rules.md/Data-Synthesis-Rules/g' *.md || true
sed -i 's/model_forge\/data_evaluation_and_acceptance_framework.md/Evaluation-Framework/g' *.md || true
sed -i 's/model_forge\/README.md/Model-Forge-Overview/g' *.md || true

# Fix image links (convert docs/xxx.gif to raw github url) to prevent broken images
echo "Fixing image links..."
# This points directly to the main branch raw content for images
sed -i "s|docs/\([a-zA-Z0-9_.-]*\.\(png\|jpg\|jpeg\|gif\|svg\|webp\)\)|https://raw.githubusercontent.com/${GITHUB_REPOSITORY}/main/docs/\1|g" *.md || true

# Commit and push changes
git add .
if git diff-index --quiet HEAD; then
  echo "No changes to sync to wiki."
else
  git commit -m "docs: auto sync docs to wiki via GitHub Actions"
  git push origin HEAD:master || git push origin HEAD:main
  echo "Wiki sync completed successfully."
fi
