import 'package:isar/isar.dart';

part 'behavior_log.g.dart';

@collection
class BehaviorLog {
  // Web 端兼容的 Id 定义
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late DateTime timestamp;

  late String deviceId;
  late String action;
  String? value;

  // 环境上下文
  late String timeOfDay;
  late bool isWeekend;
  String? season;
  double? indoorTemp;
  double? outdoorTemp;
  int? illuminance;
}
