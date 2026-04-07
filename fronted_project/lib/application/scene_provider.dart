import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scene.dart';

class SceneNotifier extends StateNotifier<List<SmartScene>> {
  SceneNotifier() : super([
    SmartScene(id: '1', name: '睡前', description: '关闭大灯，开启暖光', icon: 'bedtime', isPreset: true, isActive: true),
    SmartScene(id: '2', name: '夜起', description: '微弱暖光照明', icon: 'nights_stay', isPreset: true),
    SmartScene(id: '3', name: '晨起', description: '灯光渐亮，开启窗帘', icon: 'wb_sunny', isPreset: true),
    SmartScene(id: '4', name: '阅读', description: '明亮护眼白光', icon: 'menu_book', isPreset: true),
    SmartScene(id: '5', name: '放松', description: '昏暗舒适色调', icon: 'spa', isPreset: true),
  ]);

  void toggleScene(String id) {
    state = state.map((scene) {
      if (scene.id == id) {
        return scene.copyWith(isActive: !scene.isActive);
      }
      return scene;
    }).toList();
  }
}

final sceneProvider = StateNotifierProvider<SceneNotifier, List<SmartScene>>((ref) {
  return SceneNotifier();
});
