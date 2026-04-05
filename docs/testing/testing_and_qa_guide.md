# 自动化测试与质量保障指南 (Testing & QA Docs)

本指南规范了 `smart_home_projects` Monorepo 下各子项目的测试标准、覆盖率要求以及 CI/CD 自动化测试的执行流程。

---

## 1. 测试层级与覆盖率要求

为了确保端云协同架构的稳定性，我们要求在合并代码到 `main` 分支前，必须满足以下测试指标：

| 子项目 (Sub-Project) | 测试框架 | 核心覆盖目标 | 最低覆盖率要求 |
| :--- | :--- | :--- | :--- |
| **`backed_project`** | `pytest` + `httpx` | API 接口 (Routers)、CRUD 逻辑、JWT 鉴权、Redis 分布式锁、设备影子版本冲突 | **> 85%** ( Routers 层需 100%) |
| **`fronted_project`** | `flutter test` | UI 气泡渲染、状态机 (Riverpod/Provider)、本地 Isar 数据库读写 | **> 70%** ( 核心状态管理需 90%) |
| **`model_forge`** | `Golden Benchmark` | 模型实体抽取准确率、GBNF 格式化输出、量化后精度下降率 | **> 95%** ( 格式准确率需 100%) |
| **`devices/core`** | `gtest` (C++) | FFI 接口内存泄漏测试、字符串编解码、逻辑时钟校验 | **> 90%** ( 内存安全零容忍) |

---

## 2. 后端测试规范 (`backed_project`)

### 2.1 编写单元测试
后端采用 `pytest` 编写，测试文件应放置在 `server/tests/` 目录下。
*   **Fixture 使用**：必须使用 `pytest.fixture` 模拟数据库会话和 Redis 连接，严禁在单元测试中连接真实的生产数据库。
*   **Mock 外部服务**：测试 `/api/v1/ai/chat` 接口时，必须 Mock `AsyncOpenAI` 或 `vLLM` 的调用，避免测试执行缓慢并产生 API 费用。

**执行命令：**
```bash
cd backed_project
pytest --cov=app tests/
```

### 2.2 重点防御测试：并发竞态 (TOCTOU)
在测试 `update_shadow_batch` 时，必须编写多线程并发测试脚本，验证在弱网环境下，当旧时间戳的报文晚于新时间戳到达时，Redis Lua 脚本是否能正确拒绝旧数据（抛出 `STATE_STALE` 异常）。

---

## 3. 前端测试规范 (`fronted_project`)

### 3.1 Widget 测试 (UI 层)
对于像聊天界面（Chat Bubble）这种高频重绘的组件，必须编写 Widget 测试。
*   验证在不同设备状态下，卡片能否正确渲染“离线”、“开/关”等 UI 表现。
*   验证滚动条在收到新消息时能否自动沉底。

### 3.2 集成测试 (Integration Test)
使用 `integration_test` 包进行真机/模拟器测试。
*   **端到端闭环**：模拟用户点击麦克风 -> ASR 识别 -> 触发端侧 `llama.cpp` -> 解析 JSON -> 更新 UI 状态。
*   *注意*：集成测试中，如果端侧模型文件（.gguf）过大，可使用一个极小的 Dummy Model（几 MB）来验证全链路逻辑，而非验证智能度。

**执行命令：**
```bash
cd fronted_project
flutter test integration_test/app_test.dart
```

---

## 4. 模型验收测试 (`model_forge`)

在通过 OTA 下发新模型前，必须通过 **Golden Benchmark** 的自动化验收。
详情请参阅：[数据评估与验收体系指南](../../model_forge/training/data_evaluation_and_acceptance_framework.md)

*   **执行方式**：运行 `python3 evaluate.py`，脚本将自动输入 500 条边缘测试集。
*   **一票否决项**：只要出现 1 例 GBNF 格式错误或设备 ID 幻觉，该模型版本直接打回，禁止发布。

---

## 5. CI/CD 流水线 (GitHub Actions)

项目在 `.github/workflows/` 下配置了自动化流水线。

### 5.1 PR 检查流水线 (Pull Request Check)
当开发者向 `main` 分支提交 PR 时，自动触发：
1.  **后端 Lint & Test**：运行 `flake8` 和 `pytest`。如果覆盖率低于 85%，PR 将被自动 Block。
2.  **前端 Lint & Test**：运行 `flutter analyze` 和 `flutter test`。
3.  **C++ 核心库编译**：尝试在 Ubuntu 和 macOS 环境下编译 `unified_core`，确保跨平台构建不报错。

### 5.2 部署与发布流水线 (Deploy & Release)
当合并到 `main` 分支并打上 Tag（如 `v1.2.0`）时：
1.  **后端镜像**：构建 FastAPI Docker 镜像并推送到私有仓库。
2.  **App 打包**：通过 Fastlane 构建 Android APK 和 iOS IPA，并上传到 TestFlight/蒲公英。
3.  **模型更新**：如果 `model_forge/exports/` 有更新，触发 CDN 同步和 OTA 版本号自增。