import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/device.dart';

class LightSchedulePage extends ConsumerWidget {
  final LightDevice device;

  const LightSchedulePage({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('光照自动化计划', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Adaptive Lighting Engine (Bio-Lighting)
            _buildBioLightingHero(theme),
            const SizedBox(height: 32),

            // 2. 24h Light Schedule
            Text('全天光照计划', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildScheduleItem('07:30', '日出唤醒', '模拟晨光，亮度渐亮至 80%', Icons.wb_sunny, Colors.orangeAccent),
            const SizedBox(height: 12),
            _buildScheduleItem('09:00', '专注模式', '高色温冷白光，提升专注力', Icons.work_outline, Colors.lightBlueAccent),
            const SizedBox(height: 12),
            _buildScheduleItem('18:00', '温馨晚餐', '中性暖光，营造放松氛围', Icons.restaurant, Colors.amberAccent),
            const SizedBox(height: 12),
            _buildScheduleItem('22:00', '静谧助眠', '低色温琥珀光，抑制褪黑素流失', Icons.nightlight_round, Colors.deepOrangeAccent),
            const SizedBox(height: 32),

            // 3. Sensor Linkage
            Text('传感器联动', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildLinkageCard('入室即亮', '环境光传感器检测到低亮度时自动开启', Icons.sensors, true),
            const SizedBox(height: 12),
            _buildLinkageCard('无人自动熄灭', '雷达检测到区域内 5 分钟无体动后关闭', Icons.radar, true),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildBioLightingHero(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orangeAccent.withOpacity(0.1), Colors.indigoAccent.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('生物钟同步引擎', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('根据当地日照时间自动调节色温', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
              Switch(value: true, onChanged: (val) {}, activeColor: Colors.orangeAccent),
            ],
          ),
          const SizedBox(height: 24),
          // Visualization
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: const LinearGradient(
                colors: [Colors.orangeAccent, Colors.white, Colors.indigoAccent, Colors.deepOrangeAccent],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('清晨', style: TextStyle(color: Colors.white38, fontSize: 10)),
              const Text('正午', style: TextStyle(color: Colors.white38, fontSize: 10)),
              const Text('夜晚', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String time, String title, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.white24, size: 20),
        ],
      ),
    );
  }

  Widget _buildLinkageCard(String title, String desc, IconData icon, bool enabled) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigoAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Switch(value: enabled, onChanged: (val) {}, activeColor: Colors.indigoAccent),
        ],
      ),
    );
  }
}
