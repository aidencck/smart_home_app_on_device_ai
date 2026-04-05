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

class DevicesPage extends ConsumerStatefulWidget {
  const DevicesPage({super.key});

  @override
  ConsumerState<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends ConsumerState<DevicesPage> {
  @override
  Widget build(BuildContext context) {
    final deviceManager = ref.watch(deviceManagerProvider);
    return Builder(
      
      builder: (context) {
        if (!deviceManager.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: deviceManager.devices.length,
          itemBuilder: (context, i) {
            final d = deviceManager.devices[i];
            return DeviceCard(
              device: d,
              onTap: () => ref.read(deviceManagerProvider).toggleDevice(d.id),
              onMoreTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      DeviceDetailSheet(deviceId: d.id),
                );
              },
            );
          },
        );
      },
    );
  }
}

