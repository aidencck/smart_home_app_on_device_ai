import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_shell.dart';
import 'pages/login_page.dart';
import 'pages/privacy_opt_in_page.dart';
import 'pages/ai_agent_demo_page.dart'; // 引入新建的 AI 预览页面
import '../application/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import '../theme/figma_colors.dart';

class SmartHomeApp extends ConsumerWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

