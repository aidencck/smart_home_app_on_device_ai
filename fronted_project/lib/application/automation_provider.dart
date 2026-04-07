import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/automation.dart';

class AutomationNotifier extends StateNotifier<List<SmartAutomation>> {
  AutomationNotifier() : super([
    SmartAutomation(id: 'r1', title: '检测到入睡，自动关闭所有灯光', description: '基于生理作息识别', icon: 'nights_stay', isRecommended: true),
    SmartAutomation(id: 'r2', title: '早晨光线唤醒', description: '根据作息基线推荐', icon: 'wb_sunny', isRecommended: true),
    SmartAutomation(id: 'e1', title: '日落时开启客厅灯', description: '日落后触发', icon: 'wb_twilight', isEnabled: true, lastRun: '18:30'),
    SmartAutomation(id: 'e2', title: '离家后关闭所有设备', description: '位置远离家', icon: 'sensor_door', isEnabled: true, lastRun: '08:15', error: '网关离线'),
    SmartAutomation(id: 'e3', title: '22:30 进入睡眠模式', description: '每天22:30', icon: 'bedtime', isEnabled: true, lastRun: '昨晚 22:30'),
  ]);

  void toggleAutomation(String id) {
    state = state.map((automation) {
      if (automation.id == id) {
        return automation.copyWith(isEnabled: !automation.isEnabled);
      }
      return automation;
    }).toList();
  }

  void acceptRecommendation(String id) {
    state = state.map((automation) {
      if (automation.id == id) {
        return automation.copyWith(isRecommended: false, isEnabled: true);
      }
      return automation;
    }).toList();
  }
}

final automationProvider = StateNotifierProvider<AutomationNotifier, List<SmartAutomation>>((ref) {
  return AutomationNotifier();
});
