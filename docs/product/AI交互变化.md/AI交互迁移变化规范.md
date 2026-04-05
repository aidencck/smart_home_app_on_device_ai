这里我把“互联的”按**传统互联网 / 移动互联网**来理解。

先定一个底层判断：**信息架构不是导航条怎么摆，而是产品如何组织内容、功能、关系和路径。** NN/g 对 IA 的定义很直接：IA 是信息的骨架，导航只是用户在 UI 里到达信息的方式；Apple 和 Material 对 tab/navigation bar 的定义也都还是“在不同 section / view 之间切换”。这意味着在互联网时代，IA 的默认前提是：**用户先进入某个页面或栏目，再在页面树里找东西。** ([Nielsen Norman Group][1])

所以在传统互联网和移动互联网时代，信息架构天然更像**“对象架构”**，而不是“意图架构”。产品会先把世界切成频道、栏目、页面、卡片、详情页、列表页、个人页，再用 tab、drawer、search、推荐把用户送进这些对象里。它的核心问题是“内容怎么分类、页面怎么跳、层级怎么降噪”，而不是“用户此刻到底想完成什么”。因为在那个阶段，交互媒介主要还是屏幕和点击，系统很难在用户开口之前拿到足够多的上下文。([Nielsen Norman Group][1])

到了 **AI + 智能硬件** 时代，第一性变化不是“多了个语音入口”，而是**输入上下文被重写了**。Gemini Live 已经把摄像头和屏幕共享直接带进对话，支持用户边看、边说、边让系统基于眼前环境实时反馈；rabbit 则更直白，它把 r1 定义为向“app-free online experience”迈进的自然语言操作系统，后来又因为纯语音/纯聊天式体验不足以让用户理解能力边界，重做了 rabbitOS 2，用卡片式界面把能力重新显性化。这个信号很关键：**硬件时代不是取消信息架构，而是把信息架构从“页面树”改成“场景树 + 能力树 + 状态树”。** ([android.com][2])

这会带来第一批具体变化。

**第一，入口变了。**
过去的入口是“打开 App，选一个 tab”；现在的入口越来越像“我把眼前世界、设备状态、语音指令、历史记忆一起交给系统”。摄像头、屏幕、麦克风、位置、日历、消息、设备状态，都会成为意图识别的一部分。于是 IA 不再只回答“用户去哪一页”，而要回答“系统现在该理解什么场景”。([android.com][2])

**第二，顶层组织单位变了。**
互联网时代的顶层单位通常是频道、模块、功能页；AI 硬件时代更适合的顶层单位是**场景**，比如通勤、购物、做饭、维修、旅行、陪伴、创作。因为用户在硬件上发出的请求往往不是“打开功能 A”，而是“帮我解决眼前这件事”。这也是为什么 rabbitOS 2 即使主张自然语言，也还是需要把能力做成可浏览的 card stack：用户不是永远知道该问什么，系统必须把“可做之事”组织成可感知的场景入口。([Rabbit][3])

**第三，导航语义变了。**
以前导航主要是空间性的：从首页到二级页，从列表到详情；现在导航越来越时序化：识别意图、确认约束、选择工具、执行步骤、展示结果、继续追问。也就是说，用户不再主要关心“我现在在哪个页面”，而是关心“系统做到第几步了、下一步会不会替我操作”。这正是 agent 时代的前奏。([android.com][2])

进入 **AI Agent** 时代，这个变化进一步加速。OpenAI 对 agents 的定义已经不是聊天机器人，而是能完成从简单目标到复杂开放式工作流的系统；官方文档把 workflow 直接定义为 agents、tools、control-flow logic 的组合；computer use 又进一步说明，模型可以看截图、返回界面动作、通过 UI 操作软件。换句话说，agent 面对的“信息”不只是内容，还包括**工具、权限、环境、执行状态和结果产物**。([OpenAI 开发者][4])

这意味着 IA 在 Agent 时代要从“组织信息”升级为**“组织意图与行动”**。

**第四，产品的核心对象变了。**
以前的对象是 article、video、message、profile、order；现在必须新增一批一等公民：**goal、plan、tool、permission、run、memory、artifact、handoff、guardrail、trace**。OpenAI 的 agents 文档和 SDK 已经把 agent、handoff、guardrail、session、tracing 做成核心原语；治理 cookbook 又强调 production 里的 accountability、oversight 和 observability。对产品来说，这不是工程细节，而是新的 IA 主干。([OpenAI 开发者][5])

**第五，反馈系统变了。**
互联网产品的反馈多半是“页面刷新了 / 结果出来了”；Agent 产品必须持续回答 4 个问题：它在做什么、为什么这样做、用了哪些数据/工具、用户如何中止或接管。没有 trace、step、approval、undo，用户就很难信任一个会行动的系统。OpenAI 官方把 tracing、guardrails、tool calls 放进 agent 基础能力，本质上就是在告诉你：Agent 的 IA 必须把“执行过程”可视化。([OpenAI 开发者][5])

**第六，权限与治理被拉进了主流程。**
在传统 App 里，权限通常是一次性弹窗；在 Agent 产品里，权限会变成流程节点，因为系统不仅“展示信息”，还会“代表用户行动”。治理 cookbook 反复强调 policy、guardrails、observability、centralized enforcement，这说明在 Agent 时代，安全和合规不是外侧附属层，而是 IA 的一部分：用户意图要先经过策略解释，再进入执行。([OpenAI 开发者][6])

