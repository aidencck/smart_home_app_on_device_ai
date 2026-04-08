import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_shell.dart';
import 'pages/login_page.dart';
import 'pages/privacy_opt_in_page.dart';
import 'pages/ai_agent_demo_page.dart'; // 引入新建的 AI 预览页面
import '../application/auth/auth_provider.dart';
import '../application/linkage_manager.dart';
import 'package:flutter/material.dart';
import '../theme/figma_colors.dart';

class SmartHomeApp extends ConsumerWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 启动联动管理器
    ref.watch(linkageManagerProvider);
    
    final authState = ref.watch(authProvider);

    Widget homeWidget;
    if (!authState.isAuthenticated) {
      homeWidget = const LoginPage();
    } else if (!authState.hasAgreedToPrivacy) {
      homeWidget = const PrivacyOptInPage();
    } else {
      homeWidget = const HomeShell();
    }

    return MaterialApp(
      title: 'Smart Home',
      themeMode: ThemeMode.dark, // 强制深色模式
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D5FEF), // 深邃的紫蓝色调 (Indigo)
          brightness: Brightness.dark,
          surface: const Color(0xFF1A1A2E), // 主背景深蓝
          surfaceContainer: const Color(0xFF252542), // 卡片颜色
          surfaceContainerHighest: const Color(0xFF2E2E50),
          primary: const Color(0xFF5D5FEF), // 强调色
          onPrimary: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF14142B), // Scaffold 极致深邃
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: FigmaColors.primaryBlue,
          brightness: Brightness.light,
          surfaceContainer: FigmaColors.surfaceContainer,
          surfaceContainerHighest: FigmaColors.surfaceContainerHighest,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: false),
      ),
      home: homeWidget,
    );
  }
}

