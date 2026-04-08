import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/device.dart';

class BedAdvancedSettingsPage extends ConsumerWidget {
  final SmartBedDevice device;

  const BedAdvancedSettingsPage({super.key, required this.device});

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
        title: const Text('智能床深度配置', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Posture Presets (Zero Gravity, etc.)
            Text('姿态快捷预设', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _buildPresetChip('零重力 (Zero-G)', Icons.air, Colors.indigoAccent),
                _buildPresetChip('止鼾模式', Icons.hearing_disabled, Colors.orangeAccent),
                _buildPresetChip('观影模式', Icons.movie_outlined, Colors.purpleAccent),
                _buildPresetChip('深度助眠', Icons.nightlight_round, Colors.cyanAccent),
              ],
            ),
            const SizedBox(height: 32),

            // 2. Zone Pressure Adjustment
            Text('分区支撑调节', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPressureCard('肩部支撑', 0.65, Colors.orangeAccent),
            const SizedBox(height: 12),
            _buildPressureCard('腰部支撑', 0.85, Colors.indigoAccent),
            const SizedBox(height: 12),
            _buildPressureCard('腿部支撑', 0.45, Colors.lightBlueAccent),
            const SizedBox(height: 32),

            // 3. Vibration & Haptics
            Text('脉冲震动反馈', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildVibrationCard(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildPressureCard(String title, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: Colors.white10,
              thumbColor: Colors.white,
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              onChanged: (val) {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVibrationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('助眠脉冲', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('模拟缓慢呼吸节奏的轻微震动', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
              Switch(value: true, onChanged: null),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildVibeButton('微弱', false),
              _buildVibeButton('舒适', true),
              _buildVibeButton('强力', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVibeButton(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.indigoAccent : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
    );
  }
}
