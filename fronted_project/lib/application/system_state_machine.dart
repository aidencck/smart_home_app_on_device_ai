import 'package:flutter/material.dart';

enum SystemState {
  awake,      // 清醒模式：灯光全亮，环境舒适
  sleepPrep,  // 助眠准备：灯光变暖，播放 ASMR，床体升至 15°
  deepSleep,  // 深睡模式：全屋灯光熄灭，床体放平且硬锁，UI 沉睡
  sunrise,    // 日出唤醒：灯光模拟日出渐亮，床体微震
}

class SystemStateMachine extends ChangeNotifier {
  SystemState _currentState = SystemState.awake;
  SystemState get currentState => _currentState;

  // 状态自动切换的逻辑（模拟生理反馈）
  void updateState(SystemState newState) {
    if (_currentState == newState) return;
    
    _currentState = newState;
    _handleStateTransition(newState);
    notifyListeners();
  }

  // 状态机核心逻辑：处理不同状态下的设备联动
  void _handleStateTransition(SystemState state) {
    switch (state) {
      case SystemState.awake:
        // 清醒模式逻辑
        break;
      case SystemState.sleepPrep:
        // 助眠准备：环境自动变暗
        break;
      case SystemState.deepSleep:
        // 深睡锁定：禁止所有手动调节，进入物理安全态
        break;
      case SystemState.sunrise:
        // 日出唤醒：渐进式唤醒
        break;
    }
  }

  // 获取当前状态的视觉配置（主题色等）
  Color get stateThemeColor {
    switch (_currentState) {
      case SystemState.awake: return Colors.indigoAccent;
      case SystemState.sleepPrep: return Colors.orangeAccent;
      case SystemState.deepSleep: return Colors.deepPurpleAccent;
      case SystemState.sunrise: return Colors.amberAccent;
    }
  }

  String get stateName {
    switch (_currentState) {
      case SystemState.awake: return "清醒模式";
      case SystemState.sleepPrep: return "助眠准备";
      case SystemState.deepSleep: return "深睡模式";
      case SystemState.sunrise: return "日出唤醒";
    }
  }
}
