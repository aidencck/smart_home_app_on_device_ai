import 'package:flutter/material.dart';

enum DeviceType {
  light,
  ac,
  lock,
  camera,
  airPurifier,
  vacuum,
  tv,
  curtain,
  unknown
}

abstract class SmartDevice {
  final String id;
  final String name;
  final String room;
  final DeviceType type;
  bool isOn;

  SmartDevice({
    required this.id,
    required this.name,
    required this.room,
    required this.type,
    this.isOn = false,
  });

  IconData get icon;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'room': room,
      'type': type.name,
      'on': isOn,
      // IconData 无法被 JSON 序列化，所以在发给大模型的时候不需要携带，
      // UI 渲染时直接通过类实例的 icon 属性获取即可。
      // 如果某些地方（比如旧的 UI 组件）仍然依赖字典里的 icon，
      // 我们可以将其排除在真正的 jsonEncode 之外，或者只在 UI 层手动附加。
    };
  }

  void updateFromJson(Map<String, dynamic> json) {
    if (json.containsKey('on')) {
      isOn = json['on'] as bool;
    }
  }

  SmartDevice clone();
}

class LightDevice extends SmartDevice {
  LightDevice({
    required super.id,
    required super.name,
    required super.room,
    super.isOn,
  }) : super(type: DeviceType.light);

  @override
  IconData get icon => Icons.lightbulb_outline;

  @override
  LightDevice clone() {
    return LightDevice(id: id, name: name, room: room, isOn: isOn);
  }
}

class AcDevice extends SmartDevice {
  int temperature;

  AcDevice({
    required super.id,
    required super.name,
    required super.room,
    super.isOn,
    this.temperature = 26,
  }) : super(type: DeviceType.ac);

  @override
  IconData get icon => Icons.ac_unit;

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['temperature'] = temperature;
    return data;
  }

  @override
  void updateFromJson(Map<String, dynamic> json) {
    super.updateFromJson(json);
    if (json.containsKey('temperature')) {
      temperature = json['temperature'] as int;
    }
  }

  @override
  AcDevice clone() {
    return AcDevice(id: id, name: name, room: room, isOn: isOn, temperature: temperature);
  }
}

class LockDevice extends SmartDevice {
  LockDevice({
    required super.id,
    required super.name,
    required super.room,
    super.isOn = true, // true means locked
  }) : super(type: DeviceType.lock);

  @override
  IconData get icon => Icons.lock_outline;

  @override
  LockDevice clone() {
    return LockDevice(id: id, name: name, room: room, isOn: isOn);
  }
}

class CameraDevice extends SmartDevice {
  CameraDevice({
    required super.id,
    required super.name,
    required super.room,
    super.isOn = true,
  }) : super(type: DeviceType.camera);

  @override
  IconData get icon => Icons.videocam_outlined;

  @override
  CameraDevice clone() {
    return CameraDevice(id: id, name: name, room: room, isOn: isOn);
  }
}

class AirPurifierDevice extends SmartDevice {
  AirPurifierDevice({
    required super.id,
    required super.name,
    required super.room,
    super.isOn,
  }) : super(type: DeviceType.airPurifier);

  @override
  IconData get icon => Icons.air;

  @override
  AirPurifierDevice clone() {
    return AirPurifierDevice(id: id, name: name, room: room, isOn: isOn);
  }
}

class VacuumDevice extends SmartDevice {
  VacuumDevice({
    required super.id,
    required super.name,
    required super.room,
    super.isOn,
  }) : super(type: DeviceType.vacuum);

  @override
  IconData get icon => Icons.cleaning_services_outlined;

  @override
  VacuumDevice clone() {
    return VacuumDevice(id: id, name: name, room: room, isOn: isOn);
  }
}

class TvDevice extends SmartDevice {
  TvDevice({
    required super.id,
    required super.name,
    required super.room,
    super.isOn,
  }) : super(type: DeviceType.tv);

  @override
  IconData get icon => Icons.tv;

  @override
  TvDevice clone() {
    return TvDevice(id: id, name: name, room: room, isOn: isOn);
  }
}

class CurtainDevice extends SmartDevice {
  CurtainDevice({
    required super.id,
    required super.name,
    required super.room,
    super.isOn, // true = open, false = closed
  }) : super(type: DeviceType.curtain);

  @override
  IconData get icon => Icons.curtains_outlined;

  @override
  CurtainDevice clone() {
    return CurtainDevice(id: id, name: name, room: room, isOn: isOn);
  }
}
