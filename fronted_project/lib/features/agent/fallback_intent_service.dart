import '../../models/device.dart';
import '../../main.dart' show DeviceManager; // 依赖注入或传入

class FallbackIntentService {
  final DeviceManager deviceManager;

  FallbackIntentService(this.deviceManager);

  Future<FallbackResult> handleFallbackIntent(String text, bool isContinuing) async {
    List<Map<String, dynamic>> affectedDevices = [];
    Map<String, dynamic>? beforeState;
    Map<String, dynamic>? afterState;
    String responseText = "指令已执行。";

    if (text.contains("冷") ||
        text.contains("温度") ||
        (isContinuing && text.contains("高一点"))) {
      int temp = text.contains("高一点") ? 28 : 26;
      await deviceManager.setDeviceState("空调", true, temperature: temp);
      affectedDevices = deviceManager.getDevicesByName("空调");
      if (affectedDevices.isNotEmpty) {
         afterState = affectedDevices.first; 
         beforeState = Map<String, dynamic>.from(afterState);
         beforeState['on'] = false;
      }
      responseText = text.contains("高一点")
          ? "🤖 已为您将空调温度调高到 $temp 度。"
          : "🤖 已为您将空调打开并调至 $temp 度。";
    } else if (text.contains("暗") ||
        text.contains("灯") ||
        (isContinuing && (text.contains("亮一点") || text.contains("关掉它")))) {
      bool isTurningOn = !text.contains("关");
      await deviceManager.setDeviceState("灯", isTurningOn);
      affectedDevices = deviceManager.getDevicesByName("灯");
      if (affectedDevices.isNotEmpty) {
         afterState = affectedDevices.first;
         beforeState = Map<String, dynamic>.from(afterState);
         beforeState['on'] = !isTurningOn;
      }
      responseText = isTurningOn ? "🤖 已为您调节灯光。" : "🤖 已为您关灯。";
    } else if (text.contains("打扫") || text.contains("扫地")) {
      await deviceManager.setDeviceState("扫地", true);
      affectedDevices = deviceManager.getDevicesByName("扫地");
      if (affectedDevices.isNotEmpty) {
         afterState = affectedDevices.first;
         beforeState = Map<String, dynamic>.from(afterState);
         beforeState['on'] = false;
      }
      responseText = "🤖 已为您启动扫地机器人开始全屋清扫。";
    } else if (text.contains("出门") || text.contains("离家")) {
      await deviceManager.setDeviceState("灯", false);
      await deviceManager.setDeviceState("空调", false);
      await deviceManager.setDeviceState("电视", false);
      await deviceManager.setDeviceState("扫地", true); // 离家自动扫地
      affectedDevices = [
        ...deviceManager.getDevicesByName("灯"),
        ...deviceManager.getDevicesByName("空调"),
        ...deviceManager.getDevicesByName("电视"),
        ...deviceManager.getDevicesByName("扫地"),
      ];
      responseText = "🤖 好的，已为您开启离家模式，关闭相关设备并开始清扫。";
    } else if (text.contains("睡眠模式")) {
      await deviceManager.setDeviceState("灯", false);
      await deviceManager.setDeviceState("电视", false);
      await deviceManager.setDeviceState("空调", true, temperature: 26);
      affectedDevices = [
        ...deviceManager.getDevicesByName("灯"),
        ...deviceManager.getDevicesByName("电视"),
        ...deviceManager.getDevicesByName("空调"),
      ];
      responseText = "🤖 已为您开启睡眠模式，晚安。";
    } else if (text.contains("回家模式")) {
      await deviceManager.setDeviceState("灯", true);
      await deviceManager.setDeviceState("空调", true, temperature: 26);
      affectedDevices = [
        ...deviceManager.getDevicesByName("灯"),
        ...deviceManager.getDevicesByName("空调"),
      ];
      responseText = "🤖 欢迎回家，已为您打开灯光和空调。";
    } else if (text.contains("电视") || text.contains("看电影")) {
      bool isTurningOn = text.contains("开") || text.contains("看电影");
      await deviceManager.setDeviceState("电视", isTurningOn);
      if (text.contains("看电影")) {
        await deviceManager.setDeviceState("灯", false);
        await deviceManager.setDeviceState("窗帘", false);
      }
      affectedDevices = [
        ...deviceManager.getDevicesByName("电视"),
        if (text.contains("看电影")) ...deviceManager.getDevicesByName("灯"),
        if (text.contains("看电影")) ...deviceManager.getDevicesByName("窗帘"),
      ];
      if (affectedDevices.isNotEmpty && !text.contains("看电影")) {
         afterState = affectedDevices.first;
         beforeState = Map<String, dynamic>.from(afterState);
         beforeState['on'] = !isTurningOn;
      }
      responseText = text.contains("看电影")
          ? "🤖 已为您开启观影模式：打开电视，关闭灯光和窗帘。"
          : (isTurningOn ? "🤖 已为您打开电视。" : "🤖 已为您关闭电视。");
    } else {
       responseText = "🤖 抱歉，我不太明白您的意思，目前仅支持部分指令。";
    }

    return FallbackResult(
      responseText: responseText,
      affectedDevices: affectedDevices,
      beforeState: beforeState,
      afterState: afterState,
    );
  }
}

class FallbackResult {
  final String responseText;
  final List<Map<String, dynamic>> affectedDevices;
  final Map<String, dynamic>? beforeState;
  final Map<String, dynamic>? afterState;

  FallbackResult({
    required this.responseText,
    required this.affectedDevices,
    this.beforeState,
    this.afterState,
  });
}