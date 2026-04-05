import '../models/device.dart';

class DeviceStateEvent {
  final String deviceId;
  final Map<String, dynamic> updatedState;
  final String messageId;
  final int timestamp;

  DeviceStateEvent({
    required this.deviceId, 
    required this.updatedState,
    required this.messageId,
    required this.timestamp,
  });
}

/// 抽象设备服务接口，可被虚拟设备或真实服务器设备服务实现
abstract class DeviceService {
  /// 设备状态变更的实时数据流（对接 MQTT/WebSocket）
  Stream<DeviceStateEvent> get onDeviceStateChanged;

  /// 初始化服务
  Future<void> initialize();

  /// 获取所有设备
  Future<List<SmartDevice>> getDevices();

  /// 根据 ID 查找设备
  Future<SmartDevice?> getDeviceById(String id);

  /// 切换设备开关状态 (Legacy, will wrap setProperties)
  Future<bool> toggleDevice(String id);

  /// 设置设备状态（根据属性）(Legacy)
  Future<bool> setDeviceState(String id, Map<String, dynamic> stateChanges);

  /// 设置设备属性 (Standard TSL)
  Future<bool> setProperties(String id, Map<String, dynamic> desiredProperties);

  /// 根据关键词模糊查找设备
  Future<List<SmartDevice>> getDevicesByName(String nameKeywords);
}
