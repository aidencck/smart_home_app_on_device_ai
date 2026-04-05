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
import '../../application/providers.dart';
import '../widgets/widgets.dart';
import '../pages/pages.dart';
import '../../main.dart'; // for global variables if needed

class DeviceDetailSheet extends ConsumerWidget {
  final String deviceId;

  const DeviceDetailSheet({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceManager = ref.watch(deviceManagerProvider);
    return Builder(
      
      builder: (context) {
        final device = deviceManager.devices.firstWhere(
          (d) => d.id == deviceId,
        );
        final isOn = device.isOn;
        final name = device.name;
        final room = device.room;
        final icon = device.icon;
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // M3 顶部指示条
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 设备大图标
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isOn
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: isOn
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              // 设备名称与房间
              Text(
                name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                room,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              // 开关控制按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '电源开关',
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Switch(
                    value: isOn,
                    onChanged: (_) {
                      deviceManager.toggleDevice(deviceId);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 根据设备类型展示调节控件
              if (device is HasBrightness)
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '亮度调节',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(value: 0.8, onChanged: (val) {}),
                  ],
                )
              else if (device is HasTemperature)
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '温度调节',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton.filledTonal(
                          onPressed: () {},
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          '24°C',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

