import '../../application/providers.dart';
import '../../application/auth/auth_provider.dart';
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

class GeneralSettingsPage extends ConsumerWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '通用设置',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('深色模式'),
                  trailing: Text(
                    '跟随系统',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('语言与地区'),
                  trailing: Text(
                    '简体中文',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.update),
                  title: const Text('检查更新'),
                  trailing: Text(
                    '已是最新',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                '退出登录',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                ref.read(authProvider.notifier).logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- 独立的 Agent 交互界面 ---
