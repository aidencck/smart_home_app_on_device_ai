import subprocess
import json

# Define the repository
REPO = "aidencck/smart_home_app_on_device_ai"

# Define the labels to create
LABELS = [
    {"name": "Sprint-1", "color": "0E8A16", "description": "Sprint 1: 核心基础链路与技术债偿还"},
    {"name": "Track-A-Backend", "color": "1D76DB", "description": "云端后端链路"},
    {"name": "Track-B-EdgeAI", "color": "5319E7", "description": "边缘计算与 AI 引擎"},
    {"name": "Track-C-Frontend", "color": "FBCA04", "description": "前端 App 与本地数据闭环"},
    {"name": "Epic", "color": "3E4B9E", "description": "史诗任务"},
    {"name": "Story", "color": "C2E0C6", "description": "用户故事"},
    {"name": "Task", "color": "F9D0C4", "description": "具体开发任务"},
    {"name": "P0", "color": "B60205", "description": "最高优先级"},
    {"name": "P1", "color": "D93F0B", "description": "高优先级"}
]

# Define the tasks based on Track A, B, C
TASKS = [
    # Track A
    {
        "title": "[Epic] Track A: 云端后端链路打通",
        "body": "提供设备配网、绑定及在线状态管理的云端 API 支撑。\n\n**前置依赖**: 无。可立即开工。\n**负责**: backend-architect",
        "labels": "Sprint-1,Track-A-Backend,Epic,P0"
    },
    {
        "title": "[Task-A-1] 设计 Device 与 Binding 数据库表结构",
        "body": "### 描述\n包含 device_id, mac_address, status, bound_user_id 等字段。\n\n### 验收标准 (AC)\n- [ ] 1. 数据库迁移脚本 (Migration) 可成功执行。\n- [ ] 2. 表结构符合高并发写入要求。",
        "labels": "Sprint-1,Track-A-Backend,Task,P0"
    },
    {
        "title": "[Task-A-2] 开发 POST /v1/devices/bind API",
        "body": "### 描述\n解析 App 传来的 BLE 广播包信息并入库。\n\n### 验收标准 (AC)\n- [ ] 1. 提供 Swagger/OpenAPI 文档。\n- [ ] 2. 接口耗时 < 200ms。\n- [ ] 3. 错误码(设备已被绑定、非法设备等)符合 08号文档。",
        "labels": "Sprint-1,Track-A-Backend,Task,P0"
    },
    {
        "title": "[Task-A-3] 开发心跳 API 与离线状态 Worker",
        "body": "### 描述\n`POST /v1/devices/heartbeat` 及定时检查机制。\n\n### 验收标准 (AC)\n- [ ] 1. 设备上报心跳后更新 last_seen。\n- [ ] 2. 后台 Worker (如 Celery) 每分钟扫表，超过 3 分钟标记为 offline。",
        "labels": "Sprint-1,Track-A-Backend,Task,P1"
    },

    # Track B
    {
        "title": "[Epic] Track B: 边缘计算与 AI 引擎",
        "body": "彻底替换 C++ 层的 Mock 代码，引入真实的本地大模型推理能力与防幻觉语法限制，并提供设备模拟器。\n\n**负责**: ai-integration-eng",
        "labels": "Sprint-1,Track-B-EdgeAI,Epic,P0"
    },
    {
        "title": "[Task-B-1] 编写 BLE 设备广播模拟器",
        "body": "### 描述\n模拟智能灯、床、戒指发送符合 Luma AI 格式的蓝牙广播 (C++ 或 Python)。\n\n### 验收标准 (AC)\n- [ ] 1. 脚本运行后，手机端可通过蓝牙嗅探工具看到对应 MAC 和广播包。\n- [ ] 2. 广播包含 14 号物模型要求的标志位。",
        "labels": "Sprint-1,Track-B-EdgeAI,Task,P0"
    },
    {
        "title": "[Task-B-2] 集成精简版 llama.cpp 推理框架",
        "body": "### 描述\n在 `unified_core.cpp` 中引入库并配置编译系统 (CMake)。\n\n### 验收标准 (AC)\n- [ ] 1. 能够加载指定的 GGUF 模型文件。\n- [ ] 2. 边缘端编译无报错，内存占用控制在要求范围内。",
        "labels": "Sprint-1,Track-B-EdgeAI,Task,P0"
    },
    {
        "title": "[Task-B-3] 编写 Luma AI 专属 GBNF 防幻觉语法文件",
        "body": "### 描述\n限制大模型输出必须是 JSON-RPC 格式，且亮度在 0-100，床体角度在合法范围。\n\n### 验收标准 (AC)\n- [ ] 1. 输入极端 prompt，大模型输出仍被强制约束在 GBNF 规范的 JSON 内。\n- [ ] 2. 验证深睡期指令拦截率 100%。",
        "labels": "Sprint-1,Track-B-EdgeAI,Task,P0"
    },
    {
        "title": "[Task-B-4] 实现供 App 调用的 C++ FFI 接口层",
        "body": "### 描述\n封装模型推理与 GBNF 校验过程，暴露给 Flutter 端。\n\n### 验收标准 (AC)\n- [ ] 1. FFI 接口签名清晰 (入参: context_json, 出参: action_json)。\n- [ ] 2. 引擎端到端响应时间测试。",
        "labels": "Sprint-1,Track-B-EdgeAI,Task,P1"
    },

    # Track C
    {
        "title": "[Epic] Track C: 前端 App 与本地数据闭环",
        "body": "实现 App 端的蓝牙发现、配网流程，以及构建 Isar 本地数据库（生理基线与熔断日志）。\n\n**负责**: frontend-architect",
        "labels": "Sprint-1,Track-C-Frontend,Epic,P0"
    },
    {
        "title": "[Story-C-1] Flutter 层 BLE 扫描与设备发现模块",
        "body": "### 描述\n集成 `flutter_blue_plus`，过滤 Luma AI 特定广播。\n\n### 验收标准 (AC)\n- [ ] 1. App 能发现附近的设备并解析 MAC 地址。\n- [ ] 2. 列表实时更新无卡顿。",
        "labels": "Sprint-1,Track-C-Frontend,Story,P0"
    },
    {
        "title": "[Story-C-2] App 侧对接配网绑定 API",
        "body": "### 描述\n将扫描到的设备调用 Track A 提供的接口。\n\n### 验收标准 (AC)\n- [ ] 1. 绑定成功后提示并跳转设备页。\n- [ ] 2. 异常态（网络超时、设备被占）的友好 UI 提示。",
        "labels": "Sprint-1,Track-C-Frontend,Story,P0"
    },
    {
        "title": "[Story-C-3] 建立 Isar 数据库 Schema",
        "body": "### 描述\n定义基于 14号物模型 的生理基线与熔断实体 (`PhysiologicalBaseline` & `Override_Log`)。\n\n### 验收标准 (AC)\n- [ ] 1. 生成 `.g.dart` 成功。\n- [ ] 2. 提供 CRUD 的 Repository 层封装。",
        "labels": "Sprint-1,Track-C-Frontend,Story,P1"
    },
    {
        "title": "[Story-C-4] 首页滑杆联动写入 Override_Log 并熔断 AI",
        "body": "### 描述\n在场景执行时，捕获用户的亮度/床体滑动事件。\n\n### 验收标准 (AC)\n- [ ] 1. 滑动时立即产生一条 Override_Log (负样本)。\n- [ ] 2. 发送信号阻断当前大模型的下发任务，确保“用户干预最高优先级”。",
        "labels": "Sprint-1,Track-C-Frontend,Story,P1"
    }
]

def run_cmd(cmd):
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error running: {cmd}")
        print(result.stderr)
    return result

print("==== Creating GitHub Labels ====")
for label in LABELS:
    # Use gh label create or edit
    cmd = f'gh label create "{label["name"]}" -R {REPO} -c "{label["color"]}" -d "{label["description"]}" -f'
    run_cmd(cmd)
    print(f"Label '{label['name']}' created/updated.")

print("\n==== Creating GitHub Issues ====")
for task in TASKS:
    title = task["title"]
    body = task["body"]
    labels = task["labels"]
    
    # Save body to a temp file to avoid quoting issues
    with open("temp_body.md", "w") as f:
        f.write(body)
    
    cmd = f'gh issue create -R {REPO} -t "{title}" -F temp_body.md -l "{labels}"'
    result = run_cmd(cmd)
    if result.returncode == 0:
        print(f"Created Issue: {title} -> {result.stdout.strip()}")
    
# Clean up temp file
import os
if os.path.exists("temp_body.md"):
    os.remove("temp_body.md")

print("\n==== Sync Complete ====")
