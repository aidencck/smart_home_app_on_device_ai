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

class ScenesPage extends ConsumerWidget {
  const ScenesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> scenes = [
      {
        'title': '回家模式',
        'subtitle': '开启客厅灯、空调',
        'icon': Icons.home_filled,
        'color': Colors.blue,
      },
      {
        'title': '离家模式',
        'subtitle': '关闭所有设备，开启安防',
        'icon': Icons.directions_walk,
        'color': Colors.orange,
      },
      {
        'title': '观影模式',
        'subtitle': '关闭主灯，开启电视',
        'icon': Icons.movie,
        'color': Colors.purple,
      },
      {
        'title': '睡眠模式',
        'subtitle': '关闭所有灯光，空调静音',
        'icon': Icons.nights_stay,
        'color': Colors.indigo,
      },
      {
        'title': '阅读模式',
        'subtitle': '开启书房台灯',
        'icon': Icons.menu_book,
        'color': Colors.teal,
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: scenes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final scene = scenes[index];
        final colorScheme = Theme.of(context).colorScheme;
        return Card(
          elevation: 0,
          color: colorScheme.surfaceContainerHighest,
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已执行：${scene['title']}'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (scene['color'] as MaterialColor).withValues(
                        alpha: 0.2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      scene['icon'] as IconData,
                      color: scene['color'] as Color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scene['title'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          scene['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('已执行：${scene['title']}'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('执行'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

