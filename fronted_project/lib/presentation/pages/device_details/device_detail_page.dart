import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers.dart';
import '../../../models/device.dart';
import 'smart_ring_detail_view.dart';
import 'smart_bed_detail_view.dart';
import 'smart_light_detail_view.dart';
import 'common_device_detail_view.dart';
import 'third_level/device_general_settings_page.dart';

class DeviceDetailPage extends ConsumerWidget {
  final String deviceId;

  const DeviceDetailPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceManager = ref.watch(deviceManagerProvider);
    final device = deviceManager.devices.firstWhere(
      (d) => d.id == deviceId,
      orElse: () => throw Exception('Device not found'),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E), // 深色背景
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          device.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceGeneralSettingsPage(device: device),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildDeviceContent(device),
    );
  }

  Widget _buildDeviceContent(SmartDevice device) {
    if (device is SmartRingDevice) {
      return SmartRingDetailView(device: device);
    } else if (device is SmartBedDevice) {
      return SmartBedDetailView(device: device);
    } else if (device is LightDevice) {
      return SmartLightDetailView(device: device);
    } else {
      return CommonDeviceDetailView(device: device);
    }
  }
}