把这些变化放回 **Character.AI**，它的问题就看得更清楚了。Character.AI 在 2025–2026 年连续把产品对象做得越来越丰富：Feed 把 Characters、Scenes、Streams、creator videos 放进一个滚动流；Scenes 被定义为短小的角色驱动式 RP 场景；Stories 是结构化、多路径、可 replay 的互动叙事；labs 又成了新格式实验场。官方自己都说，Feed 让 Character.AI 从 chat-centric app 变成 content-driven social platform，labs 的方向则是“AI entertainment platform”。这说明它在对象层已经很丰富了。([Character.AI Blog][7])

但用户来 Character.AI 时，真实意图并不是“我要一个 Scene / 一个 Story / 一个 Stream / 一个 video”。用户的意图通常更像：**我想陪伴、我想 RP、我想刷剧情、我想创作、我想看别人怎么玩、我想快速找到适合我的角色。** 当首页和分发层优先按“内容对象”来组织，而不是按“用户意图”来组织时，就会出现你前面指出的结构问题：对象越来越多，用户反而更难快速进入正确路径；创作者供给越来越丰富，分发却不一定更有效。Feed 的确让内容更可传播，但它并不会自动解决“我此刻到底该去陪聊、创作、刷内容还是进入一个结构化故事”的决策成本。([Character.AI Blog][7])

所以，“信息架构没有围绕用户意图”在今天具体意味着 6 个变化，你可以把它当成一套新的产品方法论：

**1. 从内容分类，变成意图编排。**
先定义 5–8 个稳定高频意图，再把 Characters、Scenes、Stories、videos 这些对象挂到意图下面，而不是反过来。对 Character.AI 来说，顶层应该更像“陪伴 / 角色扮演 / 看内容 / 自己创作 / 继续上次关系”，而不是“Feed / Characters / Stories / Labs”。这个判断来自 Feed、Stories、Scenes 的对象扩张路径。([Character.AI Blog][7])

**2. 从页面树，变成任务树。**
互联网 IA 解决的是用户去哪；Agent IA 解决的是系统先做什么、后做什么。顶层导航会越来越少地按页面切，而更多地按“当前任务阶段”切，比如发现、确认、执行、回看。Computer use 和 agents workflow 都已经把 UI 操作与控制流绑定在一起了。([OpenAI 开发者][4])

**3. 从单设备单会话，变成跨设备连续上下文。**
AI+硬件和 Agent 都要求系统记住用户刚刚看到了什么、说了什么、授权了什么、做到哪一步了。IA 要组织的不再只是页面状态，而是跨回合 session 和 memory。OpenAI 的 Responses / Agents 路线已经把 stateful conversation、session、tool context 作为基础设施。([OpenAI 开发者][5])

**4. 从“结果可见”，变成“过程可见”。**
以前看一个结果页就够了；现在要把 plan、tool call、handoff、guardrail trigger、artifact 都显性化，否则用户无法判断 agent 是否偏航。tracing 之所以成为官方能力，是因为 Agent 产品的核心体验不只是答案质量，还有过程可信度。([OpenAI 开发者][5])

**5. 从功能发现，变成能力解释。**
AI 硬件一个典型难题是：用户不知道系统能做什么，也不知道该怎么提问。rabbitOS 2 回到 card-based 设计，本质就是在补“能力可感知性”。所以未来 IA 不只负责把内容摆好，还要负责让用户理解系统的能力边界、触发条件和最佳用法。([Rabbit][3])

**6. 从“流量分发架构”，变成“意图转化架构”。**
在内容平台里，你优化点击率；在 Agent / AI 娱乐产品里，你更该优化“这个入口是否让用户更快到达正确意图并形成下一步行为”。对 Character.AI，这意味着不该只看 Feed 消费，还要看 Feed 到开聊、开聊到关系沉淀、创作到复玩、对象浏览到长期会话的转化链。Feed 官方强调 every post is an invitation to interact, remix, and build，这恰好说明它真正要优化的不是曝光，而是**从内容对象到意图行动的转换**。([Character.AI Blog][7])

我最后给一个 VP 级结论：

**互联网时代，信息架构的核心是“把信息放在哪”；AI+智能硬件时代，核心变成“在什么场景下触发什么能力”；AI Agent 时代，核心进一步变成“围绕用户意图组织目标、工具、权限、执行和反馈”。**
谁还停留在“页面 / 栏目 / 内容对象”这套旧骨架上，谁就会出现 Character.AI 现在这种现象：对象越来越多，产品越来越热闹，但用户真正的高频意图并没有被组织成最短路径。([Nielsen Norman Group][1])

我可以下一步直接把这套分析落成一份 **“AI Agent 时代的信息架构重构框架”**，按首页、导航、推荐、记忆、权限、商业化 6 个模块给你展开。

[1]: https://www.nngroup.com/articles/ia-vs-navigation/ "The Difference Between Information Architecture (IA) and Navigation - NN/G"
[2]: https://www.android.com/articles/gemini-on-android/ "Gemini Live: Use Camera & Screen Sharing on Android | Android"
[3]: https://www.rabbit.tech/newsroom/rabbitos-2-launch?srsltid=AfmBOopWQvXU5eLzbLDLT8JSux2if8EMFe7hvrQnPcaUBL6LYHytZRLJ "rabbit overhauls r1 experience with rabbitOS 2"
[4]: https://developers.openai.com/api/docs/guides/agents/ "Agents | OpenAI API"
[5]: https://developers.openai.com/tracks/building-agents/ "Building agents"
[6]: https://developers.openai.com/cookbook/examples/partners/agentic_governance_guide/agentic_governance_cookbook/ "Building Governed AI Agents - A Practical Guide to Agentic Scaffolding"
[7]: https://blog.character.ai/character-ai-launches-worlds-first-ai-native-social-feed/ "Character.AI Launches World’s First AI-Native Social Feed"
