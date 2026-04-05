# 端侧引擎 Unified Core 与前端项目的关联与作用

这份文档整理了关于底层 C++ 引擎 (`unified_core.cpp`) 与 Flutter 前端 UI 架构之间的关系、核心职责以及未来的接入方案。

## 1. 为什么需要这个 C++ 写的 Unified Core？

在智能家居架构中，如果把所有的逻辑（如判断用户语音意图、解析高频设备状态、连接蓝牙等）都写在 Flutter (Dart) 业务层中，会导致一个非常严重的问题：**App 会非常卡，内存会被撑爆。** 

特别是在满足《AI交互改造需求文档》中规定的硬性指标：
* 端侧资源受限：RAM峰值 ≤ 1.5GB
* 需规避懒加载造成的 UI 卡顿

由于 C++ 是运行速度最快、最贴近硬件底层的语言，架构设计中将**最脏、最累、最需要算力**的核心逻辑抽离了出来，用 C++ 构建了这个 `unified_core` 引擎，从而实现“前后端（端侧）分离架构”。Flutter 仅负责“仪表盘”展示，而 C++ 负责“发动机”运转。

## 2. Unified Core 在项目中具体负责干什么？

从核心库代码中可以看出，该引擎主要负责以下几项高频、高算力事务：

* **充当“十字路口交警” (`evaluate_intent_complexity`)**：
  当用户在 Flutter UI 上输入指令时，Flutter 会将文本透传给 C++ 引擎。引擎瞬间进行分流判断：
  * **“打开灯”** -> 简单指令，**拦截**，直接在本地设备执行（极速响应，不依赖外部网络）。
  * **“如果明天下雨...”** -> 复杂条件指令，**放行**，路由交给云端大模型处理。
* **直连物理设备 (`execute_device_command`)**：
  绕过 Flutter 沉重的事件循环，直接通过底层协议（如 Matter / BLE）快速下发硬件控制指令。
* **高频数据同步与聚合 (`collect_batch_device_states`)**：
  例如智能戒指每秒都在疯狂发送心率和体动数据，如果直接将高频流推给 Flutter，极易导致 App 崩溃 (OOM)。因此，C++ 引擎在底层充当缓冲池，将这些数据聚合、过滤、打包后，再按需抛给 Flutter 层。

## 3. 它和 Flutter 项目是怎么连起来的？(FFI)

虽然 UI 与核心引擎使用不同的语言编写，但它们在同一个端侧设备（如智能面板或手机）中运行，两者之间的通讯桥梁就是 **FFI (Foreign Function Interface，外部函数接口)**。

在项目当前的演进状态中：
1. **模型推理层的 FFI 已打通**：
   在 `model_forge/inference/on_device_agent/lib/src/engine/llama_cpp/llama_bindings.dart` 中，已经实现了 `dart:ffi` 桥接，Flutter 已经可以直接调用底层的 AI 大模型进行推理。
2. **Unified Core 的 FFI 桥接规划**：
   `unified_core` 的 C++ 层代码已经就绪并测试通过。但根据架构规划文档 `system_complexity_optimization.md`，将 Flutter UI 和这个 C++ 设备控制引擎彻底绑定的 FFI 桥接层代码（类似于 `unified_core_bindings.dart`）目前仍在开发计划中。

**总结：**
Flutter 前端项目提供了直观、现代的交互设计和 UI 呈现；而 `unified_core.cpp` 则是支撑整个系统能够“毫秒级响应”、“低内存占用”的底层基石。一旦 FFI 桥接完成，UI 上的每一次意图触发，都将瞬间交由底层 C++ 引擎高效执行。
