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

class CloudStoragePage extends ConsumerWidget {
  const CloudStoragePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '云存储服务',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF334155)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '高级云端回放',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Icon(Icons.cloud_done, color: Colors.greenAccent),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '您的云存储服务将于 2026-10-01 到期',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[600],
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: const Text('立即续费 (享受 8 折优惠)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '服务设备',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            tileColor: Theme.of(context).colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: Icon(
              Icons.videocam,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('客厅摄像头'),
            subtitle: const Text('支持 30 天滚动事件录像'),
            trailing: Switch(value: true, onChanged: (v) {}),
          ),
        ],
      ),
    );
  }
}

// --- 二级界面：通用设置 ---
