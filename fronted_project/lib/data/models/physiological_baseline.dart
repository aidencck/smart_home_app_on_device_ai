import 'package:isar/isar.dart';

part 'physiological_baseline.g.dart';

@collection
class PhysiologicalBaseline {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? userId;

  // 静息心率 (bpm)
  int? restingHeartRate;
  
  // 血压：收缩压/高压 (mmHg)
  int? systolicBloodPressure;
  
  // 血压：舒张压/低压 (mmHg)
  int? diastolicBloodPressure;
  
  // 基础体温 (°C)
  double? bodyTemperature;
  
  // 基础呼吸频率 (次/分钟)
  int? respirationRate;
  
  // 基础血氧饱和度 (%)
  double? bloodOxygenLevel;

  // 最后一次基线更新时间
  DateTime? updatedAt;
}
