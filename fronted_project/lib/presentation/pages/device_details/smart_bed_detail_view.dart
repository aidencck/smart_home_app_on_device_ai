import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/device.dart';
import '../../../application/providers.dart';
import 'third_level/bed_advanced_settings_page.dart';

class SmartBedDetailView extends ConsumerWidget {
  final SmartBedDevice device;

  const SmartBedDetailView({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bed = device;
    
    // Find the ring to get sleep stage for Hard Lock
    final ring = ref.watch(deviceManagerProvider).devices.whereType<SmartRingDevice>().firstOrNull;
    final isDeepSleep = ring?.sleepStage == 'DEEP';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Bed Visualization & Occupancy
              _buildBedVisualization(bed),
              const SizedBox(height: 32),

              // 2. Control Sections
              _buildControlCard(
                '头部高度',
                '${bed.headHeight.toInt()}°',
                Icons.keyboard_double_arrow_up,
                Colors.orangeAccent,
                Slider(
                  value: bed.headHeight,
                  min: 0.0,
                  max: 60.0,
                  activeColor: Colors.orangeAccent,
                  inactiveColor: Colors.white10,
                  onChanged: isDeepSleep ? null : (val) {
                    ref.read(deviceManagerProvider).setDeviceStateById(
                      bed.id,
                      bed.isOn,
                      value: val,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              _buildControlCard(
                '脚部高度',
                '${bed.footHeight.toInt()}°',
                Icons.keyboard_double_arrow_up,
                Colors.lightBlueAccent,
                Slider(
                  value: bed.footHeight,
                  min: 0.0,
                  max: 60.0,
                  activeColor: Colors.lightBlueAccent,
                  inactiveColor: Colors.white10,
                  onChanged: isDeepSleep ? null : (val) {
                    // Update foot height
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 3. Status Grid
              Row(
                children: [
                  Expanded(
                    child: _buildToggleCard(
                      '童锁锁定',
                      bed.isLocked ? '已锁定' : '未开启',
                      Icons.lock_outline,
                      bed.isLocked ? Colors.redAccent : Colors.white54,
                      bed.isLocked,
                      (val) {
                        ref.read(deviceManagerProvider).setDeviceStateById(bed.id, bed.isOn);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildToggleCard(
                      '智能预热',
                      bed.heatingTemperature > 0 ? '${bed.heatingTemperature}°C' : '已关闭',
                      Icons.wb_sunny_outlined,
                      Colors.orangeAccent,
                      bed.heatingTemperature > 0,
                      (val) {
                        // Toggle heating
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 4. Advanced Settings Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.tune_outlined),
                  label: const Text('进入深度姿态配置'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BedAdvancedSettingsPage(device: bed),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white10),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
          
          // 4. Hard Lock Overlay (If Deep Sleep)
          if (isDeepSleep)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_person, color: Colors.amberAccent, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          '深睡期硬锁已开启',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '为了您的睡眠质量，手动调节已禁用',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBedVisualization(SmartBedDevice bed) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E2E5A), Color(0xFF1E1E3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bed.isOccupied ? Colors.greenAccent.withOpacity(0.2) : Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        bed.isOccupied ? Icons.person : Icons.person_outline,
                        size: 14,
                        color: bed.isOccupied ? Colors.greenAccent : Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        bed.isOccupied ? '有人在床' : '无人',
                        style: TextStyle(
                          color: bed.isOccupied ? Colors.greenAccent : Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: CustomPaint(
              size: const Size(200, 100),
              painter: BedAnglePainter(
                headAngle: bed.headHeight,
                footAngle: bed.footHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard(String title, String value, IconData icon, Color color, Widget control) {
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
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    value,
                    style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              control,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleCard(String title, String subTitle, IconData icon, Color color, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.indigoAccent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subTitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}

class BedAnglePainter extends CustomPainter {
  final double headAngle;
  final double footAngle;

  BedAnglePainter({required this.headAngle, required this.footAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.indigoAccent
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final baseLineY = size.height * 0.8;
    final centerX = size.width * 0.5;

    // Draw base
    canvas.drawLine(
      Offset(size.width * 0.1, baseLineY),
      Offset(size.width * 0.9, baseLineY),
      paint..color = Colors.white.withOpacity(0.1),
    );

    // Head part
    final headRad = headAngle * 3.14159 / 180;
    final headLen = size.width * 0.35;
    canvas.drawLine(
      Offset(centerX, baseLineY),
      Offset(centerX - headLen * (1 - headRad * 0.2), baseLineY - headLen * headRad * 0.6),
      paint..color = Colors.orangeAccent,
    );

    // Foot part
    final footRad = footAngle * 3.14159 / 180;
    final footLen = size.width * 0.35;
    canvas.drawLine(
      Offset(centerX, baseLineY),
      Offset(centerX + footLen * (1 - footRad * 0.2), baseLineY - footLen * footRad * 0.6),
      paint..color = Colors.lightBlueAccent,
    );
    
    // Joint dot
    canvas.drawCircle(Offset(centerX, baseLineY), 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
