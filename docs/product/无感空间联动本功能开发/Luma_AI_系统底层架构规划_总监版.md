# 《Luma AI 设备模型 + 配网流程 + 状态机 + 埋点体系（系统底层融合版）》

**文档编号**: PRD-LUMA-SYSTEM-006
**文档状态**: Final
**核心目的**: 将前面的“Zero-UI、多模态生理联动、四大核心页面”真正压实到系统底层。结合 Edge AI 网关（`unified_core`）、Isar 本地数据库以及 Flutter FFI 架构，重新定义 Luma AI 的设备对象、配网漏斗、核心状态机与联邦学习数据飞轮埋点。

---

## 1. 设备与生理模型设计 (Device & Physiological Model)

在 Luma AI 中，传统的 IoT 设备模型不足以支撑“无感联动”，必须引入**“传感器与执行器解耦”**以及**“本地生理基线模型”**。

### 1.1 产品对象层级 (6 层架构)

除了常规的 Home 和 Room，Luma AI 的核心在于重构 Device 层。

#### 第三层：设备实体 (Device Entity)
*   **感知设备 (Sensors)**: 智能戒指 (Ring)、毫米波雷达 (Radar)。
    *   *特点*: 仅作为数据源，无主动控制下发（不可调亮度/角度）。
*   **执行设备 (Actuators)**: 智能床 (Bed)、智能电视 (TV)、智能照明 (Lighting)。
    *   *特点*: 接收来自 Edge Hub 的 GBNF 安全指令并执行。
*   **边缘中枢 (Edge Hub)**: 家庭网关，内置小模型与 Isar 数据库。

#### 第四层：设备能力 (Capability)
针对多模态执行设备，能力层必须解耦。
*   `lighting_capability`: on_off, brightness, color_temperature.
*   `bed_capability`: angle_head (0-60°), angle_leg, massage_intensity, mattress_temp (24-38°C).
*   `tv_capability`: shader_engine (campfire, sunrise, deep_sea), asmr_volume.

#### 第五层：设备状态 (Device State - Isar 本地实时同步)
*   **核心字段**: `current_scene_id`, `is_ai_overridden` (是否处于手动熔断状态)。

#### 第六层 (新增)：生理基线模型 (Physiological Baseline - 仅存本地)
*   **作用**: Edge AI 进行“情绪对冲”和“节律顺应”的决策依据。
*   **字段示例**: 
    *   `user_id`
    *   `avg_hr_resting` (静息心率)
    *   `hrv_baseline_7d` (过去7天 HRV 均值，用于评估压力)
    *   `typical_sleep_onset_time` (常见入睡时间)
    *   `last_updated_at`

---

## 2. 配网与初始化流程设计 (Onboarding Flow)

配网不仅是硬件接入，更是**建立健康基线**与**体验 Zero-UI 价值**的首个漏斗。

### 2.1 配网链路升级：从“连 WiFi”到“场景预设”

1.  **基础接入 (BLE + Wi-Fi)**: 发现并绑定 Edge Hub 及执行设备。
2.  **感知设备穿戴绑定**: 引导用户佩戴戒指/激活床垫雷达，进行首次 1 分钟的“基线心率校准”。
3.  **价值前置转化 (核心步骤)**:
    *   不要在“添加成功”后结束。
    *   **强引导**: “今晚是否需要 Luma AI 为您开启『坠入梦境』模式？” -> **一键保存首个多模态自动化**。

### 2.2 失败降级策略
*   如果戒指绑定失败 -> 提示“将暂时使用雷达模式进行粗略入睡检测”。
*   如果 Edge Hub 连接失败 -> 提示“将降级为基础局域网控制，暂停 AI 节律服务”。

---

## 3. 核心状态机设计 (State Machine)

状态机的设计直接关系到 UI 的显示准确性以及 FFI 调用底层引擎的时机。

### 3.1 设备生命周期与 Edge Hub 状态
*   **特殊状态 `edge_offline_fallback`**: 当 Edge Hub 离线或宕机时，系统必须自动切入兜底模式。此时 App 首页控制区可用（直连设备），但 AI 推荐区和自动化区全部灰置。

