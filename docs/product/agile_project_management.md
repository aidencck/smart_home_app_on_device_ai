# 🤝 开源协同与敏捷项目管理指南 (Agile Project Management)

为了保证 Smart Home On-Device AI 项目的高质量迭代，并降低开源社区开发者的参与门槛，本项目全面采用 **GitHub Projects** 与 **Issue-Driven Development (基于 Issue 驱动的开发)** 模式。

本指南旨在帮助新加入的架构师、开发者或产品经理快速理解本项目的协同运作机制。

---

## 1. 看板驱动的开发流 (Kanban Workflow)

项目的开发进度、任务分配与优先级均在一个统一的 [GitHub Project 看板](https://github.com/aidencck/smart_home_app_on_device_ai/projects) 中透明展示。

### 看板状态流转说明：
*   **🆕 Todo (待办)**: 经过架构师或 Maintainer 评审并确认需要落地的 Issue。任何人都可以在这里寻找自己感兴趣的任务进行认领。
*   **⏳ In Progress (进行中)**: 开发者已认领该任务，并开始编写代码。认领后，请确保在 Issue 中留言并 Assign 给你自己。
*   **👀 In Review (评审中)**: 开发者提交了 Pull Request (PR)，并关联了该 Issue。此时需要至少一位 Maintainer 进行 Code Review。
*   **✅ Done (已完成)**: PR 被合并到 `main` 分支，任务验收通过。

---

## 2. 自动化基建：零阻力的协同体验 (Automation)

我们深知维护看板的繁琐，因此本项目引入了深度定制的 **GitHub Actions** 来实现项目管理的自动化：

1. **自动入板 (Auto-Triage)**: 
   * 当你在仓库中新建任何一个 Issue（无论是 Bug Report 还是 Feature Request），GitHub Actions 会自动将其抓取并放入 Project 看板的 `Todo` 队列中。你无需手动去看板里添加卡片。
2. **状态联动 (State Sync)**: 
   * 当你提交 PR 并在描述中写上 `Fixes #123` 或 `Resolves #123` 时，一旦 PR 被合并，看板中的 `#123` 卡片会自动流转到 `Done` 列，彻底告别手动更新进度。

---

## 3. 宏观规划：Epic 与 Issue 的层级关系

对于大型架构重构或跨周期的功能模块，我们采用 **Epic (史诗)** 进行宏观追踪。

### 如何使用 Epic 模板？
1. 当规划一个包含多个子任务的庞大模块时（例如：“Phase 1: FastAPI 端云协同底座搭建”），请在创建 Issue 时选择 **`🚀 Epic / Roadmap Feature`** 模板。
2. 在 Epic Issue 的正文中，使用 Markdown 的 Task List 语法（`- [ ] #Issue编号`）来关联所有的子 Issue。
3. **效果**：GitHub 会原生渲染一个进度条，你可以直观地看到这个大模块的完成度（例如：`3/5 tasks`）。

### 示例层级：
*   📦 **[EPIC] Phase 1: FastAPI 端云协同底座搭建**
    *   👉 [Task] `#1` 初始化 FastAPI 后端脚手架 (Pydantic v2 & JWT)
    *   👉 [Task] `#2` 基于 Redis Cluster 重构设备影子
    *   👉 [Task] `#3` Flutter 端 Command ID 拦截器开发

---

## 4. 如何参与贡献？(Call to Action)

1. **寻找任务**：访问 [GitHub Project 看板](https://github.com/aidencck/smart_home_app_on_device_ai/projects)，在 `Todo` 列中寻找带有 `help wanted` 或 `good first issue` 标签的任务。
2. **认领任务**：在对应的 Issue 下方留言：“Hi, I would like to work on this.”，Maintainer 会将任务 Assign 给你，卡片会自动移入 `In Progress`。
3. **提交 PR**：Fork 本仓库，在本地新建分支开发。提交 PR 时，请务必使用我们提供的 [Pull Request Template](../../.github/PULL_REQUEST_TEMPLATE.md)，并关联你认领的 Issue。
4. **Code Review**：等待 Maintainer 审查代码，合并后，享受你的代码运行在下一代智能家居底座上的成就感！
