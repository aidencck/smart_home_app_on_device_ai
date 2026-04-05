import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:on_device_agent/on_device_agent.dart';
import '../models/device.dart';
import '../services/device_service.dart';
import '../services/virtual_device_service.dart';
import '../theme/figma_colors.dart';
import '../features/agent/fallback_intent_service.dart';
import '../application/application.dart';
import '../application/providers.dart';
import 'widgets/widgets.dart';
import 'pages/pages.dart';
import 'pages/ai_agent_demo_page.dart'; // 引入 AI Agent Demo
import '../main.dart'; // for global variables if needed

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  final List<Widget> _pages = const [
    AiAgentDemoPage(), // 替换原来的 DevicesPage，将其作为 Home Tab
    DevicesPage(),     // 将原来的家庭设备列表移至第二个 Tab
    ScenesPage(),
    AgentScreen(),
    AutomationsPage(),
    ProfilePage(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: '控制台', // 对应 AiAgentDemoPage
    ),
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: '设备', // 对应原 DevicesPage
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_awesome_outlined),
      selectedIcon: Icon(Icons.auto_awesome),
      label: '场景',
    ),
    NavigationDestination(
      icon: Icon(Icons.smart_toy_outlined),
      selectedIcon: Icon(Icons.smart_toy),
      label: 'AI 助手',
    ),
    NavigationDestination(
      icon: Icon(Icons.rule_outlined),
      selectedIcon: Icon(Icons.rule),
      label: '自动化',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: '我的',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface, // M3 Surface
      appBar: AppBar(
        title: Text(
          _destinations[_index].label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _destinations,
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.primaryContainer,
      ),
    );
  }
}

// --- 可复用的设备卡片组件 ---
