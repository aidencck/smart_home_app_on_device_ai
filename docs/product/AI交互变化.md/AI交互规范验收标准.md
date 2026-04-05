下面给你一套可直接用于产品规划、IA 重构和设计评审的 **AI Agent 时代信息架构重构框架**。

先给结论：

**互联网时代的 IA 是“页面树”；AI+硬件时代的 IA 是“场景树”；AI Agent 时代的 IA 必须升级成“意图—上下文—执行—反馈”的任务系统。**
原因很清楚：传统 IA 主要组织内容与导航；而 Agent 官方框架已经把产品核心拆成 **models、tools、state/memory、orchestration**，并把 workflow、guardrails、tracing、evals 放进一等能力里。这说明 Agent 产品不再只是“展示信息”，而是在“理解目标、调用工具、执行步骤、暴露过程、留下产物”。([Nielsen Norman Group][1])

## 一、先换骨架：从 4 个旧问题，换成 4 个新问题

传统 IA 常问的是：

* 内容放哪
* 页面怎么跳
* 导航怎么分层
* 搜索怎么找得快

Agent IA 应该改问：

* 用户现在真正想完成什么
* 系统此刻掌握了哪些上下文
* 系统下一步该做什么，需不需要授权
* 执行过程、结果和责任怎么让用户看得懂

这不是概念游戏。OpenAI 的 agent 文档把“goal”“workflow”“tools”“control-flow logic”放在构建起点；Anthropic 也明确说，效果最好的 agent 往往不是复杂框架，而是简单、可组合的模式。Gemini Live 之类多模态入口又进一步证明：输入已经从“键入一个 query”变成“把眼前屏幕、摄像头、语音和连续上下文一起交给系统”。([OpenAI开发者][2])

## 二、重构后的 8 层 IA 框架

### 1）意图层：先组织“为什么来”，再组织“有什么”

这是顶层骨架。
Agent 产品的一级分类不该先按功能或对象分，而应先按 **用户意图** 分。常见的一层意图通常只有 5–8 个，否则会重新退化成功能市场。比如：

* 找答案
* 做任务
* 持续推进一个工作
* 协作/沟通
* 监控/提醒
* 创作/探索

这里的关键不是文案，而是把首页、搜索、推荐、通知、最近记录都统一到这组意图上。因为 Agent 的核心不是“有什么功能”，而是“我现在要完成什么目标”。OpenAI 的 agent 定义本身就是“systems that intelligently accomplish tasks”，不是“systems that answer questions”。([OpenAI开发者][3])

**你要交付的产物：**
一张 `Intent Map`，列出一级意图、二级任务、典型触发场景、成功终点。

---

### 2）上下文层：把“会话”升级成“任务上下文”

传统产品把上下文理解成页面状态；Agent 产品要把上下文扩成：

* 用户身份与权限
* 历史会话
* 长短期记忆
* 当前设备/位置/时间
* 当前屏幕/摄像头/文件
* 相关工具可用性
* 正在进行中的任务状态

Gemini Live 已经把摄像头、屏幕共享带进实时对话；OpenAI 的 agent 栈把 state/memory 视为基础原语。这意味着 IA 不再只是组织静态内容，而要组织“此刻哪些上下文应该进入决策回路”。([Android][4])

**设计原则：**
不要把所有上下文都隐式吞进去。
要把“已使用哪些上下文”“还缺哪些上下文”做成可见状态。

**你要交付的产物：**
一张 `Context Contract`，定义每类任务默认读取什么、何时请求补充、何时清空。

---

### 3）编排层：把 IA 从“栏目结构”升级成“工作流结构”

Agent 产品的中枢不是页面，而是 workflow。
OpenAI 官方把 workflow 定义为 **agents + tools + control-flow logic** 的组合，并在 Agent Builder 里用节点、typed inputs/outputs、版本发布来组织它。换句话说，新的 IA 主干其实是：

**意图识别 → 计划/路由 → 工具调用 → 验证/回退 → 产物沉淀**。 ([OpenAI开发者][5])

所以产品层必须显式设计三种编排：

* **路由**：把请求分给哪个 agent / skill / workflow
* **控制流**：一步完成，还是多步推进
* **交接**：何时 handoff 给别的 agent，何时还给用户

**你要交付的产物：**
每个高频意图一张 `Workflow Blueprint`，至少标明入口、分支、审批点、失败回退点。

---

### 4）能力层：把工具做成“可组合能力”，不是隐藏 API

