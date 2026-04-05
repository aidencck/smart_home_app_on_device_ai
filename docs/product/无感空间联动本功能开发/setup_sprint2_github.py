import subprocess
import json
import os

OWNER = "aidencck"
REPO = "smart_home_app_on_device_ai"

# Define new labels for Sprint 2
LABELS = [
    {"name": "Sprint-2", "color": "0E8A16", "description": "Sprint 2: MVP 产品骨架与多模态控制"},
    {"name": "Track-D-Backend", "color": "1D76DB", "description": "云端状态与业务聚合层"},
    {"name": "Track-E-Frontend", "color": "FBCA04", "description": "Flutter 核心页面与场景下发"}
]

# Define Sprint 2 Issues
TASKS = [
    {
        "title": "[Epic] Track D: 云端状态与业务聚合层",
        "body": "提供 App 首页渲染所需的高并发聚合 API，以及解决多端并发控制时的状态冲突问题。\n\n**负责**: backend-architect",
        "labels": "Sprint-2,Track-D-Backend,Epic,P0"
    },
    {
        "title": "[Task-D-1] 设计 Room 与 Scene 数据模型",
        "body": "### 描述\n定义房间与预设场景（如“坠入梦境”）的关联关系。\n\n### 验收标准 (AC)\n- [ ] 1. 数据库支持场景指令组存储。\n- [ ] 2. 支持场景和用户的多对多关系。",
        "labels": "Sprint-2,Track-D-Backend,Task,P0"
    },
    {
        "title": "[Task-D-2] 开发首页聚合 API (GET /v1/home/summary)",
        "body": "### 描述\n单次请求返回房间温湿度、光照、所有绑定设备状态及当前生效场景。\n\n### 验收标准 (AC)\n- [ ] 1. 避免 N+1 查询，接口响应时间 < 300ms。\n- [ ] 2. 聚合数据结构符合前端 UI 渲染需求。",
        "labels": "Sprint-2,Track-D-Backend,Task,P0"
    },
    {
        "title": "[Task-D-3] 引入 Vector Clock 解决状态并发冲突",
        "body": "### 描述\n在 Device 状态更新逻辑中加入版本时钟校验。\n\n### 验收标准 (AC)\n- [ ] 1. 拦截旧版本状态的覆盖写入。\n- [ ] 2. 边缘端与云端状态同步时，冲突解决策略生效，解决 UI 幽灵跳动。",
        "labels": "Sprint-2,Track-D-Backend,Task,P1"
    },
    {
        "title": "[Epic] Track E: Flutter 核心页面与场景下发",
        "body": "完成 Luma AI 四大核心页面的 UI 骨架开发，对接设备物模型，实现场景控制链路的端云闭环。\n\n**负责**: frontend-architect",
        "labels": "Sprint-2,Track-E-Frontend,Epic,P0"
    },
    {
        "title": "[Story-E-1] 首页 7 大模块 UI 骨架搭建",
        "body": "### 描述\n实现环境概览、生理状态环、快捷控制等组件。\n\n### 验收标准 (AC)\n- [ ] 1. 状态切换符合 Zero-UI 规范，无明显卡顿。\n- [ ] 2. 支持骨架屏加载状态 (Skeleton Loading)。",
        "labels": "Sprint-2,Track-E-Frontend,Story,P0"
    },
    {
        "title": "[Story-E-2] 对接首页聚合 API",
        "body": "### 描述\n使用 Riverpod/Provider 将接口数据映射到 UI。\n\n### 验收标准 (AC)\n- [ ] 1. 首页数据通过云端 API 渲染成功。\n- [ ] 2. 下拉刷新能够正确更新状态。",
        "labels": "Sprint-2,Track-E-Frontend,Story,P0"
    },
    {
        "title": "[Story-E-3] 场景列表与详情页 UI 及下发链路",
        "body": "### 描述\n实现场景页，点击“坠入梦境”发起控制请求。\n\n### 验收标准 (AC)\n- [ ] 1. 完成场景 UI 开发。\n- [ ] 2. 触发网关并发控制灯光及床体，提供执行反馈（Toast/震动）。",
        "labels": "Sprint-2,Track-E-Frontend,Story,P0"
    },
    {
        "title": "[Story-E-4] 动态解析物模型与设备属性面板",
        "body": "### 描述\n读取 14号文档定义的物模型，动态生成控制面板。\n\n### 验收标准 (AC)\n- [ ] 1. 支持灯光（亮度/色温）和床体（头脚高度）滑动控制。\n- [ ] 2. 滑动停止时防抖（Debounce）发送控制指令。",
        "labels": "Sprint-2,Track-E-Frontend,Story,P1"
    }
]

def run_cmd(cmd):
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return result

print("==== Creating Sprint 2 Labels ====")
for label in LABELS:
    cmd = f'gh label create "{label["name"]}" -R {OWNER}/{REPO} -c "{label["color"]}" -d "{label["description"]}" -f'
    run_cmd(cmd)

print("\n==== Creating Sprint 2 Issues ====")
for task in TASKS:
    with open("temp_sprint2.md", "w") as f:
        f.write(task["body"])
    cmd = f'gh issue create -R {OWNER}/{REPO} -t "{task["title"]}" -F temp_sprint2.md -l "{task["labels"]}"'
    res = run_cmd(cmd)
    if res.returncode == 0:
        print(f"Created: {task['title']}")

if os.path.exists("temp_sprint2.md"):
    os.remove("temp_sprint2.md")

print("\n==== Adding Sprint 2 Issues to Kanban Board ====")
# We know the project ID is 6 from the previous run
PROJECT_ID = "6"
fetch_cmd = f"gh issue list -R {OWNER}/{REPO} --label 'Sprint-2' --limit 50 --json id --jq '.[].id'"
res = run_cmd(fetch_cmd)
if res.returncode == 0 and res.stdout.strip():
    issue_ids = res.stdout.strip().split('\n')
    for issue_id in issue_ids:
        if issue_id:
            add_cmd = f"gh project item-create {PROJECT_ID} --owner {OWNER} --issue-id {issue_id}"
            add_res = run_cmd(add_cmd)
            if add_res.returncode == 0:
                print(f"Added issue ID {issue_id} to Kanban Board.")
print("==== Sprint 2 Setup Complete ====")
