class AgentIntent {
  final String deviceId;
  final String action;
  final dynamic value;

  AgentIntent({
    required this.deviceId,
    required this.action,
    this.value,
  });

  factory AgentIntent.fromJson(Map<String, dynamic> json) {
    return AgentIntent(
      deviceId: json['device_id'] ?? '',
      action: json['action'] ?? '',
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'action': action,
      'value': value,
    };
  }

  @override
  String toString() => 'AgentIntent(deviceId: $deviceId, action: $action, value: $value)';
}

/// 性能追踪指标
class PerformanceMetrics {
  final int totalTimeMs;
  final int inferenceTimeMs;
  final int promptTokens;
  final int generatedTokens;
  final double tokensPerSecond;

  PerformanceMetrics({
    required this.totalTimeMs,
    required this.inferenceTimeMs,
    this.promptTokens = 0,
    this.generatedTokens = 0,
    this.tokensPerSecond = 0.0,
  });
}

/// 表示一次执行的详细结果
class ExecutionResult {
  final bool success;
  final String? message;
  final AgentIntent? intent;
  final Map<String, dynamic>? beforeState;
  final Map<String, dynamic>? afterState;
  final PerformanceMetrics? metrics;

  ExecutionResult({
    required this.success,
    this.message,
    this.intent,
    this.beforeState,
    this.afterState,
    this.metrics,
  });
}
