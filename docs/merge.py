import re

with open('/Users/aiden/Library/Application Support/trae/User/History/-1eb04ed3/0Wym.dart', 'r') as f:
    old_code = f.read()

with open('/tmp/agent_screen.dart', 'r') as f:
    agent_code = f.read()

old_code = old_code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:on_device_agent/on_device_agent.dart';")

old_pages = """  final List<Widget> _pages = const [
    DevicesPage(),
    ScenesPage(),
    AutomationsPage(),
    ProfilePage(),
  ];"""
new_pages = """  final List<Widget> _pages = const [
    DevicesPage(),
    ScenesPage(),
    AgentScreen(),
    AutomationsPage(),
    ProfilePage(),
  ];"""
old_code = old_code.replace(old_pages, new_pages)

old_dest = """  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: '家庭',
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_awesome_outlined),
      selectedIcon: Icon(Icons.auto_awesome),
      label: '场景',
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
  ];"""
new_dest = """  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: '家庭',
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
  ];"""
old_code = old_code.replace(old_dest, new_dest)

final_code = old_code + "\n\n// --- 独立的 Agent 交互界面 ---\n" + agent_code

with open('/Users/aiden/Documents/macinit/smarthome APP/smart_home_app/lib/main.dart', 'w') as f:
    f.write(final_code)
