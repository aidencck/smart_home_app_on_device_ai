import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home_app/application/device_manager.dart';
import 'package:smart_home_app/services/virtual_device_service.dart';
import 'package:smart_home_app/models/device.dart';

void main() {
  group('DeviceManager Tests', () {
    late DeviceManager deviceManager;
    late VirtualDeviceService virtualDeviceService;

    setUp(() async {
      virtualDeviceService = VirtualDeviceService();
      deviceManager = DeviceManager(virtualDeviceService);
      // Wait for initialization to complete
      for (int i = 0; i < 20; i++) {
        if (deviceManager.isInitialized) break;
        await Future.delayed(const Duration(milliseconds: 100));
      }
    });

    test('Initializes correctly and loads devices', () {
      expect(deviceManager.isInitialized, true);
      expect(deviceManager.devices, isNotEmpty);
      expect(deviceManager.devices.length, 8);
    });

    test('toggleDevice toggles the on/off state of a device', () async {
      final initialDevice = deviceManager.devices.first;
      final deviceId = initialDevice.id;
      final initialState = initialDevice.isOn;

      await deviceManager.toggleDevice(deviceId);

      final updatedDevice = deviceManager.devices.firstWhere((d) => d.id == deviceId);
      expect(updatedDevice.isOn, !initialState);
    });

    test('getDevicesByName filters correctly', () {
      final lights = deviceManager.getDevicesByName('灯');
      expect(lights, isNotEmpty);
      expect(lights.every((d) => d.name.contains('灯')), true);
    });

    test('setDeviceStateById updates device state correctly', () async {
      final acDevice = deviceManager.devices.firstWhere((d) => d is HasTemperature) as SmartDevice;
      final deviceId = acDevice.id;

      final changes = await deviceManager.setDeviceStateById(deviceId, true, value: 24);

      expect(changes, isNotNull);
      expect(changes!['before']!.isOn, false);
      expect((changes['before'] as HasTemperature).temperature, 26);
      
      expect(changes['after']!.isOn, true);
      expect((changes['after'] as HasTemperature).temperature, 24);

      final updatedDevice = deviceManager.devices.firstWhere((d) => d.id == deviceId) as AcDevice;
      expect(updatedDevice.isOn, true);
      expect(updatedDevice.temperature, 24);
    });
  });
}
