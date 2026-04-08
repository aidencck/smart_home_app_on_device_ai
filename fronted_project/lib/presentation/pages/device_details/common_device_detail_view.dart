import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/device.dart';
import '../../../application/providers.dart';

class CommonDeviceDetailView extends ConsumerWidget {
  final SmartDevice device;

  const CommonDeviceDetailView({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOn = device.isOn;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Device Icon & Status
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOn ? Colors.indigoAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                boxShadow: [
                  if (isOn)
                    BoxShadow(
                      color: Colors.indigoAccent.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Icon(
                device.icon,
                size: 80,
                color: isOn ? Colors.indigoAccent : Colors.white24,
              ),
            ),
          ),
          const SizedBox(height: 48),

          // 2. Power Toggle Card
          _buildPowerCard(context, ref),
          const SizedBox(height: 24),

          // 3. Dynamic Controls based on Capabilities & Type
          if (device is HasTemperature)
            _buildTemperatureControl(context, ref, device as HasTemperature),
          
          if (device is HasBrightness && device is! LightDevice)
            _buildBrightnessControl(context, ref, device as HasBrightness),

          // 4. Specific Controls for other types
          if (device.type == DeviceType.lock) _buildLockControl(context, ref, device),
          if (device.type == DeviceType.camera) _buildCameraControl(context, ref, device),
          if (device.type == DeviceType.vacuum) _buildVacuumControl(context, ref, device),
          if (device.type == DeviceType.ac) _buildAcAdvancedControl(context, ref, device),

          // 5. Activity Log (Mock)
          const SizedBox(height: 32),
          Text(
            '最近动态',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityLog('今天 14:30', '设备已开启', Icons.power_settings_new),
          _buildActivityLog('今天 10:15', '固件更新成功 (v1.2.4)', Icons.system_update),
          _buildActivityLog('昨天 23:00', '进入节能模式', Icons.eco),

          // 6. Device Information
          const SizedBox(height: 32),
          Text(
            '设备信息',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('房间', device.room),
          _buildInfoRow('设备 ID', device.id),
          _buildInfoRow('型号', 'Luma Pro v2'),
          _buildInfoRow('固件版本', '1.2.4-stable'),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildPowerCard(BuildContext context, WidgetRef ref) {
    final isOn = device.isOn;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOn ? '运行中' : '已关闭',
                    style: TextStyle(
                      color: isOn ? Colors.greenAccent : Colors.white54,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '电源状态',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
              Switch(
                value: isOn,
                onChanged: (val) {
                  ref.read(deviceManagerProvider).toggleDevice(device.id);
                },
                activeColor: Colors.indigoAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemperatureControl(BuildContext context, WidgetRef ref, HasTemperature dev) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.thermostat, color: Colors.orangeAccent, size: 20),
              SizedBox(width: 8),
              Text('温度调节', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRoundButton(Icons.remove, () {}),
              Text(
                '${dev.temperature}°C',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              _buildRoundButton(Icons.add, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrightnessControl(BuildContext context, WidgetRef ref, HasBrightness dev) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('亮度', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('${dev.brightness.toInt()}%', style: const TextStyle(color: Colors.white54)),
            ],
          ),
          Slider(
            value: dev.brightness,
            min: 0,
            max: 100,
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }

  Widget _buildLockControl(BuildContext context, WidgetRef ref, SmartDevice dev) {
    final isLocked = dev.isOn;
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Icon(
            isLocked ? Icons.lock : Icons.lock_open,
            size: 64,
            color: isLocked ? Colors.redAccent : Colors.greenAccent,
          ),
          const SizedBox(height: 16),
          Text(
            isLocked ? '已上锁' : '已解锁',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(deviceManagerProvider).toggleDevice(dev.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLocked ? Colors.greenAccent : Colors.redAccent,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(isLocked ? '立即解锁' : '立即上锁', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraControl(BuildContext context, WidgetRef ref, SmartDevice dev) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.black),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off, color: Colors.white24, size: 48),
                    SizedBox(height: 8),
                    Text('预览已断开', style: TextStyle(color: Colors.white24)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRoundButton(Icons.mic, () {}),
              _buildRoundButton(Icons.camera_alt, () {}),
              _buildRoundButton(Icons.videocam, () {}),
              _buildRoundButton(Icons.history, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVacuumControl(BuildContext context, WidgetRef ref, SmartDevice dev) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _VacuumStat(label: '本次清扫', value: '12m²', icon: Icons.grid_on),
              _VacuumStat(label: '当前电量', value: '85%', icon: Icons.battery_charging_full),
              _VacuumStat(label: '耗时', value: '15min', icon: Icons.timer),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('开始清扫'),
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text('回充'),
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcAdvancedControl(BuildContext context, WidgetRef ref, SmartDevice dev) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('模式选择', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ModeChip(icon: Icons.ac_unit, label: '制冷', isActive: true),
              _ModeChip(icon: Icons.wb_sunny, label: '制热', isActive: false),
              _ModeChip(icon: Icons.air, label: '送风', isActive: false),
              _ModeChip(icon: Icons.eco, label: '节能', isActive: false),
            ],
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('风速调节', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallButton('自动'),
              _buildSmallButton('低速'),
              _buildSmallButton('中速', isActive: true),
              _buildSmallButton('高速'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.indigoAccent : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontSize: 12),
      ),
    );
  }

  Widget _buildRoundButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildActivityLog(String time, String action, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white38),
          const SizedBox(width: 12),
          Text(time, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(width: 12),
          Expanded(child: Text(action, style: const TextStyle(color: Colors.white70, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38)),
          Text(value, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _VacuumStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _VacuumStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white38, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _ModeChip({required this.icon, required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.indigoAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isActive ? Colors.indigoAccent : Colors.transparent),
      ),
      child: Column(
        children: [
          Icon(icon, color: isActive ? Colors.indigoAccent : Colors.white54, size: 24),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}
