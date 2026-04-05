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

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        // 1. 用户信息卡片
        Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: const NetworkImage(
                'https://api.dicebear.com/7.x/avataaars/png?seed=Felix',
              ),
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aiden',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.diamond,
                          size: 14,
                          color: colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pro 会员',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 32),

        // 2. 数据概览面板
        Row(
          children: [
            Expanded(child: _buildStatCard(context, '设备', '6', Icons.devices)),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(context, '场景', '5', Icons.auto_awesome),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(context, '自动化', '3', Icons.rule)),
          ],
        ),
        const SizedBox(height: 32),

        // 3. 核心功能区 (M3 Card 分组)
        Text(
          '核心管理',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: colorScheme.surfaceContainerLow,
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _buildListTile(
                context: context,
                icon: Icons.home_outlined,
                title: '家庭与房间管理',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeManagementPage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildListTile(
                context: context,
                icon: Icons.hub_outlined,
                title: '网关与 Matter 集成',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GatewayIntegrationPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 4. 服务与设置区
        Text(
          '服务与设置',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: colorScheme.surfaceContainerLow,
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _buildListTile(
                context: context,
                icon: Icons.notifications_outlined,
                title: '通知与告警中心',
                color: Colors.redAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationCenterPage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildListTile(
                context: context,
                icon: Icons.cloud_outlined,
                title: '云存储服务',
                subtitle: '摄像头云端回放',
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CloudStoragePage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildListTile(
                context: context,
                icon: Icons.settings_outlined,
                title: '通用设置',
                color: colorScheme.onSurfaceVariant,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GeneralSettingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String count,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }
}

// --- 二级界面：家庭管理 (Home Management) ---
