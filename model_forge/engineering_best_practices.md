# 🏠 智能家居端侧 AI：工程化落地实践指南 (Data, Lifecycle & Constraints)

> **"Intelligence is not just about making a decision; it's about making a safe and consistent one in the physical world."**
> 本文档旨在解决 `model_forge` 项目中缺失的数据采集闭环、传感器全生命周期管理及物理约束逻辑，提升 AI Agent 的工程落地能力。

---

## 一、 核心架构：从物理感知到智能决策的端到端链路

为了实现无感智能，系统必须从“被动响应指令”转变为“主动感知并决策”。

### 1. 完整数据流向 (The Actual Process)

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#1e293b', 'edgeLabelBackground':'#0f172a', 'tertiaryColor': '#334155'}}}%%
graph TD
    subgraph "感知层 (Perception)"
        S1["物理传感器 (Ring/Light/Temp)"] --> SH["传感器中枢 (Sensor Hub)"]
        SH --> DS["设备状态管理 (State Manager)"]
    end

    subgraph "推理层 (Reasoning)"
        DS --> CP["上下文提供者 (Context Provider)"]
        CP --> LLM["端侧大模型 (On-Device LLM)"]
        LLM --> PI["意图解析 (Intent Parsing)"]
    end

    subgraph "约束与执行层 (Safety & Execution)"
        PI --> CE["物理约束引擎 (Constraint Engine)"]
        CE -- "通过校验" --> AE["动作执行器 (Action Executor)"]
        CE -- "拦截/修正" --> LOG["冲突日志 (Conflict Log)"]
        AE --> ACT["物理执行器 (Actuator)"]
    end

    subgraph "数据反馈闭环 (Feedback Loop)"
        ACT --> FB["用户反馈/行为观察"]
        FB --> DC["数据采集仓 (Data Collector)"]
        DC --> FT["LoRA 微调/迭代"]
    end

    classDef dark fill:#1e293b,stroke:#334155,color:#fff;
    class S1,SH,DS,CP,LLM,PI,CE,AE,LOG,ACT,FB,DC,FT dark;
```

---

## 二、 数据采集策略：构建真实世界的数据飞轮

合成数据（Synthetic Data）只能解决“起步”问题，真实的工程落地必须依赖**环境反馈数据**。

### 1. 采集维度
*   **传感器原始数据 (Raw Data)**：高频采样（如心率、环境亮度），在端侧进行特征提取（Feature Extraction）后上传“语义数据”（如：用户进入深睡）。
*   **决策冲突日志 (Conflict Logs)**：大模型建议的操作被“物理约束引擎”拦截或被用户手动撤销的情况。
*   **状态转移序列 (State Transitions)**：记录“状态A -> 动作B -> 状态C”的序列，用于训练强化学习（RL）或更精准的 SFT。

### 2. 反馈机制 (The Flywheel)
1.  **主动采纳**：用户未干预，视为正样本。
2.  **静默拒绝**：大模型输出了意图，但约束引擎因安全原因拦截，记录为“护栏样本”。
3.  **用户修正**：Agent 执行了操作，但用户在 5 分钟内进行了反向操作（如 Agent 关灯，用户立刻开灯），记录为“负样本 (Negative Sample)”。

---

## 三、 传感器全生命周期管理 (Sensor Lifecycle)

传感器不是永远可靠的。工程化落地必须考虑其“生老病死”。

| 阶段 | 核心任务 | 技术要点 |
| :--- | :--- | :--- |
| **1. 注册 (Registration)** | 设备配网与能力发现 | 使用 Matter/IoT 协议声明传感器精度、采样率、单位。 |
| **2. 校准 (Calibration)** | 消除系统误差 | 初始启动时或定期（如每3个月）要求用户协助进行零位校准。 |
| **3. 活跃监控 (Monitoring)** | 健康度与心跳检测 | **Heartbeat**: 超过 5 分钟未上报数据标记为 `OFFLINE`。**Anomaly Detection**: 瞬时数值跳变（如室温从 25°C 突跳到 80°C）标记为 `FAULTY`，触发 Agent 告警。 |
| **4. 漂移处理 (Drift Handling)** | 长期运行误差补偿 | 通过与云端或其他冗余传感器对比，自动修正读数偏差。 |
| **5. 报废 (Decommissioning)** | 数据合规销毁 | 物理设备移除后，彻底清除本地相关的行为日志和习惯缓存。 |

---

## 四、 物理约束引擎 (Physical Constraint Engine)

大模型擅长推理，但不了解物理世界的极限。必须在 `ActionExecutor` 之前增加一层硬约束。

### 1. 约束分类
*   **安全硬约束 (Safety Constraints)**：
    *   *示例*：电暖器开启时间严禁超过 8 小时。
    *   *逻辑*：`if (action == 'turn_on' && device == 'heater' && duration > MAX) reject();`
*   **环境互斥约束 (Environmental Exclusion)**：
    *   *示例*：空调制冷开启时，加湿器严禁以最高功率运行（防止结露）。
    *   *逻辑*：`if (state['ac'].mode == 'cooling') limit(humidifier.power, 50%);`
*   **隐私与权限约束 (Privacy & Auth)**：
    *   *示例*：深睡期（DEEP_SLEEP）严禁开启主卧摄像头或门锁，除非二次生物识别鉴权。

### 2. 约束表示法 (GBNF-like DSL)
建议使用结构化的配置（如 JSON-Schema）来定义每个设备的物理边界：
```json
{
  "device_type": "smart_bed",
  "constraints": [
    {
      "id": "deep_sleep_lock",
      "condition": "global.sleep_stage == 'DEEP_SLEEP'",
      "enforce": { "angle": 0, "vibration": "off" },
      "priority": "CRITICAL"
    }
  ]
}
```

---

## 五、 工程落地路线图 (Action Plan)

1.  **[ ] 升级 SensorHub**：实现传感器状态机，支持 `OFFLINE` 和 `FAULTY` 状态的动态感知。
2.  **[ ] 重构 ActionExecutor**：引入 `ConstraintManager` 拦截器，在下发指令前读取设备边界配置。
3.  **[ ] 建立本地数据湖**：在 `Isar` 中新增 `ConflictLog` 表，专门记录“Agent 决策 vs 物理约束”的偏差。
4.  **[ ] 自动化 SFT 闭环**：编写脚本从 `ConflictLog` 提取数据，自动转换为微调数据集格式。

---
*Created by Gemini-3-Flash-Preview in Trae IDE*
