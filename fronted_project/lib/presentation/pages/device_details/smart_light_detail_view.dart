import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/device.dart';
import '../../../application/providers.dart';
import 'third_level/light_schedule_page.dart';

class SmartLightDetailView extends ConsumerWidget {
  final LightDevice device;

  const SmartLightDetailView({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final light = device;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Light Visualization (Glassmorphism + Shadow)
          _buildLightBulbHero(light),
          const SizedBox(height: 48),

          // 2. Brightness Slider
          _buildSliderSection(
            '亮度调节',
            '${light.brightness.toInt()}%',
            Icons.brightness_medium,
            Colors.amber,
            Slider(
              value: light.brightness,
              min: 0.0,
              max: 100.0,
              activeColor: Colors.amber,
              inactiveColor: Colors.white10,
              onChanged: (val) {
                ref.read(deviceManagerProvider).setDeviceStateById(
                  light.id,
                  light.isOn,
                  value: val,
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // 3. Color Temperature Slider
          _buildSliderSection(
            '色温调节',
            '${light.colorTemperature}K',
            Icons.thermostat,
            Colors.orangeAccent,
            Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Colors.orangeAccent, Colors.white, Colors.lightBlueAccent],
                ),
              ),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 0,
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withOpacity(0.2),
                ),
                child: Slider(
                  value: light.colorTemperature.toDouble(),
                  min: 2700,
                  max: 6500,
                  onChanged: (val) {
                    // Update color temp
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 4. Sunrise Wake-up Toggle
          _buildSunriseWakeupCard(light, ref),
          const SizedBox(height: 32),

          // 5. Preset Scenes (Shader Engine)
          Text(
            '光效引擎 (Shader Engine)',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _buildSceneChip('围炉煮茶', Icons.fireplace, Colors.deepOrangeAccent),
              _buildSceneChip('挪威森林', Icons.forest, Colors.greenAccent),
              _buildSceneChip('深海静谧', Icons.waves, Colors.blueAccent),
              _buildSceneChip('极光幻境', Icons.auto_awesome, Colors.purpleAccent),
            ],
          ),
          const SizedBox(height: 32),

          // 6. Detailed Schedule Button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              icon: const Icon(Icons.schedule_outlined, color: Colors.orangeAccent),
              label: const Text('管理全天光照计划', style: TextStyle(color: Colors.orangeAccent)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LightSchedulePage(device: light),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.orange.withOpacity(0.05),
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

  Widget _buildLightBulbHero(LightDevice light) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dynamic Shadow/Glow
          if (light.isOn)
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4 * (light.brightness / 100)),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          // Bulb Icon
          Icon(
            Icons.lightbulb,
            size: 120,
            color: light.isOn
                ? Colors.amber.withOpacity(0.6 + 0.4 * (light.brightness / 100))
                : Colors.white10,
          ),
        ],
      ),
    );
  }

  Widget _buildSunriseWakeupCard(LightDevice light, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.orange.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wb_sunny, color: Colors.orangeAccent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '日出唤醒 (Sunrise)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '15分钟渐变唤醒，抑制褪黑素',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Switch(
                value: light.sunriseEnabled,
                onChanged: (val) {
                  // Toggle sunrise
                },
                activeColor: Colors.orangeAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderSection(String title, String value, IconData icon, Color color, Widget slider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color, size: 24),
                      const SizedBox(width: 12),
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              slider,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSceneChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
