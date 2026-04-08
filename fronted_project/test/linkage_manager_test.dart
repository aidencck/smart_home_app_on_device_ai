import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home_app/application/device_manager.dart';
import 'package:smart_home_app/application/linkage_manager.dart';
import 'package:smart_home_app/services/virtual_device_service.dart';
import 'package:smart_home_app/models/device.dart';

void main() {
  group('LinkageManager Tests', () {
    late DeviceManager deviceManager;
    late VirtualDeviceService virtualDeviceService;
    late LinkageManager linkageManager;

    setUp(() async {
      virtualDeviceService = VirtualDeviceService();
      deviceManager = DeviceManager(virtualDeviceService);
      // Wait for initialization to complete
      for (int i = 0; i < 20; i++) {
        if (deviceManager.isInitialized) break;
        await Future.delayed(const Duration(milliseconds: 100));
      }
      linkageManager = LinkageManager(deviceManager);
    });

    test('DEEP_SLEEP triggers bed lock and TV off', () async {
      // Find devices
      final ring = deviceManager.devices.whereType<SmartRingDevice>().first;
      final bed = deviceManager.devices.whereType<SmartBedDevice>().first;
      final tv = deviceManager.devices.whereType<TvDevice>().first;

      // Ensure initial states
      expect(ring.sleepStage, 'AWAKE');
      expect(bed.isLocked, false);
      expect(tv.isOn, true);

      // Trigger DEEP_SLEEP
      await deviceManager.setDevicePropertiesById(ring.id, {'sleep_stage': 'DEEP_SLEEP'});
      
      // Wait for linkage to process
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify outcomes
      final updatedBed = deviceManager.devices.whereType<SmartBedDevice>().first;
      final updatedTv = deviceManager.devices.whereType<TvDevice>().first;

      expect(updatedBed.headHeight, 0.0);
      expect(updatedBed.footHeight, 0.0);
      expect(updatedBed.isLocked, true);
      expect(updatedTv.isOn, false);
    });

    test('AWAKE unlocks the bed', () async {
      final ring = deviceManager.devices.whereType<SmartRingDevice>().first;
      final bed = deviceManager.devices.whereType<SmartBedDevice>().first;

      // Ensure we are in a state where linkage doesn't automatically unlock
      await deviceManager.setDevicePropertiesById(ring.id, {'sleep_stage': 'REM'});
      await Future.delayed(const Duration(milliseconds: 100));

      // Lock the bed manually
      await deviceManager.setDevicePropertiesById(bed.id, {'is_locked': true});
      expect(deviceManager.devices.whereType<SmartBedDevice>().first.isLocked, true);

      // Trigger AWAKE
      await deviceManager.setDevicePropertiesById(ring.id, {'sleep_stage': 'AWAKE'});
      
      // Wait for linkage to process
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify outcome
      final updatedBed = deviceManager.devices.whereType<SmartBedDevice>().first;
      expect(updatedBed.isLocked, false);
    });
  });
}
