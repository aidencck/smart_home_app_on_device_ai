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
import 'device_details/device_detail_page.dart';
import '../../main.dart'; // for global variables if needed

class DevicesPage extends ConsumerStatefulWidget {
  final String initialRoom;
  const DevicesPage({super.key, this.initialRoom = '全部'});

  @override
  ConsumerState<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends ConsumerState<DevicesPage> {
  late String _selectedRoom;
  final List<String> _rooms = ['全部', '主卧', '客厅', '厨房', '卫生间'];

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.initialRoom;
  }

  @override
  Widget build(BuildContext context) {
    final deviceManager = ref.watch(deviceManagerProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('设备空间', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Room Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _rooms.map((room) {
                final isSelected = _selectedRoom == room;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedRoom = room),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.indigoAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.indigoAccent.withOpacity(0.5) : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        room,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white54,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Device Grid
          Expanded(
            child: Builder(
              builder: (context) {
                if (!deviceManager.isInitialized) {
                  return const Center(child: CircularProgressIndicator(color: Colors.indigoAccent));
                }
                
                final filteredDevices = _selectedRoom == '全部'
                    ? deviceManager.devices
                    : deviceManager.devices.where((d) => d.room == _selectedRoom).toList();

                if (filteredDevices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.devices_other, size: 64, color: Colors.white.withOpacity(0.1)),
                        const SizedBox(height: 16),
                        Text('该房间暂无设备', style: TextStyle(color: Colors.white.withOpacity(0.3))),
                      ],
                    ),
                  );
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: filteredDevices.length,
                  itemBuilder: (context, i) {
                    final d = filteredDevices[i];
                    return DeviceCard(
                      device: d,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeviceDetailPage(deviceId: d.id),
                          ),
                        );
                      },
                      onMoreTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeviceDetailPage(deviceId: d.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

