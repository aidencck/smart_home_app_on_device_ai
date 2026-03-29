import 'dart:async';
import '../models/device.dart';
import 'device_service.dart';

/// 虚拟设备服务：在内存中模拟设备的各种操作和状态，方便本地测试与 AI 端侧调试
class VirtualDeviceService implements DeviceService {
  final List<SmartDevice> _devices = [];

  // 模拟网络延迟时间
  final Duration networkDelay;

  VirtualDeviceService({this.networkDelay = const Duration(milliseconds: 100)});

  @override
  Future<void> initialize() async {
    // 模拟从本地数据库或初始配置加载设备
    await Future.delayed(networkDelay);
    
    if (_devices.isEmpty) {
      _devices.addAll([
        LightDevice(id: 'light_1', name: '客厅灯', room: '客厅', isOn: true),
        AcDevice(id: 'ac_1', name: '卧室空调', room: '主卧', isOn: false, temperature: 26),
        LockDevice(id: 'lock_1', name: '门锁', room: '大门', isOn: true),
        CameraDevice(id: 'cam_1', name: '摄像头', room: '客厅', isOn: true),
        AirPurifierDevice(id: 'air_1', name: '空气净化器', room: '书房', isOn: false),
        VacuumDevice(id: 'robot_1', name: '扫地机器人', room: '客厅', isOn: false),
        TvDevice(id: 'tv_1', name: '电视', room: '客厅', isOn: false),
        CurtainDevice(id: 'curtain_1', name: '客厅窗帘', room: '客厅', isOn: false),
      ]);
    }
  }

  @override
  Future<List<SmartDevice>> getDevices() async {
    await Future.delayed(networkDelay);
    // 返回拷贝，防止外部直接修改
    return _devices.map((d) => d.clone()).toList();
  }

  @override
  Future<SmartDevice?> getDeviceById(String id) async {
    await Future.delayed(networkDelay);
    try {
      final device = _devices.firstWhere((d) => d.id == id);
      return device.clone();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> toggleDevice(String id) async {
    await Future.delayed(networkDelay);
    try {
      final device = _devices.firstWhere((d) => d.id == id);
      device.isOn = !device.isOn;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> setDeviceState(String id, Map<String, dynamic> stateChanges) async {
    await Future.delayed(networkDelay);
    try {
      final device = _devices.firstWhere((d) => d.id == id);
      device.updateFromJson(stateChanges);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<SmartDevice>> getDevicesByName(String nameKeywords) async {
    await Future.delayed(networkDelay);
    return _devices
        .where((d) => d.name.contains(nameKeywords) || d.room.contains(nameKeywords))
        .map((d) => d.clone())
        .toList();
  }
}
