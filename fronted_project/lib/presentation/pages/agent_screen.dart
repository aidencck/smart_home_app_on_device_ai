import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:on_device_agent/on_device_agent.dart';
import '../../models/device.dart';
import '../../services/device_service.dart';
import '../../services/virtual_device_service.dart';
import '../../theme/figma_colors.dart';
import '../../features/agent/fallback_intent_service.dart';
import '../../application/application.dart';
import '../../application/providers.dart';
import '../widgets/widgets.dart';
import '../pages/pages.dart';
import '../../main.dart'; // for global variables if needed

class AgentScreen extends ConsumerStatefulWidget {
  const AgentScreen({super.key});

  @override
  ConsumerState<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends ConsumerState<AgentScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isListening = false; // 语音状态

  bool _isProcessingStepsExpanded = true;
  double _processingStepsFontSize = 12.0;

  @override
  void initState() {
    super.initState();
    // 添加监听，当 agentManager 状态改变时刷新 UI
    ref.read(agentManagerProvider).addListener(_onAgentUpdate);
    // 首次进入时可能已经有消息了，滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    ref.read(agentManagerProvider).removeListener(_onAgentUpdate);
    super.dispose();
  }

  void _onAgentUpdate() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  Future<void> _handleSendMessage(String text) async {
    if (text.isEmpty) return;
    _textController.clear();
    await ref.read(agentManagerProvider).handleSendMessage(text);
  }

