import 'package:isar/isar.dart';

part 'override_log.g.dart';

@collection
class OverrideLog {
  Id id = Isar.autoIncrement;

  // 涉及的设备或系统模块ID
  @Index()
  String? targetId;

  // 干预动作类型 (例如: "FORCE_OFF", "MUTE_ALARM", "MANUAL_OVERRIDE")
  String? actionType;
  
  // 熔断/干预原因描述
  String? reason;

  // 触发人或系统标识 (例如: "user_123", "system_safety_protocol")
  String? triggeredBy;

  // 发生干预/熔断的时间
  @Index()
  DateTime? timestamp;
  
  // 熔断级别或干预优先级 (例如: 1: 普通, 2: 紧急, 3: 致命)
  int? severityLevel;

  // 是否已解决或恢复正常
  bool? isResolved;

  // 恢复/解决时间
  DateTime? resolvedAt;
}
