import 'dart:async';
import '../models/device.dart';
import 'device_service.dart';

/// 远程设备服务：后续用于对接真实的后端核心服务器
/// 当前仅提供结构示例，用于证明虚拟设备的接口可无缝切换
class RemoteDeviceService implements DeviceService {
  final String baseUrl;
  final String token;
  final _stateController = StreamController<DeviceStateEvent>.broadcast();

  RemoteDeviceService({required this.baseUrl, required this.token});

  @override
  Stream<DeviceStateEvent> get onDeviceStateChanged => _stateController.stream;

  @override
  Future<void> initialize() async {
    // TODO: 实现与服务器的 WebSocket 连接建立或初始化认证
  }

  @override
  Future<List<SmartDevice>> getDevices() async {
    // TODO: 调用真实的 REST API 获取设备列表
    // 例如: final response = await http.get('$baseUrl/devices', headers: {'Authorization': 'Bearer $token'});
    // return (response.data as List).map((json) => SmartDevice.fromJson(json)).toList();
    return [];
  }

  @override
  Future<SmartDevice?> getDeviceById(String id) async {
    // TODO: 调用真实的 REST API 获取单个设备
    return null;
  }

  @override
  Future<bool> toggleDevice(String id) async {
    // TODO: 调用真实的 REST API 切换设备状态
    // 例如: final response = await http.post('$baseUrl/devices/$id/toggle');
    // return response.statusCode == 200;
    return false;
  }

  @override
  Future<bool> setDeviceState(String id, Map<String, dynamic> stateChanges) async {
    return setProperties(id, stateChanges);
  }

  @override
  Future<bool> setProperties(String id, Map<String, dynamic> desiredProperties) async {
    // TODO: 调用真实的 REST API 更新设备属性
    // 例如: final response = await http.patch('$baseUrl/devices/$id', body: desiredProperties);
    // return response.statusCode == 200;
    return false;
  }

  @override
  Future<List<SmartDevice>> getDevicesByName(String nameKeywords) async {
    // TODO: 调用真实的 REST API 进行设备搜索
    return [];
  }
}
