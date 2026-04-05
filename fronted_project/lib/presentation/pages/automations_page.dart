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
    final automations = [
      {'title': '日落时开启客厅灯', 'active': true},
      {'title': '离家后关闭所有设备', 'active': true},
      {'title': '22:30 进入睡眠模式', 'active': false},
    ];
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: automations.length,
      itemBuilder: (context, i) {
        final a = automations[i];
        return Card(
          color: colorScheme.surfaceContainerLow,
          margin: const EdgeInsets.only(bottom: 12),
          child: SwitchListTile(
            title: Text(
              a['title'] as String,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            value: a['active'] as bool,
            onChanged: (_) {},
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        );
      },
    );
  }
}