在 Agent 时代，功能目录会变成能力目录。
OpenAI Agents SDK 明确把 handoffs、tools、streaming、full trace 作为核心；Anthropic 也强调 effective agents 依赖简单、可组合的构件。产品上这意味着：工具不应只是后端接口，而应成为 IA 的一部分。([OpenAI开发者][6])

建议把能力分成 4 类：

* **读取类**：搜索、读文件、查日历、读邮件
* **生成类**：写文档、总结、规划、生成图片/代码
* **执行类**：发邮件、建会议、下单、改系统设置
* **监控类**：追踪状态、条件触发、自动提醒

每个能力都需要有清晰的：

* 输入要求
* 输出类型
* 权限边界
* 失败语义
* 是否可撤销

**你要交付的产物：**
一张 `Skill/Tool Catalog`，不是按后端服务分，而是按用户可理解能力分。

---

### 5）权限与风险层：把治理嵌进主流程，不要挂在设置页外面

这是很多团队最容易晚做、也最容易出事的一层。
OpenAI 2026 的 governed agents cookbook 讲得很明确：到了生产阶段，问题会变成“失败怎么办、谁负责、怎么证明合规”，而治理做得好反而会加速交付；Agent Builder 安全文档也点出了 prompt injection、data leakage 等风险。([OpenAI开发者][7])

所以 IA 里必须有一层 **Risk Architecture**：

* 什么动作默认允许
* 什么动作要显式确认
* 什么动作需要双重审批
* 什么数据绝不外发
* 什么情况下中止 agent 并交回用户

权限设计不能只是一层系统弹窗。
它应该嵌在任务流程里，成为节点。

**你要交付的产物：**
一张 `Permission Matrix`：意图 × 能力 × 数据级别 × 执行动作 × 审批级别。

---

### 6）过程可见层：把“正在发生什么”做成主界面，不是调试页

Agent 产品如果只显示最终答案，用户会不信任。
OpenAI 的 agent 体系已经把 tracing、trace grading、workflow-level eval 放进正式工具链，说明“过程观测”不是开发者奢侈品，而是生产系统的一部分。([OpenAI开发者][8])

前台最少要显式展示：

* 当前目标
* 当前步骤
* 正在用哪些工具
* 是否在等待授权
* 是否遇到异常
* 用户现在能暂停/修改/接管什么

也就是把黑盒输出，改造成“可跟随执行”的状态机。

**你要交付的产物：**
一套 `Execution UI`，通常是 step timeline + status chips + approval prompts + stop/take-over controls。

---

### 7）产物层：让结果沉淀成可复用对象，而不是一次性回答

Agent 的价值不只在答案，而在 **artifact**。
OpenAI 的工作流思路本身就把输出看成可部署、可版本化、可评估的对象；在产品层，你也要把文档、表格、计划、任务清单、会议纪要、搜索报告、自动化规则等产物做成一等公民。([OpenAI开发者][5])

这会直接改写 IA：

* “历史记录”不再只是聊天记录
* “项目空间”不再只是文件夹
* “搜索结果”不再只是列表
* “完成任务”会生成后续可编辑、可分享、可继续运行的对象

**你要交付的产物：**
一张 `Artifact Model`：每种任务最终沉淀成什么对象、归属到哪里、谁可继续编辑或再执行。

---

### 8）学习与评估层：把 IA 设计成可被持续优化的系统

Agent 产品没有“上线即完成”的 IA。
OpenAI 官方推荐用 evals 和 trace grading 来定位 workflow 级错误；Anthropic 的经验也强调持续迭代简单模式而不是一开始追复杂度。([OpenAI开发者][9])

所以你要把指标直接绑在 IA 上，而不是只看 DAU 或停留时长。

建议至少监控：

* 意图识别准确率
* 首次路径命中率
* 上下文补充率
* 工具调用成功率
* 授权中断率
* 用户接管率
* 任务完成率
* 产物复用率
* trace 异常率
* 高风险动作拦截率

**你要交付的产物：**
一套 `IA Metrics Tree`，能一路追到页面、节点、工具和审批点。

## 三、落到界面：首页、导航、搜索、通知该怎么改

### 首页：从“功能入口页”改成“任务控制台”

首页不该优先堆功能和推荐位，而应优先放：

* 继续未完成任务
* 直接发起高频意图
* 最近产物
* 需要审批/确认的执行
* Agent 主动提醒与监控结果

因为 Agent 产品的高频动作不再是“浏览”，而是“继续推进”。这和传统 IA 的栏目首页完全不同。OpenAI 的 agent 文档围绕 goal 和 workflow 展开，也支持这种首页逻辑。([OpenAI开发者][2])

### 导航：从“页面导航”改成“状态导航”

