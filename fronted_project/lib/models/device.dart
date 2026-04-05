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

// --- Capabilities ---
mixin HasTemperature on SmartDevice {
  int get temperature => (properties['temperature'] as num?)?.toInt() ?? 26;
  set temperature(int value) => properties['temperature'] = value;
}

mixin HasBrightness on SmartDevice {
  double get brightness => (properties['brightness'] as num?)?.toDouble() ?? 0.8;
  set brightness(double value) => properties['brightness'] = value;
}

// --- Security ---
enum SecurityLevel { normal, highRisk }

abstract class SmartDevice {
  final String id;
  final String name;
  final String room;
  final DeviceType type;

  final Map<String, dynamic> properties = {};

  bool get isOn => properties['power_state'] == true;
  set isOn(bool value) => properties['power_state'] = value;

  SmartDevice({
    required this.id,
    required this.name,
    required this.room,
    required this.type,
    bool isOn = false,
  }) {
    this.isOn = isOn;
  }

  IconData get icon;

  SecurityLevel get securityLevel => SecurityLevel.normal;

  Map<String, dynamic> serializeCapabilities() => {};

  void updateCapabilitiesFromJson(Map<String, dynamic> json) {}

  Map<String, dynamic> toJson() {
    // Export state as a TSL map
    return {
      'id': id,
      'name': name,
      'room': room,
      'type': type.name,
      'state': Map<String, dynamic>.from(properties),
    };
  }

  void updateFromJson(Map<String, dynamic> json) {
    if (json.containsKey('state')) {
      final stateMap = json['state'] as Map<String, dynamic>;
      properties.addAll(stateMap);
    } else {
      // Fallback for older flat JSON structure
      if (json.containsKey('on')) {
        isOn = json['on'] as bool;
      }
      updateCapabilitiesFromJson(json);
    }
  }

  SmartDevice clone();
}

class LightDevice extends SmartDevice with HasBrightness {
  LightDevice({
    required super.id,
    required super.name,
    required super.room,
    super.isOn,
    double brightness = 0.8,
  }) : super(type: DeviceType.light) {
    this.brightness = brightness;
  }

  @override
  Map<String, dynamic> serializeCapabilities() => {'brightness': brightness};

  @override
  void updateCapabilitiesFromJson(Map<String, dynamic> json) {
    if (json.containsKey('brightness')) {
      brightness = (json['brightness'] as num).toDouble();
    }
  }

  @override
  IconData get icon => Icons.lightbulb_outline;

  @override
  LightDevice clone() {
    final copy = LightDevice(id: id, name: name, room: room, isOn: isOn, brightness: brightness);
    return copy;
  }
}

class AcDevice extends SmartDevice with HasTemperature {
  AcDevice({
    required super.id,
    required super.name,
    required super.room,
    super.isOn,
    int temperature = 26,
  }) : super(type: DeviceType.ac) {
    this.temperature = temperature;
  }

  @override
  Map<String, dynamic> serializeCapabilities() => {'temperature': temperature};

  @override
  void updateCapabilitiesFromJson(Map<String, dynamic> json) {
    if (json.containsKey('temperature')) {
      temperature = json['temperature'] as int;
    }
  }

  @override
  IconData get icon => Icons.ac_unit;

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
  SecurityLevel get securityLevel => SecurityLevel.highRisk;

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
  SecurityLevel get securityLevel => SecurityLevel.highRisk;

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
  IconData get icon => Icons.blinds;

  @override
  CurtainDevice clone() {
    return CurtainDevice(id: id, name: name, room: room, isOn: isOn);
  }
}
