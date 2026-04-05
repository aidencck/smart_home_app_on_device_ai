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

class NotificationCenterPage extends ConsumerWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '通知与告警',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
        actions: [TextButton(onPressed: () {}, child: const Text('全部已读'))],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        separatorBuilder: (context, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final alerts = [
            {
              'title': '门锁异常打开',
              'time': '10 分钟前',
              'icon': Icons.lock_open,
              'color': Colors.red,
            },
            {
              'title': '检测到客厅有人移动',
              'time': '2 小时前',
              'icon': Icons.directions_walk,
              'color': Colors.orange,
            },
            {
              'title': '固件更新可用',
              'time': '昨天',
              'icon': Icons.system_update,
              'color': Colors.blue,
            },
          ];
          final alert = alerts[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  alert['icon'] as IconData,
                  color: alert['color'] as Color,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert['time'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- 二级界面：云存储服务 ---
