import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device.dart';
import 'device_manager.dart';
import 'providers.dart';

class LinkageManager extends ChangeNotifier {
  final DeviceManager deviceManager;
  String? _lastSleepStage;

  LinkageManager(this.deviceManager) {
    _initLastStage();
    deviceManager.addListener(_onDeviceStateChanged);
  }

  void _initLastStage() {
    final ring = deviceManager.devices.whereType<SmartRingDevice>().firstOrNull;
    if (ring != null) {
      _lastSleepStage = ring.sleepStage;
    }
  }

  void _onDeviceStateChanged() {
    final ring = deviceManager.devices.whereType<SmartRingDevice>().firstOrNull;
    if (ring == null) return;

    final currentSleepStage = ring.sleepStage;
    if (_lastSleepStage == currentSleepStage) return;

    debugPrint('🌙 [Linkage] 检测到睡眠阶段变更: $_lastSleepStage -> $currentSleepStage');
    _lastSleepStage = currentSleepStage;
    _handleSleepStageChange(currentSleepStage);
  }

  Future<void> _handleSleepStageChange(String stage) async {
    debugPrint('🌙 [Linkage] 检测到睡眠阶段变更: $stage');

    switch (stage) {
      case 'DEEP_SLEEP':
        await _executeDeepSleepLinkage();
        break;
      case 'LIGHT_SLEEP':
        await _executeLightSleepLinkage();
        break;
      case 'AWAKE':
        await _executeAwakeLinkage();
        break;
    }
  }

  Future<void> _executeDeepSleepLinkage() async {
    debugPrint('🛡️ [Linkage] 执行深睡联动: 锁定床位 + 关闭电视');
    
    // 1. 智能床：复位并锁定
    final bed = deviceManager.devices.whereType<SmartBedDevice>().firstOrNull;
    if (bed != null) {
      debugPrint('🛡️ [Linkage] 正在锁定智能床 ${bed.id}');
      await deviceManager.setDevicePropertiesById(bed.id, {
        'headHeight': 0.0,
        'footHeight': 0.0,
        'is_locked': true,
      });
    }

    // 2. 电视：强制关闭
    final tv = deviceManager.devices.whereType<TvDevice>().firstOrNull;
    if (tv != null && tv.isOn) {
      debugPrint('🛡️ [Linkage] 正在关闭电视 ${tv.id}');
      await deviceManager.toggleDevice(tv.id);
    }
  }

  Future<void> _executeLightSleepLinkage() async {
    debugPrint('🌤️ [Linkage] 执行浅睡联动: 准备唤醒');
    // 1. 智能床：头部微抬辅助呼吸
    final bed = deviceManager.devices.whereType<SmartBedDevice>().firstOrNull;
    if (bed != null) {
      debugPrint('🌤️ [Linkage] 正在解锁并微调智能床 ${bed.id}');
      await deviceManager.setDevicePropertiesById(bed.id, {
        'headHeight': 10.0,
        'is_locked': false,
      });
    }

    // 2. 电视：模拟日出渐变 (如果电视在线)
    final tv = deviceManager.devices.whereType<TvDevice>().firstOrNull;
    if (tv != null) {
      debugPrint('🌤️ [Linkage] 正在为电视 ${tv.id} 开启日出模拟模式');
      // 模拟渐变逻辑：实际中会发送 transition_duration: 900 等参数
      await deviceManager.setDevicePropertiesById(tv.id, {
        'power_state': true,
        'mode': 'sunrise',
        'brightness': 0.1, // 初始低亮度
      });
    }
  }

  Future<void> _executeAwakeLinkage() async {
    debugPrint('☕ [Linkage] 执行清醒联动: 解锁设备');
    final bed = deviceManager.devices.whereType<SmartBedDevice>().firstOrNull;
    if (bed != null) {
      debugPrint('☕ [Linkage] 正在解锁智能床 ${bed.id}');
      await deviceManager.setDevicePropertiesById(bed.id, {
        'is_locked': false,
      });
    }
  }

  @override
  void dispose() {
    deviceManager.removeListener(_onDeviceStateChanged);
    super.dispose();
  }
}

final linkageManagerProvider = ChangeNotifierProvider<LinkageManager>((ref) {
  final deviceManager = ref.watch(deviceManagerProvider);
  return LinkageManager(deviceManager);
});