  void _toggleVoiceInput() async {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      // 模拟语音录入 UI 状态
      ref.watch(agentManagerProvider).chatHistory.add({
        "role": "system",
        "text": "🎙️ 正在聆听 (端侧 ASR 识别中)...",
        "isVoiceIndicator": true,
      });
      

      // 模拟录音和端侧 ASR (Whisper) 转换时间
      await Future.delayed(const Duration(seconds: 2));

      // 移除聆听指示器
      ref.watch(agentManagerProvider).chatHistory.removeWhere((msg) => msg['isVoiceIndicator'] == true);
      
      setState(() {
        _isListening = false;
      });
      

      // 模拟 ASR 识别结果并直接发送
      final asrResult = "帮我把主卧空调温度调高一点";
      _textController.text = asrResult;
      // 稍微停留一下让用户看到识别结果
      await Future.delayed(const Duration(milliseconds: 500));
      _handleSendMessage(asrResult);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildWelcomeLoading() {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.smart_toy,
                        size: 32,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "正在唤醒端侧大模型...",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "您可以直接输入指令，就绪后将立即执行",
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "我是您的专属 AI 助手",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "您可以尝试对我说：",
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _buildCapabilityCard(Icons.thermostat, "帮我把主卧空调温度调高一点"),
              const SizedBox(height: 12),
              _buildCapabilityCard(Icons.lightbulb_outline, "离开房间，关掉所有设备"),
              const SizedBox(height: 12),
              _buildCapabilityCard(Icons.movie_outlined, "我想看电影，帮我准备一下"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapabilityCard(IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _textController.text = text;
          _handleSendMessage(text);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "“$text”",
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCommands() {
    final commands = ["我有点冷", "看电影", "出门模式", "打扫一下", "关掉它", "调高一点"];
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: commands.length,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(
              commands[index],
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            onPressed: () {
              _textController.text = commands[index];
              _handleSendMessage(commands[index]);
            },
            backgroundColor: colorScheme.surfaceContainerHigh,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProcessingSteps() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isProcessingStepsExpanded = !_isProcessingStepsExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "AI 正在执行...",
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Font size controls
                  if (_isProcessingStepsExpanded) ...[
                    IconButton(
                      icon: const Icon(Icons.text_decrease, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _processingStepsFontSize = (_processingStepsFontSize - 2).clamp(10.0, 24.0);
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.text_increase, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _processingStepsFontSize = (_processingStepsFontSize + 2).clamp(10.0, 24.0);
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    _isProcessingStepsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          
          // Steps list
          if (_isProcessingStepsExpanded && ref.watch(agentManagerProvider).processingSteps.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 44.0, right: 16.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ref.watch(agentManagerProvider).processingSteps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isLast = index == ref.watch(agentManagerProvider).processingSteps.length - 1;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isLast ? Icons.pending_outlined : Icons.check_circle,
                          size: _processingStepsFontSize + 4,
                          color: isLast ? colorScheme.primary : colorScheme.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step,
                            style: TextStyle(
                              fontSize: _processingStepsFontSize,
                              color: isLast ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // 聊天记录展示区
        if (ref.read(agentManagerProvider).isInitializing && ref.watch(agentManagerProvider).chatHistory.isEmpty)
          _buildWelcomeLoading()
        else if (ref.watch(agentManagerProvider).chatHistory.isEmpty)
          _buildEmptyState()
        else
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: ref.watch(agentManagerProvider).chatHistory.length,
              itemBuilder: (context, index) {
                final msg = ref.watch(agentManagerProvider).chatHistory[index];
                final role = msg['role'];
                final text = msg['text'];

                if (role == 'system') {
                  return _buildSystemMessage(text);
                }

                return _buildChatMessage(msg);
              },
            ),
          ),

        // 处理中的思考动画及进度
        if (ref.watch(agentManagerProvider).isProcessing)
          _buildProcessingSteps(),

        // 快捷指令推荐
        if (!ref.read(agentManagerProvider).isInitializing && !ref.watch(agentManagerProvider).isProcessing) _buildQuickCommands(),

        // 底部输入区
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          decoration: BoxDecoration(color: colorScheme.surfaceContainer),
          child: SafeArea(
            child: Row(
              children: [
                // 语音输入按钮
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening
                        ? colorScheme.error
                        : colorScheme.primary,
                  ),
                  onPressed: (ref.read(agentManagerProvider).isInitializing || ref.watch(agentManagerProvider).isProcessing)
                      ? null
                      : _toggleVoiceInput,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: TextField(
                        controller: _textController,
                        enabled: !ref.watch(agentManagerProvider).isProcessing,
                        decoration: InputDecoration(
                          hintText: ref.read(agentManagerProvider).isInitializing
                              ? 'AI唤醒中，您可以直接输入...'
                              : '输入指令 (如: 我有点冷)',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: _handleSendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 发送按钮
                  IconButton.filled(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: ref.watch(agentManagerProvider).isProcessing
                        ? null
                        : () => _handleSendMessage(_textController.text.trim()),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemMessage(String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> msg) {
    final role = msg['role'];
    final text = msg['text'];
    final devices = msg['devices'] as List<SmartDevice>?;
    final beforeState = msg['beforeState'] as SmartDevice?;
    final afterState = msg['afterState'] as SmartDevice?;
    final metrics = msg['metrics'] as PerformanceMetrics?;
    final steps = msg['steps'] as List<String>?;
    
    final isProactive = msg['isProactive'] == true;
    final suggestionAction = msg['suggestionAction'] as String?;
    final isUser = role == 'user';
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser
                  ? colorScheme.primaryContainer
                  : (isProactive
                        ? colorScheme.secondaryContainer
                        : colorScheme.surfaceContainer),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 20),
              ),
              border: isProactive
                  ? Border.all(
                      color: colorScheme.secondary.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isProactive)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "主动推荐",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // 展示思维链步骤 (如果存在)
                if (!isUser && steps != null && steps.isNotEmpty) ...[
                  ExpansionTile(
                    title: Row(
                      children: [
                        Icon(Icons.psychology, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          "执行步骤",
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 12.0),
                    iconColor: colorScheme.primary,
                    collapsedIconColor: colorScheme.onSurfaceVariant,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: steps.map((step) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: colorScheme.tertiary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    step,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                ],

                Text(
                  text,
                  style: TextStyle(
                    color: isUser
                        ? colorScheme.onPrimaryContainer
                        : (isProactive
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurface),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                if (beforeState != null && afterState != null) ...[
                  const SizedBox(height: 12),
                  Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  Text(
                    "状态变化",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildStateChip(beforeState, colorScheme),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.arrow_forward, size: 16, color: colorScheme.onSurfaceVariant),
                      ),
                      _buildStateChip(afterState, colorScheme, isAfter: true),
                    ],
                  ),
                ],
                if (isProactive && suggestionAction != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: OutlinedButton(
                      onPressed: () {
                        _textController.text = "执行$suggestionAction";
                        _handleSendMessage("执行$suggestionAction");
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.secondary,
                        side: BorderSide(color: colorScheme.secondary),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 36),
                      ),
                      child: Text("一键执行", style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                if (!isUser && kDebugMode && metrics != null)
                  _buildMetricsPanel(metrics, colorScheme),
              ],
            ),
          ),
          if (devices != null && devices.isNotEmpty && !isUser && beforeState == null)
            Container(
              margin: const EdgeInsets.only(bottom: 16, left: 4),
              height: 120, // 稍微增加高度以适应可能有更多内容的卡片
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: devices.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return SizedBox(
                    width: 180, // 增加宽度以提供更好的阅读体验
                    child: ListenableBuilder(
                      listenable: ref.read(deviceManagerProvider),
                      builder: (context, child) {
                        return DeviceCard(
                          device: device,
                          onTap: () => ref.read(deviceManagerProvider).toggleDevice(
                            device.id,
                          ),
                          onMoreTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => DeviceDetailSheet(
                                deviceId: device.id,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStateChip(SmartDevice state, ColorScheme colorScheme, {bool isAfter = false}) {
    final isOn = state.isOn == true;
    int? temp;
    if (state is HasTemperature) {
      temp = (state as HasTemperature).temperature;
    }
    
    String stateText = isOn ? "开启" : "关闭";
    if (isOn && temp != null) {
      stateText += " ($temp°C)";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAfter ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAfter ? colorScheme.primary : Colors.transparent,
          width: 1,
        )
      ),
      child: Text(
        stateText,
        style: TextStyle(
          fontSize: 12,
          color: isAfter ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildMetricsPanel(PerformanceMetrics metrics, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, size: 14, color: colorScheme.tertiary),
              const SizedBox(width: 4),
              Text(
                "性能追踪 (Debug 专供)",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildMetricRow("端侧推理耗时:", "${metrics.inferenceTimeMs} ms", colorScheme),
          _buildMetricRow("全链路总耗时:", "${metrics.totalTimeMs} ms", colorScheme),
          _buildMetricRow("生成速度:", "${metrics.tokensPerSecond.toStringAsFixed(1)} tk/s", colorScheme),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
