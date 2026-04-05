import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'src/engine/inference_engine.dart';
import 'src/engine/llama_cpp/llama_engine.dart';
import 'src/context/context_provider.dart';
import 'src/executor/action_executor.dart';
import 'src/models/agent_intent.dart';

export 'src/models/agent_intent.dart';

/// 智能家居端侧 AI Agent 的主门面类 (Facade)
/// 负责协调引擎、上下文与执行器
class SmartHomeAgent {
  final InferenceEngine _engine;
  final AgentContextProvider _contextProvider;
  final AgentActionExecutor _executor;

  bool _isReady = false;
  bool get isReady => _isReady;
  
  // 内存状态标识
  bool _isLowMemory = false;
  bool get isLowMemory => _isLowMemory;

  SmartHomeAgent({
    InferenceEngine? engine,
    AgentContextProvider? contextProvider,
    AgentActionExecutor? executor,
  })  : _engine = engine ?? (kIsWeb ? LlamaCppEngineMock() : LlamaCppEngine()), // Web 平台降级使用 Mock
        _contextProvider = contextProvider ?? AgentContextProvider(),
        _executor = executor ?? AgentActionExecutor();

  /// 初始化 Agent (包括加载本地模型)
  Future<void> initialize({required String modelPath, String? dbDir}) async {
    log("Agent 开始初始化...");
    
    // 1. 初始化数据库执行器
    await _executor.initialize(customDir: dbDir);
    
    // 启动前进行粗略的内存检查 (Mock: 实际项目中可通过 MethodChannel 调用 iOS/Android API)
    _checkSystemMemory();
    
    if (_isLowMemory) {
      log("警告: 检测到系统可用内存不足，端侧模型加载可能会被中止。");
      // 这里可以选择中止加载，或者抛出特定异常让 UI 层处理
      // 为了演示，我们暂时继续，但设置了标志位
    }

    // 2. 初始化推理引擎
    await _engine.initialize(modelPath);
    _isReady = true;
    log("Agent 初始化完成，已准备好接收指令。");
  }

