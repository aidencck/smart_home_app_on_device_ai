import 'dart:convert';

/// 负责收集家庭设备的当前状态，生成上下文快照
class AgentContextProvider {
  final List<Map<String, String>> _conversationHistory = [];

  void addMessage(String role, String content) {
    _conversationHistory.add({"role": role, "content": content});
    // 保留最近 5 轮对话作为上下文
    if (_conversationHistory.length > 10) {
      _conversationHistory.removeAt(0);
    }
  }

  void clearHistory() {
    _conversationHistory.clear();
  }

  List<Map<String, dynamic>> _currentDevices = [];
  String _ragLogs = "";

  void updateDevices(List<Map<String, dynamic>> devices) {
    // 再次过滤确保进入 ContextProvider 的设备状态也是纯净的
    _currentDevices = devices.map((d) {
      final Map<String, dynamic> safeMap = {};
      d.forEach((key, value) {
        if (value is String || value is num || value is bool || value == null) {
          safeMap[key] = value;
        } else if (value is Map) {
          // Allow TSL state map
          safeMap[key] = value;
        }
      });
      return safeMap;
    }).toList();
  }

  void updateRagLogs(String logs) {
    _ragLogs = logs;
  }

  /// 获取当前所有设备的简化状态 (JSON字符串)
  /// 在实际项目中，这里会调用您的 IoT 状态管理层
  String getDeviceStateSnapshot() {
    if (_currentDevices.isNotEmpty) {
      return jsonEncode(_currentDevices); // 因为在 updateDevices 已经做过过滤了，这里绝对安全
    }
    // Mock data for demonstration fallback
    final List<Map<String, dynamic>> mockStates = [
      {"id": "light_1", "name": "客厅灯", "room": "客厅", "state": "off"},
      {"id": "ac_1", "name": "卧室空调", "room": "主卧", "state": "on", "temp": 26},
      {"id": "curtain_1", "name": "客厅窗帘", "room": "客厅", "state": "open"},
      {"id": "tv_1", "name": "电视", "room": "客厅", "state": "off"},
    ];
    return jsonEncode(mockStates);
  }

  /// 获取环境上下文 (用于动态感知执行)
  String getEnvironmentContext() {
    final now = DateTime.now();
    return jsonEncode({
      "time": "${now.hour}:${now.minute.toString().padLeft(2, '0')}",
      "season": "summer", // 模拟季节
      "indoor_temp": 28.5,
      "outdoor_temp": 32.0,
      "illuminance": 850, // 勒克斯
    });
  }

  /// 获取本地行为日志摘要 (用于 AI 预测推荐)
  String getBehaviorLogsSummary() {
    // 这里应该是从本地 SQLite 读取并聚类的结果
    return '''
- 用户习惯 1: 连续 3 天在 23:00 关闭所有灯光 (置信度 95%)
- 用户习惯 2: 每次开启电视时，通常会调暗客厅灯光 (置信度 88%)
''';
  }

  /// 构建完整的 System Prompt
  String buildPrompt(String userQuery) {
    final contextSnapshot = getDeviceStateSnapshot();
    final envContext = getEnvironmentContext();
    final behaviorLogs = getBehaviorLogsSummary();
    
    String historyText = "";
    if (_conversationHistory.isNotEmpty) {
      historyText = "\n【近期对话历史】\n";
      for (var msg in _conversationHistory) {
        historyText += "${msg['role'] == 'user' ? '用户' : '助手'}: ${msg['content']}\n";
      }
    }

    String ragText = "";
    if (_ragLogs.isNotEmpty) {
      ragText = "\n【相关设备日志 (RAG Context)】\n用户可能在询问设备的状态或历史，请参考以下日志回答：\n$_ragLogs\n";
    }
    
    return '''
你是一个运行在端侧的智能家居 AI 助手。你的核心能力是：
1. 根据用户指令控制设备。
2. 动态感知环境，调整设备参数。
3. 根据【相关设备日志】回答用户关于设备历史和状态的提问。

请根据以下上下文、近期对话历史和用户指令，输出需要执行的 JSON 格式动作。
如果你是在回答用户的问题（例如“门锁开过吗”），请将设备ID设为 "system"，action 设为 "reply"，并在 value 中填入你的回答内容。
除了 JSON 之外不要输出任何其他内容。

【当前设备状态】
$contextSnapshot

【当前环境感知】
$envContext

【本地行为学习总结】
$behaviorLogs
$ragText$historyText
【最新用户指令】
"$userQuery"

【输出格式要求】
{"device_id": "设备ID或system", "action": "动作类型(turn_on/turn_off/set_temp/reply等)", "value": "数值或回答内容(可选)", "reason": "AI动态调整或推荐的理由(可选)"}
''';
  }
}
