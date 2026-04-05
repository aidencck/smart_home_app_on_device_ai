import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smart_home_app/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Test App Startup and AgentScreen Loading Performance', (WidgetTester tester) async {
    // 1. 测量应用启动耗时
    final stopwatch = Stopwatch()..start();

    // 启动应用
    app.main();
    
    // 等待首帧渲染完成（包括各种初始化的微任务）
    await tester.pumpAndSettle();
    
    final startupTime = stopwatch.elapsedMilliseconds;
    print('=========================================');
    print('📊 [Performance Data] App 启动时间: $startupTime ms');
    
    // 验证已经进入了应用主页
    expect(find.text('AI 助手'), findsWidgets); 
    
    // 2. 验证预加载过程
    // 在首页停留2秒，允许 AgentManager.preload() 在后台执行 _initAsync()
    print('⏳ 正在等待后台 preload() 执行 (2秒)...');
    await tester.pump(const Duration(seconds: 2));
    
    // 3. 测量切换到 AgentScreen 的耗时
    stopwatch.reset();
    
    // 找到底部导航栏的 "AI 助手" 并点击
    final aiAgentTab = find.text('AI 助手').last; // 底部导航栏上的文字
    await tester.tap(aiAgentTab);
    
    // 等待页面切换动画和渲染完成
    await tester.pumpAndSettle();
    final tabSwitchTime = stopwatch.elapsedMilliseconds;
    
    print('📊 [Performance Data] 切换到 AI 助手标签耗时: $tabSwitchTime ms');
    
    // 4. 验证预加载是否有效
    // 如果预加载成功且完成，则不应该看到 "正在唤醒端侧大模型..." 
    final isInitializingText = find.text('正在唤醒端侧大模型...');
    
    if (isInitializingText.evaluate().isNotEmpty) {
      print('⚠️ [Warning] AI 助手仍在初始化中，预加载可能未完成。');
      // 等待初始化完成
      await tester.pumpAndSettle(const Duration(seconds: 3));
    } else {
      print('✅ [Success] AI 助手已就绪，预加载有效 (未阻塞 UI，且用户切换时立即可用)！');
    }
    
    // 检查是否显示了欢迎消息或输入框
    expect(find.byType(TextField), findsOneWidget);
    print('=========================================');
    
    // 返回报告数据
    // binding.reportData = {
    //   'startup_time_ms': startupTime,
    //   'tab_switch_time_ms': tabSwitchTime,
    // };
  });
}
