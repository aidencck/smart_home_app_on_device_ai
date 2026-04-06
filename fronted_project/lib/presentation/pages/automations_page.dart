import '../../application/providers.dart';
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
import '../widgets/widgets.dart';
import '../pages/pages.dart';
import '../../main.dart'; // for global variables if needed

class AutomationsPage extends ConsumerWidget {
  const AutomationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final recommendedAutomations = [
      {'title': '检测到入睡，自动关闭所有灯光', 'description': '基于生理作息识别', 'icon': Icons.nights_stay},
      {'title': '早晨光线唤醒', 'description': '根据作息基线推荐', 'icon': Icons.wb_sunny},
    ];

    final enabledAutomations = [
      {'title': '日落时开启客厅灯', 'status': 'success', 'lastRun': '18:30', 'icon': Icons.wb_twilight},
      {'title': '离家后关闭所有设备', 'status': 'fail', 'lastRun': '08:15', 'error': '网关离线', 'icon': Icons.sensor_door},
      {'title': '22:30 进入睡眠模式', 'status': 'success', 'lastRun': '昨晚 22:30', 'icon': Icons.bedtime},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'AI 推荐自动化',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        ...recommendedAutomations.map((a) => _buildRecommendationCard(a, colorScheme)),
        const SizedBox(height: 32),
        Text(
          '已启用自动化',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...enabledAutomations.map((a) => _buildEnabledCard(a, colorScheme)),
      ],
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> data, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: colorScheme.primaryContainer.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(data['icon'] as IconData, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] as String,
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['description'] as String,
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('启用'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnabledCard(Map<String, dynamic> data, ColorScheme colorScheme) {
    final isFail = data['status'] == 'fail';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: isFail ? colorScheme.errorContainer.withOpacity(0.5) : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isFail ? colorScheme.error.withOpacity(0.5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFail ? colorScheme.error.withOpacity(0.2) : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                data['icon'] as IconData,
                color: isFail ? colorScheme.error : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] as String,
                    style: TextStyle(
                      color: isFail ? colorScheme.onErrorContainer : colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isFail ? Icons.error_outline : Icons.check_circle_outline,
                        size: 14,
                        color: isFail ? colorScheme.error : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isFail ? '执行失败 (${data['error']})' : '上次执行: ${data['lastRun']}',
                        style: TextStyle(
                          color: isFail ? colorScheme.error : colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: true,
              activeColor: colorScheme.primary,
              onChanged: (val) {},
            ),
          ],
        ),
      ),
    );
  }
}