### 3.2 场景状态机 (Scenario State)
*   引入 `modified_after_execution` (执行后被手动修改) 状态，即**“熔断状态”**。
*   **流转逻辑**: 
    1. Edge Hub 自动执行了“坠入梦境” (`executing` -> `active`)。
    2. 用户觉得灯太暗，手动将亮度从 10% 调到 25%。
    3. 场景状态立即变为 `modified_after_execution`。
    4. **事件触发**: 向 EventBus 抛出 `OVERRIDE_AI` 信号，记录负样本。

### 3.3 自动化状态机 (Automation State)
*   引入 `failed_by_override` 状态。如果自动化是因为用户的“主动熔断”而终止，不视为系统 Bug，而是作为大模型微调的输入。

### 3.4 首页聚合状态机 (UI State)
*   **优先级调整**: 
    1. `system_fault` (如：网关离线)。
    2. `ai_intervention_active` (AI 正在干预，如：Sunrise Shader 正在执行中，UI 需呈现呼吸态)。
    3. `recent_override_recorded` (刚刚发生手动熔断，提示：AI 正在学习您的新偏好)。
    4. `ready_normal` (日常待机)。

---

## 4. 埋点体系设计 (联邦学习数据飞轮)

Luma AI 的埋点不仅仅是为了看 PV/UV，更核心的目的是**在端侧 (Edge Hub) 收集数据，用于本地大模型的 LoRA 微调**，形成越用越懂你的数据飞轮。所有生理埋点**绝不上云**。

### 4.1 核心转化漏斗 1：AI 处方渗透率
*   `曝光`: AI 情绪抚慰/节律建议弹出。
*   `采纳`: 用户点击“立即体验”。
*   `完成`: 该模式完整运行结束（未被中途熔断）。
*   `留存`: 7 天内该自动化持续处于 Enabled 状态。

### 4.2 核心训练指标：手动熔断事件 (The Override Event)
这是最重要的事件，用于修正 AI 的“过度自信”。
*   **`event_ai_override_triggered`**
    *   `trigger_source`: 物理按键 / App 拖拽滑杆
    *   `interrupted_scene_id`: 被打断的场景 (如：坠入梦境)
    *   `override_type`: brightness_up / angle_down / temp_down (调亮/放平/降温)
    *   `original_value`: AI 设定的值 (如：10%)
    *   `user_value`: 用户手动设定的值 (如：25%)
    *   `time_since_ai_start_ms`: AI 开始执行到被用户打断的时长。

### 4.3 核心商业指标：SaaS 价值证明 (Sleep Improvement)
*   **`event_sleep_quality_delta`** (每日晨起由 Edge Hub 计算)
    *   `ai_intervention_flag`: 昨晚是否启用了 AI 联动。
    *   `sleep_latency_mins`: 入睡耗时。
    *   `deep_sleep_ratio`: 深睡比例。
    *   `hrv_recovery_score`: 晨起 HRV 恢复得分。
    *   *目标*: 在 AI 页向用户展示这组数据的正向提升，为订阅转化铺垫。

---

## 5. 产品总监结论

这份文档是 Luma AI 从“概念”走向“工程代码”的终极桥梁。
它明确了：
1.  **不再仅仅控灯**：引入了传感器感知层与多模态执行器的 Capability 解耦。
2.  **不再只看配网率**：配网的终点是让用户一键保存“首个生理联动场景”。
3.  **状态机的精髓在于“熔断”**：将用户的不满（手动调光）转化为系统进化的养料（`modified_after_execution` 状态）。
4.  **埋点即模型训练**：所有的 Override 事件都会在夜间被本地 Isar 提取，喂给 C++ `unified_core` 进行本地模型微调。

把这套底层系统做扎实，Luma AI 就真正具备了让竞争对手无法轻易 Copy 的“端侧数据壁垒”。下一步，我们可以直接进入《核心页面字段表与按钮交互表》的实战开发阶段。