import 'dart:async';
import 'dart:developer';

/// 推理引擎的抽象基类，方便未来切换 llama.cpp, MediaPipe 或云端大模型
abstract class InferenceEngine {
  /// 初始化/加载模型
  Future<void> initialize(String modelPath);

  /// 释放模型资源
  void dispose();

  /// 执行推理并返回完整的字符串结果
  /// [grammarSchema] 用于 GBNF 语法约束，确保输出符合 JSON 格式
  Future<String> infer(String prompt, {String? grammarSchema});

  /// 流式推理 (用于打字机效果)
  Stream<String> inferStream(String prompt);
}

/// 模拟的端侧推理引擎实现 (待替换为真实的 FFI 调用)
class LlamaCppEngineMock implements InferenceEngine {
  bool _isInitialized = false;

  @override
  Future<void> initialize(String modelPath) async {
    // 模拟加载耗时
    await Future.delayed(const Duration(seconds: 2));
    _isInitialized = true;
    log("模型加载成功: $modelPath");
  }

  @override
  void dispose() {
    _isInitialized = false;
    log("模型已释放");
  }

  @override
  Future<String> infer(String prompt, {String? grammarSchema}) async {
    if (!_isInitialized) throw Exception("模型未初始化");
    
    // 模拟推理耗时 (可以通过添加指标属性返回，由于当前接口是String，我们使用Stopwatch在Agent层记录)
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 根据 Prompt 简单模拟不同的输出，以便测试解析器
    if (prompt.contains("有点热") || prompt.contains("空调")) {
      return '{"device_id": "ac_1", "action": "set_temp", "value": 24}';
    } else if (prompt.contains("开灯") || prompt.contains("灯")) {
      return '{"device_id": "light_1", "action": "turn_on"}';
    } else if (prompt.contains("开过") || prompt.contains("记录")) {
      return '{"device_id": "system", "action": "reply", "value": "根据记录，门锁今天早上被打开过。"}';
    } else {
      return '{"device_id": "unknown", "action": "none"}';
    }
  }

  @override
  Stream<String> inferStream(String prompt) async* {
    if (!_isInitialized) throw Exception("模型未初始化");
    
    final response = await infer(prompt);
    // 模拟流式输出
    for (int i = 0; i < response.length; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      yield response[i];
    }
  }
}
