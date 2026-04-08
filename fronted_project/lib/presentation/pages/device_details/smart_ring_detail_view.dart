import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/device.dart';
import '../../../application/providers.dart';
import 'third_level/sleep_report_page.dart';

class SmartRingDetailView extends ConsumerStatefulWidget {
  final SmartRingDevice device;

  const SmartRingDetailView({super.key, required this.device});

  @override
  ConsumerState<SmartRingDetailView> createState() => _SmartRingDetailViewState();
}

class _SmartRingDetailViewState extends ConsumerState<SmartRingDetailView>
    with SingleTickerProviderStateMixin {
  late AnimationController _haloController;

  @override
  void initState() {
    super.initState();
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _haloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ring = widget.device;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Breathing Halo & Readiness Score
          _buildHeroSection(ring),
          const SizedBox(height: 48),

          // 2. Health Metrics Grid
          Text(
            '实时生理指标',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _buildMetricCard('睡眠分期', _getSleepStageName(ring.sleepStage), Icons.bedtime, Colors.purpleAccent),
              _buildMetricCard('HRV', '${ring.hrv} ms', Icons.query_stats, Colors.orangeAccent),
              _buildMetricCard('血氧饱和度', '${ring.spo2}%', Icons.opacity, Colors.lightBlueAccent),
              _buildMetricCard('电池状态', '${ring.batteryLevel}%', Icons.battery_charging_full, Colors.greenAccent),
            ],
          ),
          const SizedBox(height: 32),

          // 3. Sleep Stage Analysis
          _buildSleepAnalysisSection(theme),
          const SizedBox(height: 32),

          // 4. Detailed Report Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('查看详细睡眠报告'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SleepReportPage(device: ring),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildHeroSection(SmartRingDevice ring) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Breathing Halo
          AnimatedBuilder(
            animation: _haloController,
            builder: (context, child) {
              return Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigoAccent.withOpacity(0.2 * _haloController.value),
                      blurRadius: 40 + (20 * _haloController.value),
                      spreadRadius: 10 + (10 * _haloController.value),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              );
            },
          ),
          // Readiness Circular Indicator
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: ring.readinessScore / 100,
              strokeWidth: 12,
              backgroundColor: Colors.white.withOpacity(0.05),
              color: Colors.cyanAccent,
              strokeCap: StrokeCap.round,
            ),
          ),
          // Center Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${ring.readinessScore}',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
              const Text(
                '准备度评分',
                style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${ring.heartRate} BPM',
                    style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepAnalysisSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '睡眠结构分析',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '昨晚 7h 24m',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Glassmorphism Card
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  // Stage Bar
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        children: [
                          Expanded(flex: 15, child: Container(color: Colors.orangeAccent)), // Awake
                          Expanded(flex: 25, child: Container(color: Colors.lightBlueAccent)), // REM
                          Expanded(flex: 40, child: Container(color: Colors.indigoAccent)), // Light
                          Expanded(flex: 20, child: Container(color: Colors.deepPurpleAccent)), // Deep
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStageLegend('清醒', '15%', Colors.orangeAccent),
                      _buildStageLegend('REM', '25%', Colors.lightBlueAccent),
                      _buildStageLegend('浅睡', '40%', Colors.indigoAccent),
                      _buildStageLegend('深睡', '20%', Colors.deepPurpleAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStageLegend(String label, String percent, Color color) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Text(percent, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _getSleepStageName(String stage) {
    switch (stage.toUpperCase()) {
      case 'AWAKE': return '清醒中';
      case 'LIGHT': return '浅睡眠';
      case 'DEEP': return '深睡眠';
      case 'REM': return '快速动眼';
      default: return '检测中';
    }
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
