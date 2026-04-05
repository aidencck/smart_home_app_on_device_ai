import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:isar/isar.dart';
import 'package:local_auth/local_auth.dart';
import '../models/agent_intent.dart';
import '../models/behavior_log.dart';

/// 负责解析模型输出、安全拦截并执行最终动作
class AgentActionExecutor {
  Isar? _isar;
  bool _isInitialized = false;

  /// 初始化本地数据库
  Future<void> initialize({String? customDir}) async {
    if (_isInitialized) return;
    try {
      final dir = customDir ?? Directory.systemTemp.path;
      _isar = await Isar.open(
        [BehaviorLogSchema],
        directory: dir,
        name: 'smarthome_agent_logs',
      );
      _isInitialized = true;
      log("✅ Isar 数据库初始化成功 (目录: $dir)");
      
      // 数据老化清理 (仅保留近 30 天)
      await _pruneOldLogs();
    } catch (e) {
      log("❌ Isar 数据库初始化失败: $e");
    }
  }

  /// 获取近期日志 (用于 RAG)
  Future<List<BehaviorLog>> getRecentLogs({int limit = 20}) async {
    if (_isar == null) return [];
    try {
      return await _isar!.behaviorLogs
          .filter()
          .idGreaterThan(-1) // Dummy filter to allow sorting
          .sortByTimestampDesc()
          .limit(limit)
          .findAll();
    } catch (e) {
      log("获取近期日志异常: $e");
      return [];
    }
  }

  /// 数据老化机制
  Future<void> _pruneOldLogs() async {
    if (_isar == null) return;
    
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    try {
      final oldLogsCount = await _isar!.behaviorLogs
          .filter()
          .timestampLessThan(thirtyDaysAgo)
          .count();
          
      if (oldLogsCount > 0) {
        await _isar!.writeTxn(() async {
          await _isar!.behaviorLogs
              .filter()
              .timestampLessThan(thirtyDaysAgo)
              .deleteAll();
        });
        log("🧹 已清理 $oldLogsCount 条 30 天前的行为日志");
      }
    } catch (e) {
      log("清理旧日志异常: $e");
    }
  }

  /// 解析大模型输出文本，提取 JSON 并执行
  Future<ExecutionResult> parseAndExecute(String modelOutput) async {
    try {
      // 1. 鲁棒的 JSON 提取 (防止模型幻觉输出多余文本)
      final jsonString = _extractJson(modelOutput);
      if (jsonString == null) {
        log("未检测到有效的控制指令: $modelOutput");
        return ExecutionResult(success: false, message: "未检测到有效的控制指令");
      }

      // 2. 反序列化
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final intent = AgentIntent.fromJson(jsonMap);

      // 如果是系统回复意图（例如 RAG 回答），直接放行，不走硬件控制
      if (intent.deviceId == 'system' && intent.action == 'reply') {
        return ExecutionResult(success: true, message: intent.value?.toString(), intent: intent);
      }

      // 3. 安全拦截校验 (Guardrails)
      if (!await _guardrailsCheck(intent)) {
        log("指令被安全拦截拒绝: $intent");
        return ExecutionResult(success: false, message: "指令被安全拦截拒绝", intent: intent);
      }

      // 4. 记录行为日志 (用于端侧习惯学习和场景推荐)
      _logUserBehavior(intent);

      // 5. 执行控制动作
      final executed = await _executeCommand(intent);
      
      return ExecutionResult(
        success: executed, 
        intent: intent,
      );
    } catch (e) {
      log("执行动作异常: $e");
      return ExecutionResult(success: false, message: "执行动作异常: $e");
    }
  }

  Future<void> _logUserBehavior(AgentIntent intent) async {
    if (_isar == null) return;
    
    final logEntry = BehaviorLog()
      ..timestamp = DateTime.now()
      ..deviceId = intent.deviceId
      ..action = intent.action
      ..value = intent.value?.toString()
      ..timeOfDay = _getTimeOfDay()
      ..isWeekend = DateTime.now().weekday >= 6;
      
    try {
      await _isar!.writeTxn(() async {
        await _isar!.behaviorLogs.put(logEntry);
      });
      final count = await _isar!.behaviorLogs.count();
      log("📝 [本地数据基建] 已记录用户行为日志: ${intent.action} -> ${intent.deviceId}");
      log("📝 当前本地日志总数: $count");
    } catch (e) {
      log("记录行为日志异常: $e");
    }
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 18) return 'afternoon';
    if (hour >= 18 && hour < 22) return 'evening';
    return 'night';
  }

  String? _extractJson(String text) {
    final startIndex = text.indexOf('{');
    final endIndex = text.lastIndexOf('}');
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return text.substring(startIndex, endIndex + 1);
    }
    return null;
  }

  Future<bool> _guardrailsCheck(AgentIntent intent) async {
    // 示例：拦截非法的温度设置
    if (intent.action == 'set_temp' && intent.value != null) {
      final temp = double.tryParse(intent.value.toString());
      if (temp != null && (temp < 16.0 || temp > 30.0)) {
        log("警告：温度设置 $temp 越界 (允许范围 16-30)");
        return false;
      }
    }
    
    // 高危设备安全护栏拦截
    const highRiskDevices = ['door_1', 'camera_1', 'lock_1'];
    if (highRiskDevices.contains(intent.deviceId)) {
      log("🚨 触发高危指令拦截机制！设备 [${intent.deviceId}] 属于高危设备，需要生物认证。");
      return await _requestBiometricAuth();
    }

    return true;
  }

  Future<bool> _requestBiometricAuth() async {
    try {
      final LocalAuthentication auth = LocalAuthentication();
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        log("设备不支持生物识别认证，直接拒绝高危操作");
        return false;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: '控制高危设备需要验证您的身份',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      
      return didAuthenticate;
    } catch (e) {
      log("生物认证异常: $e");
      return false;
    }
  }

  Future<bool> _executeCommand(AgentIntent intent) async {
    // 实际项目中这里对接您的 IoT 控制协议 (Matter/MQTT)
    log(">>> 正在下发指令到局域网: 控制设备 [${intent.deviceId}] 执行 [${intent.action}] 参数 [${intent.value ?? '无'}] <<<");
    await Future.delayed(const Duration(milliseconds: 200));
    log(">>> 指令执行成功！ <<<");
    return true;
  }
}