  void _checkSystemMemory() {
    // 这是一个 Mock 的内存检测逻辑
    // 真实场景下，应调用 sysctl (iOS) 或 ActivityManager (Android) 获取可用内存
    // 假设如果不是 macOS/Windows/Linux 等桌面平台，且内存 < 2GB，则标记为低内存
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
       // Mock: 模拟 10% 的概率检测到低内存
       _isLowMemory = DateTime.now().millisecond % 10 == 0; 
    }
  }

  /// 处理用户的自然语言指令 (端到端闭环)
  Future<ExecutionResult> handleUserQuery(String query, {List<Map<String, dynamic>>? availableDevices, void Function(String)? onProgress}) async {
    if (!_isReady) {
      throw Exception("Agent 尚未初始化完成");
    }

    final stopwatchTotal = Stopwatch()..start();

    try {
      log("--- 开始处理指令: '$query' ---");
      _contextProvider.addMessage('user', query);

      // --- 1. RAG 日志检索 (意图拦截) ---
      // 简单规则：如果询问 "记录", "日志", "开过", "关过", "多久" 等，去本地查日志
      bool isQueryIntent = query.contains("开过") || query.contains("关过") || query.contains("多久") || query.contains("查询");
      if (isQueryIntent) {
        final recentLogs = await _executor.getRecentLogs(limit: 10);
        if (recentLogs.isNotEmpty) {
          final logLines = recentLogs.map((l) => "时间:${l.timestamp} 设备:${l.deviceId} 动作:${l.action} 值:${l.value ?? ''}").join('\n');
          _contextProvider.updateRagLogs(logLines);
          onProgress?.call("理解用户意图并检索日志... \n[RAG] 命中历史日志记录");
        } else {
          _contextProvider.updateRagLogs("暂无设备日志。");
          onProgress?.call("理解用户意图并检索日志... \n[RAG] 无相关历史日志");
        }
      } else {
         _contextProvider.updateRagLogs(""); // 清空上一轮的 RAG
         onProgress?.call("理解用户意图并检索日志...");
      }

      // --- 2. 动态生成 GBNF 语法树 ---
      if (availableDevices != null) {
        // 构建 GBNF 规则时，只需要设备的 ID 列表，过滤掉不可序列化的 IconData 等属性
        final safeDevices = availableDevices.map((d) {
          final Map<String, dynamic> safeMap = {};
          d.forEach((key, value) {
            if (value is String || value is num || value is bool || value == null) {
              safeMap[key] = value;
            } else if (value is Map) {
              safeMap[key] = value;
            }
          });
          return safeMap;
        }).toList();
        
        _contextProvider.updateDevices(safeDevices);
      }
      
      String deviceIdRule = '"\\"system\\""'; // 默认只有 system (用于回复)
      if (availableDevices != null && availableDevices.isNotEmpty) {
        final ids = availableDevices.map((d) => '"\\"${d['id']}\\""').join(' | ');
        deviceIdRule = '$ids | "\\"system\\""';
      }
      onProgress?.call("构建设备上下文环境... \n[Devices] ${availableDevices?.map((d) => d['name']).join(', ') ?? '无'}");

      // 1. 构建 Prompt (注入当前家庭上下文、历史对话和 RAG 日志)
      final prompt = _contextProvider.buildPrompt(query);
      
      // 2. 端侧推理 (带动态 GBNF 语法约束)
      onProgress?.call("调用端侧大模型进行推理... \n[Prompt] ${prompt.length > 50 ? '${prompt.substring(0, 50)}...' : prompt}");
      final jsonGrammar = '''
        root ::= "{" ws "\\"device_id\\"" ws ":" ws device_id_rule "," ws "\\"action\\"" ws ":" ws string ("," ws "\\"value\\"" ws ":" ws (number | string))? ("," ws "\\"reason\\"" ws ":" ws string)? "}"
        device_id_rule ::= $deviceIdRule
        string ::= "\\"" [^"]* "\\""
        number ::= [0-9]+ ("." [0-9]+)?
        ws ::= [ \\t\\n]*
      ''';
      
      final stopwatchInference = Stopwatch()..start();
      final modelOutput = await _engine.infer(prompt, grammarSchema: jsonGrammar);
      stopwatchInference.stop();
      log("模型原始输出: $modelOutput");

      // 3. 解析与安全执行
      onProgress?.call("解析并执行控制指令... \n[Output] $modelOutput");
      final result = await _executor.parseAndExecute(modelOutput);
      
      stopwatchTotal.stop();
      
      // 构建性能指标
      // 这里的 tokens 数量在 mock 中使用字符串长度大致估算，在真实 LlamaCppEngine 中可以由 C++ 传递上来
      final promptTokensEstimate = prompt.length ~/ 3; 
      final generatedTokensEstimate = modelOutput.length ~/ 3;
      final tokensPerSec = generatedTokensEstimate / (stopwatchInference.elapsedMilliseconds / 1000.0);

      final metrics = PerformanceMetrics(
        totalTimeMs: stopwatchTotal.elapsedMilliseconds,
        inferenceTimeMs: stopwatchInference.elapsedMilliseconds,
        promptTokens: promptTokensEstimate,
        generatedTokens: generatedTokensEstimate,
        tokensPerSecond: tokensPerSec.isFinite ? tokensPerSec : 0.0,
      );
      
      // 检查是否为大模型的自然语言回复 (RAG 或者普通的对话)
      if (result.success) {
        if (result.intent?.deviceId == 'system' && result.intent?.action == 'reply') {
           final reply = result.message ?? result.intent?.value?.toString() ?? "已完成";
           _contextProvider.addMessage('agent', reply);
           return ExecutionResult(
             success: true, 
             message: reply, 
             intent: result.intent,
             metrics: metrics,
           );
        }
        
        _contextProvider.addMessage('agent', '已执行操作');
        return ExecutionResult(
          success: true, 
          message: result.message, 
          intent: result.intent,
          metrics: metrics,
        );
      } else {
        _contextProvider.addMessage('agent', '未能识别操作意图');
        return ExecutionResult(
          success: false, 
          message: result.message, 
          intent: result.intent,
          metrics: metrics,
        );
      }

    } catch (e) {
      stopwatchTotal.stop();
      log("处理指令时发生错误: $e");
      return ExecutionResult(success: false, message: "处理错误: $e");
    }
  }

  /// 获取上下文提供者（用于手动管理对话历史等）
  AgentContextProvider get contextProvider => _contextProvider;

  /// 释放资源
  void dispose() {
    _engine.dispose();
    _isReady = false;
  }
}
