import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeneralSettingsPage extends ConsumerStatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  ConsumerState<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends ConsumerState<GeneralSettingsPage> {
  bool _useFahrenheit = false;
  String _selectedRegion = 'Europe (GDPR)';
  bool _shareDiagnostics = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF14142B),
      appBar: AppBar(
        title: const Text('系统与隐私设置', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('通用设置 (General)'),
          _buildSettingTile(
            title: '温度单位',
            subtitle: _useFahrenheit ? '华氏度 (°F)' : '摄氏度 (°C)',
            trailing: Switch(
              value: _useFahrenheit,
              onChanged: (val) => setState(() => _useFahrenheit = val),
            ),
          ),
          _buildSettingTile(
            title: '应用语言',
            subtitle: '简体中文',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('地区与合规 (Region & Compliance)'),
          _buildSettingTile(
            title: '当前服务地区',
            subtitle: _selectedRegion,
            onTap: () {
              _showRegionPicker();
            },
          ),
          if (_selectedRegion.contains('Europe'))
            _buildInfoCard(
              '已根据欧盟 GDPR 规范启用最高隐私保护。所有生理数据（心率、睡眠阶段）均在端侧 AI 模型中本地处理，不上传云端。',
              Colors.tealAccent,
            ),
          const SizedBox(height: 24),
          _buildSectionHeader('隐私中心 (Privacy Center)'),
          _buildSettingTile(
            title: '诊断与反馈',
            subtitle: '共享脱敏后的故障日志以改进 AI 体验',
            trailing: Switch(
              value: _shareDiagnostics,
              onChanged: (val) => setState(() => _shareDiagnostics = val),
            ),
          ),
          _buildSettingTile(
            title: '导出我的数据',
            subtitle: '下载所有存储在本地的生理与控制记录',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('正在生成数据导出包...')),
              );
            },
          ),
          _buildSettingTile(
            title: '删除所有本地数据',
            subtitle: '将清空所有 AI 训练偏好与设备历史',
            textColor: Colors.redAccent,
            onTap: () {
              _showDeleteConfirm();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF252542),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: textColor ?? Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: Colors.white24) : null),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoCard(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color.withOpacity(0.9), fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showRegionPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('选择您的地区', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildRegionOption('Europe (GDPR)', '最高隐私合规'),
              _buildRegionOption('North America (US)', '全功能体验'),
              _buildRegionOption('Asia Pacific', '低延迟接入'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegionOption(String title, String subtitle) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      onTap: () {
        setState(() => _selectedRegion = title);
        Navigator.pop(context);
      },
    );
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('确定删除吗？', style: TextStyle(color: Colors.white)),
        content: const Text('此操作将清空所有本地 AI 数据且不可恢复。', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定删除', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
