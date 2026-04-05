import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- State Management ---
enum RecommendationStatus { pending, accepted, ignored }

class RecommendationNotifier extends StateNotifier<RecommendationStatus> {
  RecommendationNotifier() : super(RecommendationStatus.pending);

  void accept() {
    state = RecommendationStatus.accepted;
  }

  void ignore() {
    state = RecommendationStatus.ignored;
  }
}

// 占位符：管理点击“采纳”或“忽略”后的状态变更
final recommendationProvider = StateNotifierProvider<RecommendationNotifier, RecommendationStatus>((ref) {
  return RecommendationNotifier();
});

// --- UI Screen ---
class AiRecommendationScreen extends ConsumerWidget {
  const AiRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(recommendationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17), // 深色科幻背景
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'AI 智能分析',
          style: TextStyle(
            color: Color(0xFF00E5FF), // 霓虹青色，突出科技感
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF00E5FF)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最新优化建议',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            _buildRecommendationCard(context, ref, status),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, WidgetRef ref, RecommendationStatus status) {
    final isAccepted = status == RecommendationStatus.accepted;
    final isIgnored = status == RecommendationStatus.ignored;

    if (isIgnored) {
      return const Center(
        child: Text(
          '建议已忽略',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2F), // 偏蓝的深色卡片
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          // 采纳后变为绿色边框，否则为科幻蓝边框
          color: isAccepted ? Colors.greenAccent : const Color(0xFF00E5FF).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isAccepted 
                ? Colors.greenAccent.withOpacity(0.15) 
                : const Color(0xFF00E5FF).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isAccepted 
                      ? Colors.greenAccent.withOpacity(0.1) 
                      : const Color(0xFF00E5FF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAccepted ? Icons.check_circle_outline : Icons.psychology,
                  color: isAccepted ? Colors.greenAccent : const Color(0xFF00E5FF),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAccepted ? '配置已生效' : '睡眠环境优化',
                      style: TextStyle(
                        color: isAccepted ? Colors.greenAccent : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Override_Log 数据分析',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            '根据您昨晚的 Override_Log 数据，建议将入睡灯光亮度调低 20%。',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          
          // 底部按钮区域或成功状态展示区
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation, 
                child: SizeTransition(sizeFactor: animation, child: child)
              );
            },
            child: isAccepted
                ? Container(
                    key: const ValueKey('accepted_state'),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.greenAccent, size: 20),
                        SizedBox(width: 8),
                        Text(
                          '智能调节已开启',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    key: const ValueKey('action_buttons'),
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => ref.read(recommendationProvider.notifier).ignore(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white54,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('忽略 (Ignore)'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => ref.read(recommendationProvider.notifier).accept(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E5FF),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 8,
                            shadowColor: const Color(0xFF00E5FF).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '采纳 (Accept)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
