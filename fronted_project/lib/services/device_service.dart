import '../models/device.dart';

/// 抽象设备服务接口，可被虚拟设备或真实服务器设备服务实现
abstract class DeviceService {
  /// 初始化服务
  Future<void> initialize();

  /// 获取所有设备
  Future<List<SmartDevice>> getDevices();

  /// 根据 ID 查找设备
  Future<SmartDevice?> getDeviceById(String id);

  /// 切换设备开关状态
  Future<bool> toggleDevice(String id);

  /// 设置设备状态（根据属性）
  Future<bool> setDeviceState(String id, Map<String, dynamic> stateChanges);

  /// 根据关键词模糊查找设备
  Future<List<SmartDevice>> getDevicesByName(String nameKeywords);
}
