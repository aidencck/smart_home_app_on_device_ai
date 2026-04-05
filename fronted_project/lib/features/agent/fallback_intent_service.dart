import '../../application/device_manager.dart';
import '../../models/device.dart';

class FallbackIntentService {
  final DeviceManager deviceManager;

  FallbackIntentService(this.deviceManager);

  Future<FallbackResult> handleFallbackIntent(String text, bool isContinuing) async {
    List<SmartDevice> affectedDevices = [];
    SmartDevice? beforeState;
    SmartDevice? afterState;
    String responseText = "指令已执行。";

    final acPattern = RegExp(r'(空调|温度|冷|热|度)');
    final lightPattern = RegExp(r'(灯|亮|暗)');
    final vacuumPattern = RegExp(r'(扫地|打扫|清洁)');
    final outPattern = RegExp(r'(出门|离家|离开)');
    final sleepPattern = RegExp(r'(睡眠|睡觉|晚安)');
    final homePattern = RegExp(r'(回家|回来)');
    final tvPattern = RegExp(r'(电视|电影|剧)');
    final queryDevicesPattern = RegExp(r'(哪些|什么|所有).*(设备|东西)');

    if (queryDevicesPattern.hasMatch(text)) {
      final devices = deviceManager.devices;
      final names = devices.map((d) => d.name).join('、');
      responseText = "🤖 您目前有以下设备：$names。";
    } else if (acPattern.hasMatch(text) || (isContinuing && text.contains("高一点"))) {
      // 提取实体（温度数字）
      final tempMatch = RegExp(r'(\d{1,2})度').firstMatch(text);
      int temp = 26;
      if (tempMatch != null) {
        temp = int.tryParse(tempMatch.group(1) ?? '26') ?? 26;
      } else if (text.contains("高一点") || text.contains("热")) {
        temp = 28;
      } else if (text.contains("低一点") || text.contains("冷")) {
        temp = 24;
      }
      
      await deviceManager.setDeviceState("空调", true, temperature: temp);
      affectedDevices = deviceManager.getDevicesByName("空调");
      if (affectedDevices.isNotEmpty) {
         afterState = affectedDevices.first; 
         beforeState = afterState.clone();
         beforeState.isOn = false;
      }
      responseText = text.contains("高一点")
          ? "🤖 已为您将空调温度调高到 $temp 度。"
          : "🤖 已为您将空调打开并调至 $temp 度。";
    } else if (lightPattern.hasMatch(text) ||
        (isContinuing && (text.contains("亮一点") || text.contains("关掉它")))) {
      bool isTurningOn = !text.contains("关");
      await deviceManager.setDeviceState("灯", isTurningOn);
      affectedDevices = deviceManager.getDevicesByName("灯");
      if (affectedDevices.isNotEmpty) {
         afterState = affectedDevices.first;
         beforeState = afterState.clone();
         beforeState.isOn = !isTurningOn;
      }
      responseText = isTurningOn ? "🤖 已为您调节灯光。" : "🤖 已为您关灯。";
    } else if (vacuumPattern.hasMatch(text)) {
      await deviceManager.setDeviceState("扫地", true);
      affectedDevices = deviceManager.getDevicesByName("扫地");
      if (affectedDevices.isNotEmpty) {
         afterState = affectedDevices.first;
         beforeState = afterState.clone();
         beforeState.isOn = false;
      }
      responseText = "🤖 已为您启动扫地机器人开始全屋清扫。";
    } else if (outPattern.hasMatch(text)) {
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
    } else if (sleepPattern.hasMatch(text)) {
      await deviceManager.setDeviceState("灯", false);
      await deviceManager.setDeviceState("电视", false);
      await deviceManager.setDeviceState("空调", true, temperature: 26);
      affectedDevices = [
        ...deviceManager.getDevicesByName("灯"),
        ...deviceManager.getDevicesByName("电视"),
        ...deviceManager.getDevicesByName("空调"),
      ];
      responseText = "🤖 已为您开启睡眠模式，晚安。";
    } else if (homePattern.hasMatch(text)) {
      await deviceManager.setDeviceState("灯", true);
      await deviceManager.setDeviceState("空调", true, temperature: 26);
      affectedDevices = [
        ...deviceManager.getDevicesByName("灯"),
        ...deviceManager.getDevicesByName("空调"),
      ];
      responseText = "🤖 欢迎回家，已为您打开灯光和空调。";
    } else if (tvPattern.hasMatch(text)) {
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
         beforeState = afterState.clone();
         beforeState.isOn = !isTurningOn;
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
  final List<SmartDevice> affectedDevices;
  final SmartDevice? beforeState;
  final SmartDevice? afterState;

  FallbackResult({
    required this.responseText,
    required this.affectedDevices,
    this.beforeState,
    this.afterState,
  });
}
