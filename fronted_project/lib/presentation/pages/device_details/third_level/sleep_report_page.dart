import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/device.dart';

class SleepReportPage extends ConsumerWidget {
  final SmartRingDevice device;

  const SleepReportPage({super.key, required this.device});

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
        title: const Text('睡眠深度洞察', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Sleep Score Hero
            _buildScoreHero(theme),
            const SizedBox(height: 32),

            // 2. Sleep Stages Detailed Chart
            Text('睡眠阶段详解', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSleepStageChart(),
            const SizedBox(height: 32),

            // 3. Physiological Trends (HR & HRV)
            Text('夜间生理趋势', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPhysioTrendCard('心率波动 (BPM)', [65, 62, 58, 60, 55, 52, 54, 58, 62, 65], Colors.redAccent),
            const SizedBox(height: 16),
            _buildPhysioTrendCard('HRV 变异性 (ms)', [42, 45, 48, 50, 52, 55, 53, 50, 48, 45], Colors.orangeAccent),
            const SizedBox(height: 32),

            // 4. AI Insights
            _buildAiInsightCard(theme),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreHero(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigoAccent.withOpacity(0.2), Colors.purpleAccent.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: 0.88,
                  strokeWidth: 10,
                  backgroundColor: Colors.white10,
                  color: Colors.cyanAccent,
                  strokeCap: StrokeCap.round,
                ),
              ),
              const Text('88', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('睡眠得分: 优秀', style: TextStyle(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('您的深度睡眠时长超过了 85% 的同龄用户，身体恢复非常理想。', 
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepStageChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(40, (index) {
                // Mock stages: 0-Awake, 1-REM, 2-Light, 3-Deep
                final stage = (index % 4 == 0) ? 0 : (index % 3 == 0) ? 3 : (index % 2 == 0) ? 2 : 1;
                final colors = [Colors.orangeAccent, Colors.lightBlueAccent, Colors.indigoAccent, Colors.deepPurpleAccent];
                final heights = [0.2, 0.5, 0.7, 1.0];
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    height: 150 * heights[stage],
                    decoration: BoxDecoration(
                      color: colors[stage].withOpacity(0.8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('23:00', style: TextStyle(color: Colors.white38, fontSize: 10)),
              const Text('03:00', style: TextStyle(color: Colors.white38, fontSize: 10)),
              const Text('07:30', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhysioTrendCard(String title, List<double> data, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: data.map((val) {
                return Container(
                  width: 20,
                  height: val,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.indigoAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.indigoAccent.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.indigoAccent, size: 24),
              const SizedBox(width: 12),
              Text('AI 睡眠洞察', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem('入睡时间比平时早 20 分钟，这显著提升了您的 REM 睡眠比例。'),
          _buildInsightItem('凌晨 03:24 有一次短暂清醒，可能与室内温度波动有关。'),
          _buildInsightItem('建议：今晚尝试开启“坠入梦境”场景，维持恒定室温。'),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: Colors.indigoAccent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14))),
        ],
      ),
    );
  }
}
