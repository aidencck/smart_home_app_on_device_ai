import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:on_device_agent/on_device_agent.dart';
import '../models/device.dart';
import '../services/device_service.dart';
import '../services/virtual_device_service.dart';
import '../theme/figma_colors.dart';
import '../features/agent/fallback_intent_service.dart';
import '../application/application.dart';
import '../presentation/widgets/widgets.dart';
import '../presentation/pages/pages.dart';
import 'system_state_machine.dart';
import '../main.dart'; // for global variables if needed

class DeviceManager extends ChangeNotifier {
  final DeviceService _service;
  final SystemStateMachine _stateMachine;
  List<SmartDevice> _devices = [];
  bool _isInitialized = false;

  DeviceManager(this._service, this._stateMachine) {
    _init();
  }

  Future<void> _init() async {
    await _service.initialize();
    _devices = await _service.getDevices();
    _isInitialized = true;
    
    _service.onDeviceStateChanged.listen((event) {
      final deviceIndex = _devices.indexWhere((d) => d.id == event.deviceId);
      if (deviceIndex != -1) {
        _devices[deviceIndex].properties.addAll(event.updatedState);
        notifyListeners();
      }
    });

    notifyListeners();
  }

  bool get isInitialized => _isInitialized;

  List<SmartDevice> get devices => _devices;

  Future<void> toggleDevice(String id) async {
    // 乐观更新
    final deviceIndex = _devices.indexWhere((d) => d.id == id);
    if (deviceIndex == -1) return;
    
    final originalState = _devices[deviceIndex].isOn;
    _devices[deviceIndex].isOn = !originalState;
    notifyListeners();

    // 实际调用 (发送 desired properties)
    final success = await _service.setProperties(id, {'power_state': !originalState});
    if (!success) {
      // 失败回滚: 从云端或服务层拉取最新真实状态对账
      final actualDevice = await _service.getDeviceById(id);
      if (actualDevice != null) {
        _devices[deviceIndex].isOn = actualDevice.isOn;
      } else {
        // 仅在彻底断网且无法查证时，才回退到操作前状态
        _devices[deviceIndex].isOn = originalState;
      }
      notifyListeners();
    }
  }

  Future<void> setDeviceState(String nameKeywords, bool isOn, {int? temperature}) async {
    bool changed = false;
    for (var i = 0; i < _devices.length; i++) {
      final d = _devices[i];
      if (d.name.contains(nameKeywords) || d.room.contains(nameKeywords)) {
        if (d.isOn != isOn) {
          d.isOn = isOn;
          changed = true;
        }
        if (temperature != null && d is AcDevice) {
          d.temperature = temperature;
          changed = true;
        }
        
        if (changed) {
          // 同步给 service, 使用 setProperties 发送 desired state
          await _service.setProperties(d.id, d.properties);
        }
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  // 根据确切的 deviceId 设置状态，返回操作前后的状态
  Future<Map<String, SmartDevice>?> setDeviceStateById(String deviceId, bool isOn, {dynamic value}) async {
    try {
      final deviceIndex = _devices.indexWhere((d) => d.id == deviceId);
      if (deviceIndex == -1) return null;
      
      final device = _devices[deviceIndex];
      final beforeState = device.clone();
      final originalState = device.isOn;
      
      bool changed = false;
      if (device.isOn != isOn) {
        device.isOn = isOn;
        changed = true;
      }
      
      if (value != null && device is HasTemperature) {
         int? temp = int.tryParse(value.toString());
         if (temp != null && (device as HasTemperature).temperature != temp) {
           (device as HasTemperature).temperature = temp;
           changed = true;
         }
      }
      
      if (value != null && device is HasBrightness) {
         double? bright = double.tryParse(value.toString());
         if (bright != null && (device as HasBrightness).brightness != bright) {
           (device as HasBrightness).brightness = bright;
           changed = true;
         }
      }
      
      if (changed) {
        // 构建 desired state 并发送
        final desiredProperties = Map<String, dynamic>.from(device.properties);
        final success = await _service.setProperties(device.id, desiredProperties);
        if (!success) {
           final actualDevice = await _service.getDeviceById(deviceId);
           if (actualDevice != null) {
             _devices[deviceIndex].properties.addAll(actualDevice.properties);
           } else {
             _devices[deviceIndex].properties.addAll(beforeState.properties);
           }
        }
        notifyListeners();
      }
      
      final afterState = _devices[deviceIndex].clone();

      return {
        'before': beforeState,
        'after': afterState,
      };
    } catch (e) {
      return null;
    }
  }

  Future<bool> setDevicePropertiesById(String deviceId, Map<String, dynamic> properties) async {
    try {
      final deviceIndex = _devices.indexWhere((d) => d.id == deviceId);
      if (deviceIndex == -1) return false;
      
      final device = _devices[deviceIndex];
      
      // Update local state
      device.properties.addAll(properties);
      
      // Sync to service
      final success = await _service.setProperties(deviceId, properties);
      if (success) {
        notifyListeners();
      } else {
        // Fallback or re-fetch
        final actualDevice = await _service.getDeviceById(deviceId);
        if (actualDevice != null) {
          device.properties.addAll(actualDevice.properties);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  List<SmartDevice> getDevicesByName(String nameKeywords) {
    return _devices
        .where(
          (d) =>
              d.name.contains(nameKeywords) ||
              d.room.contains(nameKeywords),
        )
        .toList();
  }

  SmartDevice? getDeviceByName(String nameKeywords) {
    try {
      return _devices.firstWhere(
        (d) =>
            d.name.contains(nameKeywords) ||
            d.room.contains(nameKeywords),
      );
    } catch (e) {
      return null;
    }
  }
}

// 全局实例，注入虚拟服务（后续可替换为 RemoteDeviceService）