一级导航建议只保留少数稳定骨架，例如：

* 任务
* 产物
* 自动化/监控
* 记忆/知识
* 权限与审计

不要把 skill、tool、workflow、agent 全都拉到一级。那些更适合成为编排层或专业模式。([OpenAI开发者][5])

### 搜索：从“找信息”改成“找下一步”

搜索结果不应只返回内容，还应返回：

* 可直接执行的动作
* 对应工作流
* 历史相似任务
* 相关产物
* 可引用的记忆与上下文

这本质上是把 search 改造成 intent router。Agent 产品里，搜索与执行越来越是一体的。([OpenAI开发者][2])

### 通知：从“消息提醒”改成“任务状态回调”

通知应围绕：

* 需要你批准
* 已完成某步
* 失败需你接管
* 监控命中条件
* 产物已生成可查看

而不是只推“Agent 有回复了”。因为真正重要的是任务状态，不是对话条数。([OpenAI开发者][7])

## 四、你可以直接拿去用的重构顺序

第一步，先定 5–8 个一级意图。
第二步，为每个高频意图画 workflow。
第三步，梳理上下文 contract 和 permission matrix。
第四步，把前台补齐执行态、审批态、异常态。
第五步，把结果沉淀成 artifact，而不是埋在 chat history 里。
第六步，用 traces 和 evals 跑真实任务，持续压缩路径。
这个顺序和官方 agent 体系的 workflow-first、trace-first、safety-aware 思路是一致的。([OpenAI开发者][5])

## 五、套回 Character.AI，会怎么改

Character.AI 现在的问题，正好是“对象很多，但意图骨架不够强”。
官方已经把产品扩成 Feed、Scenes、Stories、labs、memory 等多种对象与体验，且明确在从 chat-centric app 走向 content-driven social platform 与 AI entertainment platform。([Character.AI Blog][10])

如果按 Agent 时代 IA 重构，它的首页不该再主要按对象分，而该按意图分成：

* 继续上次关系
* 找陪伴
* 进入角色扮演
* 刷可互动内容
* 自己创作
* 管理我的角色/记忆

然后再把 Feed、Scenes、Stories、labs 这些对象挂到对应意图下。
这样用户进入时先回答“我此刻想做什么”，不是先被迫理解产品里有哪些格式。这个思路也更适合它当前把 teen 用户逐步从 open-ended chat 转向更结构化、多模态体验的路线。([Character.AI Blog][10])

## 六、一句话收束

**AI Agent 时代的信息架构，不再是“把信息摆好”，而是“围绕用户意图组织目标、上下文、工具、权限、执行过程与结果产物”。**
谁还把 IA 停留在页面树、栏目树、内容对象树，谁就会出现同一种问题：功能越来越多，用户却越来越不确定下一步该做什么。这个判断与 NN/g 对 IA 与导航的区分、OpenAI 对 agent/workflow 的定义，以及多模态连续上下文产品的演进方向是吻合的。([Nielsen Norman Group][1])

我可以下一条直接给你补一版 **“AI Agent 产品 IA 蓝图模板”**，按首页、导航、状态流、审批流、产物流画成结构图。

[1]: https://www.nngroup.com/articles/ia-vs-navigation/ "The Difference Between Information Architecture (IA) and Navigation - NN/G"
[2]: https://developers.openai.com/api/docs/guides/agents/ "Agents | OpenAI API"
[3]: https://developers.openai.com/api/docs/guides/agents/?utm_source=chatgpt.com "Agents | OpenAI API"
[4]: https://www.android.com/articles/gemini-on-android/ "Gemini Live: Use Camera & Screen Sharing on Android | Android"
[5]: https://developers.openai.com/api/docs/guides/agent-builder/ "Agent Builder | OpenAI API"
[6]: https://developers.openai.com/api/docs/guides/agents-sdk/?utm_source=chatgpt.com "Agents SDK | OpenAI API"
[7]: https://developers.openai.com/cookbook/examples/partners/agentic_governance_guide/agentic_governance_cookbook/ "Building Governed AI Agents - A Practical Guide to Agentic Scaffolding"
[8]: https://developers.openai.com/api/docs/guides/trace-grading/?utm_source=chatgpt.com "Trace grading | OpenAI API"
[9]: https://developers.openai.com/api/docs/guides/agent-evals/?utm_source=chatgpt.com "Agent evals | OpenAI API"
[10]: https://blog.character.ai/character-ai-launches-worlds-first-ai-native-social-feed/?utm_source=chatgpt.com "Character.AI Launches World's First AI-Native Social Feed"
