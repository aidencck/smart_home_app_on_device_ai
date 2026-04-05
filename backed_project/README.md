# macinit - Smart Home Backend

`macinit` 是一个高性能、微服务化、多云兼容的智能家居后端系统。本项目旨在提供一个端云协同的 AIoT 基础设施，不仅支持端侧大模型的高效语义控制，还能与各大第三方 IoT 平台无缝集成。

## 🚀 核心架构与特性

经过近期的深度重构，项目已从单体应用平滑演进为基于 **领域驱动设计 (DDD)** 和 **事件驱动架构 (EDA)** 的模块化微服务体系：

*   **隔离与并发安全**：通过 `SERVICE_ROLE` 环境变量，将 AI 推理密集型 I/O 与设备高频控制流在物理进程级别彻底隔离，杜绝了大模型请求阻塞设备控制的风险。
*   **防腐层设计 (ACL)**：解耦了数据访问层，移除了跨域 Redis 直连，实现了服务间的边界隔离。
*   **军事级防重放攻击**：修复了弱网重试风暴下的防重放攻击穿透漏洞，并结合基于 Lua 的 Vector Clock 机制，从底层保障设备状态（Device Shadow）的高并发一致性。
*   **多云兼容架构 (Tuya / AWS IoT)**：引入了南向集成层（Southbound Integration Layer），通过适配器模式和内部统一物模型（TSL），将核心 AI 控制逻辑与第三方平台的专有协议完美解耦。

## 📚 详细架构文档

请参考以下文档深入了解系统的架构演进与设计模式：

*   [macinit 多云 IoT 兼容架构设计](../docs/architecture/multi_cloud_architecture.md)：详细阐述了防腐层（ACL）、统一物模型（TSL）以及异构协议（涂鸦、AWS）的同步设计。

## 🛠 快速启动

系统已通过 Docker Compose 实现了容器化的微服务隔离。你可以一键启动四个独立角色的微服务：

```bash
cd smart_home_projects/backed_project
docker-compose up -d
```

这将会启动：
*   **AI Gateway** (`smarthome_ai_gateway`): 负责语义分析与大模型调度 (Port: 8000)
*   **Device Shadow** (`smarthome_device_shadow`): 负责处理高频状态上报与竞态控制 (Port: 8001)
*   **IoT Core** (`smarthome_iot_core`): 负责传统的租户、设备注册与控制面业务 (Port: 8002)
*   **Data Flywheel** (`smarthome_data_flywheel`): 负责异步日志收集、评估与 OTA (Port: 8003)

## 🧪 测试

在微服务启动后，可以运行集成测试套件验证防重放机制与 Vector Clock 拦截逻辑：

```bash
docker exec smarthome_ai_gateway pytest tests/test_api.py -v
```