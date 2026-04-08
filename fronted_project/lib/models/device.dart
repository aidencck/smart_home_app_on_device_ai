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
  ring,
  bed,
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

  int get colorTemperature => (properties['color_temp'] as num?)?.toInt() ?? 2700;
  set colorTemperature(int value) => properties['color_temp'] = value;

  bool get sunriseEnabled => properties['sunrise_enabled'] == true;
  set sunriseEnabled(bool value) => properties['sunrise_enabled'] = value;
}

mixin HasBedControl on SmartDevice {
  double get headHeight => (properties['headHeight'] as num?)?.toDouble() ?? 0.0;
  set headHeight(double value) => properties['headHeight'] = value;

  double get footHeight => (properties['footHeight'] as num?)?.toDouble() ?? 0.0;
  set footHeight(double value) => properties['footHeight'] = value;

  bool get isLocked => properties['is_locked'] == true;
  set isLocked(bool value) => properties['is_locked'] = value;

  bool get isOccupied => properties['is_occupied'] == true;
  set isOccupied(bool value) => properties['is_occupied'] = value;

  int get heatingTemperature => (properties['heating_temp'] as num?)?.toInt() ?? 0;
  set heatingTemperature(int value) => properties['heating_temp'] = value;
}

mixin HasSleepTracking on SmartDevice {
  String get sleepStage => properties['sleep_stage']?.toString() ?? 'AWAKE';
  set sleepStage(String value) => properties['sleep_stage'] = value;

  int get heartRate => (properties['heart_rate'] as num?)?.toInt() ?? 70;
  set heartRate(int value) => properties['heart_rate'] = value;

  int get batteryLevel => (properties['battery_level'] as num?)?.toInt() ?? 85;
  set batteryLevel(int value) => properties['battery_level'] = value;

  int get hrv => (properties['hrv'] as num?)?.toInt() ?? 45;
  set hrv(int value) => properties['hrv'] = value;

  int get spo2 => (properties['spo2'] as num?)?.toInt() ?? 98;
  set spo2(int value) => properties['spo2'] = value;

  int get readinessScore => (properties['readiness_score'] as num?)?.toInt() ?? 80;
  set readinessScore(int value) => properties['readiness_score'] = value;
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
    Map<String, dynamic>? properties,
  }) {
    if (properties != null) {
      this.properties.addAll(properties);
    }
    if (!this.properties.containsKey('power_state')) {
      this.isOn = isOn;
    }
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

class SmartRingDevice extends SmartDevice with HasSleepTracking {
  SmartRingDevice({
    required super.id,
    required super.name,
    required super.room,
    super.isOn = true,
    super.properties,
    String sleepStage = 'AWAKE',
    int heartRate = 70,
  }) : super(type: DeviceType.ring) {
    if (!this.properties.containsKey('sleep_stage')) {
      this.sleepStage = sleepStage;
    }
    if (!this.properties.containsKey('heart_rate')) {
      this.heartRate = heartRate;
    }
  }

  @override
  IconData get icon => Icons.watch;

  @override
  SmartRingDevice clone() {
    return SmartRingDevice(
      id: id,
      name: name,
      room: room,
      isOn: isOn,
      sleepStage: sleepStage,
      heartRate: heartRate,
    );
  }
}

class SmartBedDevice extends SmartDevice with HasBedControl {
  SmartBedDevice({
    required super.id,
    required super.name,
    required super.room,
    super.isOn = true,
    super.properties,
    double headHeight = 0.0,
    double footHeight = 0.0,
    bool isLocked = false,
  }) : super(type: DeviceType.bed) {
    if (!this.properties.containsKey('headHeight')) {
      this.headHeight = headHeight;
    }
    if (!this.properties.containsKey('footHeight')) {
      this.footHeight = footHeight;
    }
    if (!this.properties.containsKey('is_locked')) {
      this.isLocked = isLocked;
    }
  }

  @override
  IconData get icon => Icons.bed;

  @override
  SmartBedDevice clone() {
    return SmartBedDevice(
      id: id,
      name: name,
      room: room,
      isOn: isOn,
      headHeight: headHeight,
      footHeight: footHeight,
      isLocked: isLocked,
    );
  }
}
