import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/ai_recommendation.dart';
import '../../services/ai_recommendation_service.dart';
import '../../application/auth/auth_provider.dart';
import '../../application/providers.dart';
import '../../application/system_state_machine.dart';
import '../widgets/skeleton_card.dart';

// --- Providers ---
final aiRecommendationServiceProvider = Provider<AiRecommendationService>((
  ref,
) {
  return AiRecommendationService();
});

class AiRecommendationsNotifier extends AsyncNotifier<List<AiRecommendation>> {
  @override
  Future<List<AiRecommendation>> build() async {
    final token = ref.watch(authProvider).token;
    if (token == null) return [];
    final service = ref.read(aiRecommendationServiceProvider);
    return service.getRecommendations(token);
  }

  Future<void> accept(String id) async {
    final token = ref.read(authProvider).token;
    if (token == null) return;

    final service = ref.read(aiRecommendationServiceProvider);
    await service.acceptRecommendation(id, token);
    // Refresh the list after successful acceptance
    ref.invalidateSelf();
  }

  Future<void> ignore(String id) async {
    final token = ref.read(authProvider).token;
    if (token == null) return;

    // 乐观更新 UI 状态
    state = state.whenData((recommendations) {
      return recommendations.map<AiRecommendation>((r) {
        if (r.id == id) {
          return AiRecommendation(
            id: r.id,
            userId: r.userId,
            title: r.title,
            description: r.description,
            status: 'ignored',
            actionPayload: r.actionPayload,
          );
        }
        return r;
      }).toList();
    });

    try {
      final service = ref.read(aiRecommendationServiceProvider);
      await service.rejectRecommendation(id, token);
    } catch (e) {
      // 失败则恢复状态
      ref.invalidateSelf();
      throw Exception('Failed to ignore recommendation: $e');
    }
  }
}

final aiRecommendationsProvider =
    AsyncNotifierProvider<AiRecommendationsNotifier, List<AiRecommendation>>(
      () {
        return AiRecommendationsNotifier();
      },
    );

// --- UI Screen ---
class AiRecommendationScreen extends ConsumerWidget {
  const AiRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final systemState = ref.watch(systemStateMachineProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'AI 建议采纳中心',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            _buildStateBadge(systemState),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F172A), // slate-900
              const Color(0xFF1E1B4B), // indigo-950
              const Color(0xFF000000), // black
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildInsightsCard(colorScheme),
            const SizedBox(height: 24),
            _buildBaselineCard(colorScheme),
            const SizedBox(height: 24),
            _buildRecommendationSection(context, ref, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日洞察',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.insights, size: 32, color: colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '您昨晚比平时晚睡了 45 分钟，且起夜 2 次。建议今晚提早 30 分钟开启睡眠环境，并将灯光调暗。',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBaselineCard(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '作息基线识别',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildBaselineRow(
                  '入睡时间',
                  '23:30 - 00:00',
                  Icons.bedtime,
                  colorScheme,
                ),
                Divider(height: 32, color: Colors.white.withOpacity(0.1)),
                _buildBaselineRow(
                  '晨起时间',
                  '07:00 - 07:30',
                  Icons.wb_sunny,
                  colorScheme,
                ),
                Divider(height: 32, color: Colors.white.withOpacity(0.1)),
                _buildBaselineRow('午休习惯', '无', Icons.wb_twilight, colorScheme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBaselineRow(
    String title,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationSection(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
  ) {
    final asyncRecommendations = ref.watch(aiRecommendationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '推荐场景',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: () => ref.invalidate(aiRecommendationsProvider),
              tooltip: '刷新',
            ),
          ],
        ),
        const SizedBox(height: 12),
        asyncRecommendations.when(
          data: (recommendations) {
            if (recommendations.isEmpty) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      '暂无推荐建议',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: recommendations
                  .map(
                    (r) =>
                        _buildRecommendationCard(context, ref, colorScheme, r),
                  )
                  .toList(),
            );
          },
          loading: () => const Column(
            children: [
              SkeletonCard(height: 160),
              SizedBox(height: 16),
              SkeletonCard(height: 160),
            ],
          ),
          error: (error, stack) => _buildErrorCard(context, ref, error),
        ),
      ],
    );
  }

  Widget _buildStateBadge(SystemStateMachine stateMachine) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: stateMachine.stateThemeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stateMachine.stateThemeColor.withOpacity(0.5)),
      ),
      child: Text(
        stateMachine.stateName,
        style: TextStyle(
          color: stateMachine.stateThemeColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, WidgetRef ref, Object error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          const Text(
            '获取建议失败',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(aiRecommendationsProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    AiRecommendation recommendation,
  ) {
    final isAccepted = recommendation.status == 'accepted';
    final isIgnored = recommendation.status == 'ignored';

    if (isIgnored) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                '已忽略当前建议',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ),
          ),
        ),
      );
    }

    final title = recommendation.title;
    final subtitle = recommendation.actionPayload['subtitle'] as String? ?? '根据您的习惯自动生成';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: isAccepted
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isAccepted
                ? colorScheme.primary.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: isAccepted
                  ? colorScheme.primary.withOpacity(0.2)
                  : Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isAccepted
                          ? colorScheme.primary.withOpacity(0.2)
                          : Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: isAccepted
                          ? colorScheme.primary
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAccepted)
                    Icon(Icons.check_circle, color: colorScheme.primary),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                recommendation.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
              if (!isAccepted) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          try {
                            await ref
                                .read(aiRecommendationsProvider.notifier)
                                .ignore(recommendation.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已忽略该建议')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('忽略失败')),
                              );
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('忽略'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          try {
                            await ref
                                .read(aiRecommendationsProvider.notifier)
                                .accept(recommendation.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已成功采纳建议')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(const SnackBar(content: Text('采纳失败')));
                            }
                          }
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('采纳', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
