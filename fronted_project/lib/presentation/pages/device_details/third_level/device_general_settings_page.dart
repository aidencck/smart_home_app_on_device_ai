import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/device.dart';

class DeviceGeneralSettingsPage extends ConsumerWidget {
  final SmartDevice device;

  const DeviceGeneralSettingsPage({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('设备管理', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Device Info Header
            _buildInfoHeader(),
            const SizedBox(height: 32),

            // 2. Settings Sections
            _buildSectionHeader('常规设置'),
            _buildSettingTile('设备名称', device.name, Icons.edit_outlined),
            _buildSettingTile('所属房间', device.room, Icons.room_outlined),
            _buildSettingTile('设备共享', '3 人已加入', Icons.share_outlined),
            const SizedBox(height: 32),

            _buildSectionHeader('连接与维护'),
            _buildSettingTile('固件更新', '当前版本: v1.2.4', Icons.system_update_outlined, trailing: const Text('检查更新', style: TextStyle(color: Colors.indigoAccent, fontSize: 12))),
            _buildSettingTile('信号强度', '-42 dBm (极佳)', Icons.wifi_outlined),
            _buildSettingTile('设备日志', '查看运行记录', Icons.list_alt_outlined),
            const SizedBox(height: 32),

            _buildSectionHeader('高级选项'),
            _buildSettingTile('指示灯开关', '开启', Icons.light_mode_outlined, trailing: const Switch(value: true, onChanged: null)),
            _buildSettingTile('隐私保护模式', '关闭', Icons.security_outlined, trailing: const Switch(value: false, onChanged: null)),
            const SizedBox(height: 48),

            // 3. Dangerous Actions
            Center(
              child: TextButton(
                onPressed: () {
                  // Show confirm dialog
                },
                child: const Text('解绑并删除设备', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(device.icon, size: 50, color: Colors.indigoAccent),
          ),
          const SizedBox(height: 16),
          Text(device.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(device.id, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSettingTile(String title, String value, IconData icon, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          trailing ?? const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
        ],
      ),
    );
  }
}
