import '../../application/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:on_device_agent/on_device_agent.dart';
import '../../models/device.dart';
import '../../models/automation.dart';
import '../../services/device_service.dart';
import '../../services/virtual_device_service.dart';
import '../../theme/figma_colors.dart';
import '../../features/agent/fallback_intent_service.dart';
import '../../application/application.dart';
import '../../application/automation_provider.dart';
import '../widgets/widgets.dart';
import '../pages/pages.dart';
import '../../main.dart'; // for global variables if needed

IconData _getIconData(String iconName) {
  switch (iconName) {
    case 'nights_stay': return Icons.nights_stay;
    case 'wb_sunny': return Icons.wb_sunny;
    case 'wb_twilight': return Icons.wb_twilight;
    case 'sensor_door': return Icons.sensor_door;
    case 'bedtime': return Icons.bedtime;
    default: return Icons.auto_awesome;
  }
}

class AutomationsPage extends ConsumerWidget {
  const AutomationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final automations = ref.watch(automationProvider);

    final recommendedAutomations = automations.where((a) => a.isRecommended).toList();
    final enabledAutomations = automations.where((a) => !a.isRecommended).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('自动化', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.indigoAccent, size: 20),
              const SizedBox(width: 8),
              const Text(
                'AI 推荐自动化',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recommendedAutomations.map((a) => _buildRecommendationCard(a, colorScheme, ref)),
          const SizedBox(height: 32),
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.amberAccent, size: 20),
              const SizedBox(width: 8),
              const Text(
                '已启用自动化',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...enabledAutomations.map((a) => _buildEnabledCard(a, colorScheme, ref)),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(SmartAutomation data, ColorScheme colorScheme, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.indigoAccent.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigoAccent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIconData(data.icon), color: Colors.indigoAccent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                ref.read(automationProvider.notifier).acceptRecommendation(data.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                foregroundColor: Colors.white,
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

  Widget _buildEnabledCard(SmartAutomation data, ColorScheme colorScheme, WidgetRef ref) {
    final isFail = data.error != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isFail ? Colors.redAccent.withOpacity(0.05) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFail ? Colors.redAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFail ? Colors.redAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(data.icon),
                color: isFail ? Colors.redAccent : Colors.white70,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(
                      color: isFail ? Colors.redAccent : Colors.white,
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
                        color: isFail ? Colors.redAccent : Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isFail ? '执行失败 (${data.error})' : '上次执行: ${data.lastRun}',
                        style: TextStyle(
                          color: isFail ? Colors.redAccent : Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: data.isEnabled,
              activeColor: Colors.amberAccent,
              onChanged: (val) {
                ref.read(automationProvider.notifier).toggleAutomation(data.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

