# 故障排查矩阵与 FAQ (Troubleshooting & FAQ)

在部署、开发或运行端云协同架构的 `smart_home_projects` 时，您可能会遇到各种挑战。本指南汇总了团队在过去六个月中遇到的高频问题及其标准解决方案。

---

## 1. 模型加载与端侧 OOM (Out of Memory)

**Q: 启动 App 时，端侧加载 `.gguf` 模型直接闪退（OOM）。**
*   **现象**: 控制台输出 `Terminated due to memory issue`，或在低端 Android 机型上频繁卡死。
*   **原因分析**: 模型参数量过大（如 2B 级别），或选择了未量化的 `F16` 格式，导致分配给 App 的可用内存耗尽。
*   **解决方案**:
    1.  确保使用的是经过量化的模型（推荐 `Q4_K_M` 或 `IQ2_XXS`）。
    2.  对于 4GB RAM 以下的 Android 设备，强制回退至云端大模型兜底（在代码中设置 `enableLocalModel = false`）。
    3.  检查 `llama_bindings.dart` 中是否在 `dispose()` 时未正确释放 C++ 内存。
    4.  参考：[Mac M4 端侧模型微调与量化复现 SOP](../../model_forge/training/mac_m4_reproduction_sop.md) 进行重新量化。

**Q: 端侧推理极度缓慢，每秒只能输出 1-2 个 Token。**
*   **现象**: 用户下发语音后，长达 5-10 秒才有控制响应。
*   **原因分析**: 未开启 GPU 加速（如 Apple Metal 或 Android Vulkan），导致 CPU 满载；或系统处于省电模式。
*   **解决方案**:
    1.  确认在编译 `llama.cpp` 时开启了 `GGML_METAL=1` 或 `GGML_VULKAN=1` 宏。
    2.  在 `llama_engine.dart` 的初始化参数中，确保 `n_gpu_layers` 设为大于 0 的合理值（通常设为 99 将全部层卸载到 GPU）。

---

## 2. 并发与状态同步问题

**Q: 弱网下设备状态不同步，出现“幽灵播报”（设备状态在开和关之间反复横跳）。**
*   **现象**: 端侧控制空调开启后，由于网络重传，过了一会儿空调又被重置为之前的关闭状态。
*   **原因分析**: 典型的 TOCTOU（Time-of-Check to Time-of-Use）并发竞态，旧的网络包晚于新的网络包到达云端。
*   **解决方案**:
    1.  确保云端已部署基于 Redis Lua 脚本的 Version Clock 校验机制（详见 `backed_project/app/services/device_service.py`）。
    2.  检查端侧在调用 `/shadow/batch` 时，是否正确上传了递增的 `last_update_ts` 版本号，绝不能使用云端的时间戳。
    3.  参考：[后端并发防御架构与代码质量审计报告](../../backed_project/docs/code_review_and_architecture_audit.md)。

**Q: FastAPI 云端接口响应变慢，日志显示大量 Timeout。**
*   **现象**: 云端大模型兜底接口 `/api/v1/ai/chat` 大量请求超过 5 秒。
*   **原因分析**: OpenAI/vLLM 服务限流，或者未采用异步客户端导致线程池耗尽。
*   **解决方案**:
    1.  确保 `AIService` 中使用的是 `AsyncOpenAI`。
    2.  检查 Redis 的 Semantic Cache（语义缓存）是否命中率过低，必要时调低相似度阈值或检查哈希算法。
    3.  检查端侧是否拦截了足够多的高频指令，如果没有，说明端侧 0.5B 模型的识别率退化了。

---

## 3. 开发环境与构建问题

**Q: 运行 `docker-compose up` 时，Redis 容器频繁重启。**
*   **现象**: `smarthome_redis` 状态显示 `restarting`。
*   **原因分析**: Docker 的宿主机挂载目录权限不足，或者缺少配置文件。
*   **解决方案**:
    1.  确保 `.env` 文件存在且 `REDIS_PASSWORD` 变量已设置。
    2.  检查挂载卷 `redis_data` 的权限，或者执行 `docker volume rm redis_data` 重置。
    3.  参考：[Docker 容器化与开发环境配置指南](../../backed_project/docs/docker_development_guide.md)。

**Q: 运行 `flutter run` 时报错：找不到 `unified_core` 动态链接库。**
*   **现象**: 提示 `Failed to load dynamic library 'libunified_core.so'`。
*   **原因分析**: C++ 核心库未在目标平台上正确编译。
*   **解决方案**:
    1.  **iOS/macOS**: 确保在 Xcode 中已将 `devices/unified_core/` 添加到 Target 的编译资源中。
    2.  **Android**: 确保 `android/app/build.gradle` 中正确配置了 CMake 路径，并执行了 NDK 构建。
    3.  可以使用 `tools/dev/build_core.sh` 脚本一键生成对应的平台库。

---

## 4. 业务逻辑与 AI 幻觉

**Q: 大模型兜底时，偶尔会返回不存在的设备 ID（例如 `light_999`）。**
*   **现象**: 云端返回的 JSON 动作无法在端侧找到对应设备执行。
*   **原因分析**: Prompt 构建不够严谨，或大模型产生了严重的幻觉（Hallucination）。
*   **解决方案**:
    1.  这是大模型的通病。请在端侧强行开启 **GBNF (Grammar-Based Network Format)** 约束。
    2.  在构建请求上下文时，动态生成类似 `{"type": "string", "enum": ["light_1", "ac_2"]}` 的 JSON Schema，强制大模型只能从中选择。
    3.  在飞轮系统中将此类失败交互标记为负样本，供下一轮微调使用。