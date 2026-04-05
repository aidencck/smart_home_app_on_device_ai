import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 添加 kDebugMode 支持
import 'package:on_device_agent/on_device_agent.dart';
import 'models/device.dart';
import 'services/device_service.dart';
import 'services/virtual_device_service.dart';
import 'theme/figma_colors.dart'; // 引入 Figma Design Tokens
import 'features/agent/fallback_intent_service.dart'; // 引入重构后的 Fallback 服务

void main() {
  runApp(const SmartHomeApp());
}

// --- 全局设备状态管理 ---
class DeviceManager extends ChangeNotifier {
  final DeviceService _service;
  List<SmartDevice> _devices = [];
  bool _isInitialized = false;

  DeviceManager(this._service) {
    _init();
  }

  Future<void> _init() async {
    await _service.initialize();
    _devices = await _service.getDevices();
    _isInitialized = true;
    notifyListeners();
  }

  bool get isInitialized => _isInitialized;

  List<Map<String, dynamic>> get devices => _devices.map((d) {
    return {
      'id': d.id,
      'name': d.name,
      'room': d.room,
      'type': d.type.name,
      'on': d.isOn,
      'icon': d.icon,
      if (d is AcDevice) 'temperature': d.temperature,
    };
  }).toList();

  Future<void> toggleDevice(String id) async {
    // 乐观更新
    final deviceIndex = _devices.indexWhere((d) => d.id == id);
    if (deviceIndex == -1) return;
    
    _devices[deviceIndex].isOn = !_devices[deviceIndex].isOn;
    notifyListeners();

    // 实际调用
    final success = await _service.toggleDevice(id);
    if (!success) {
      // 失败回滚
      _devices[deviceIndex].isOn = !_devices[deviceIndex].isOn;
      notifyListeners();
    }
  }

  Future<void> setDeviceState(String nameKeywords, bool isOn, {int? temperature}) async {
    bool changed = false;
    for (var i = 0; i < _devices.length; i++) {
      final d = _devices[i];
      if (d.name.contains(nameKeywords) || d.room.contains(nameKeywords)) {
        if (d.isOn != isOn) {
          d.isOn = isOn;
          changed = true;
        }
        if (temperature != null && d is AcDevice) {
          d.temperature = temperature;
          changed = true;
        }
        
        if (changed) {
          // 同步给 service
          await _service.setDeviceState(d.id, d.toJson());
        }
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  // 根据确切的 deviceId 设置状态，返回操作前后的状态
  Future<Map<String, dynamic>?> setDeviceStateById(String deviceId, bool isOn, {dynamic value}) async {
    try {
      final deviceIndex = _devices.indexWhere((d) => d.id == deviceId);
      if (deviceIndex == -1) return null;
      
      final device = _devices[deviceIndex];
      final beforeState = {
        'id': device.id,
        'name': device.name,
        'room': device.room,
        'type': device.type.name,
        'on': device.isOn,
        'icon': device.icon,
        if (device is AcDevice) 'temperature': device.temperature,
      };
      
      bool changed = false;
      if (device.isOn != isOn) {
        device.isOn = isOn;
        changed = true;
      }
      
      if (value != null && device is AcDevice) {
         int? temp = int.tryParse(value.toString());
         if (temp != null && device.temperature != temp) {
           device.temperature = temp;
           changed = true;
         }
      }
      
      if (changed) {
        await _service.setDeviceState(device.id, device.toJson());
        notifyListeners();
      }
      
      final afterState = {
        'id': device.id,
        'name': device.name,
        'room': device.room,
        'type': device.type.name,
        'on': device.isOn,
        'icon': device.icon,
        if (device is AcDevice) 'temperature': device.temperature,
      };

      return {
        'before': beforeState,
        'after': afterState,
      };
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> getDevicesByName(String nameKeywords) {
    return _devices
        .where(
          (d) =>
              d.name.contains(nameKeywords) ||
              d.room.contains(nameKeywords),
        )
        .map((d) {
          return {
            'id': d.id,
            'name': d.name,
            'room': d.room,
            'type': d.type.name,
            'on': d.isOn,
            'icon': d.icon,
            if (d is AcDevice) 'temperature': d.temperature,
          };
        })
        .toList();
  }

  Map<String, dynamic>? getDeviceByName(String nameKeywords) {
    try {
      final d = _devices.firstWhere(
        (d) =>
            d.name.contains(nameKeywords) ||
            d.room.contains(nameKeywords),
      );
      return {
        'id': d.id,
        'name': d.name,
        'room': d.room,
        'type': d.type.name,
        'on': d.isOn,
        'icon': d.icon,
        if (d is AcDevice) 'temperature': d.temperature,
      };
    } catch (e) {
      return null;
    }
  }
}

// 全局实例，注入虚拟服务（后续可替换为 RemoteDeviceService）
final deviceManager = DeviceManager(VirtualDeviceService());

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final List<Widget> _pages = const [
    DevicesPage(),
    ScenesPage(),
    AgentScreen(),
    AutomationsPage(),
    ProfilePage(),
  ];

  final List<NavigationDestination> _destinations = const [
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
class DeviceCard extends StatelessWidget {
  final Map<String, dynamic> device;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOn = device['on'] as bool;
    final name = device['name'] as String;
    final icon = device['icon'] as IconData;
    final room = device['room'] as String?;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: isOn ? 1 : 0,
      color: isOn
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onMoreTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: isOn
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    size: 28,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isOn)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4, right: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      if (onMoreTap != null)
                        GestureDetector(
                          onTap: onMoreTap,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isOn
                                  ? colorScheme.onPrimaryContainer.withValues(
                                      alpha: 0.1,
                                    )
                                  : colorScheme.onSurfaceVariant.withValues(
                                      alpha: 0.1,
                                    ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.more_horiz,
                              size: 16,
                              color: isOn
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isOn
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (room != null) ...[
                        Text(
                          room,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: isOn
                                ? colorScheme.onPrimaryContainer.withValues(
                                    alpha: 0.8,
                                  )
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '·',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOn
                                ? colorScheme.onPrimaryContainer.withValues(
                                    alpha: 0.8,
                                  )
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          isOn
                              ? (device.containsKey('temperature')
                                    ? '已开启 ${device['temperature']}°C'
                                    : '已开启')
                              : '已关闭',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isOn
                                ? colorScheme.onPrimaryContainer.withValues(
                                    alpha: 0.8,
                                  )
                                : colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeviceDetailSheet extends StatelessWidget {
  final String deviceId;

  const DeviceDetailSheet({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: deviceManager,
      builder: (context, _) {
        final device = deviceManager.devices.firstWhere(
          (d) => d['id'] == deviceId,
        );
        final isOn = device['on'] as bool;
        final name = device['name'] as String;
        final room = device['room'] as String;
        final icon = device['icon'] as IconData;
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // M3 顶部指示条
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 设备大图标
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isOn
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 64,
                  color: isOn
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              // 设备名称与房间
              Text(
                name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                room,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              // 开关控制按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '电源开关',
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Switch(
                    value: isOn,
                    onChanged: (_) {
                      deviceManager.toggleDevice(deviceId);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 根据设备类型展示调节控件
              if (deviceId.startsWith('light'))
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '亮度调节',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(value: 0.8, onChanged: (val) {}),
                  ],
                )
              else if (deviceId.startsWith('ac'))
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '温度调节',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton.filledTonal(
                          onPressed: () {},
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          '24°C',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: deviceManager,
      builder: (context, _) {
        if (!deviceManager.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: deviceManager.devices.length,
          itemBuilder: (context, i) {
            final d = deviceManager.devices[i];
            return DeviceCard(
              device: d,
              onTap: () => deviceManager.toggleDevice(d['id'] as String),
              onMoreTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      DeviceDetailSheet(deviceId: d['id'] as String),
                );
              },
            );
          },
        );
      },
    );
  }
}

class ScenesPage extends StatelessWidget {
  const ScenesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> scenes = [
      {
        'title': '回家模式',
        'subtitle': '开启客厅灯、空调',
        'icon': Icons.home_filled,
        'color': Colors.blue,
      },
      {
        'title': '离家模式',
        'subtitle': '关闭所有设备，开启安防',
        'icon': Icons.directions_walk,
        'color': Colors.orange,
      },
      {
        'title': '观影模式',
        'subtitle': '关闭主灯，开启电视',
        'icon': Icons.movie,
        'color': Colors.purple,
      },
      {
        'title': '睡眠模式',
        'subtitle': '关闭所有灯光，空调静音',
        'icon': Icons.nights_stay,
        'color': Colors.indigo,
      },
      {
        'title': '阅读模式',
        'subtitle': '开启书房台灯',
        'icon': Icons.menu_book,
        'color': Colors.teal,
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: scenes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final scene = scenes[index];
        final colorScheme = Theme.of(context).colorScheme;
        return Card(
          elevation: 0,
          color: colorScheme.surfaceContainerHighest,
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已执行：${scene['title']}'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (scene['color'] as MaterialColor).withValues(
                        alpha: 0.2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      scene['icon'] as IconData,
                      color: scene['color'] as Color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scene['title'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          scene['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('已执行：${scene['title']}'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('执行'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AutomationsPage extends StatelessWidget {
  const AutomationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final automations = [
      {'title': '日落时开启客厅灯', 'active': true},
      {'title': '离家后关闭所有设备', 'active': true},
      {'title': '22:30 进入睡眠模式', 'active': false},
    ];
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: automations.length,
      itemBuilder: (context, i) {
        final a = automations[i];
        return Card(
          color: colorScheme.surfaceContainerLow,
          margin: const EdgeInsets.only(bottom: 12),
          child: SwitchListTile(
            title: Text(
              a['title'] as String,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            value: a['active'] as bool,
            onChanged: (_) {},
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        // 1. 用户信息卡片
        Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: const NetworkImage(
                'https://api.dicebear.com/7.x/avataaars/png?seed=Felix',
              ),
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aiden',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.diamond,
                          size: 14,
                          color: colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pro 会员',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 32),

        // 2. 数据概览面板
        Row(
          children: [
            Expanded(child: _buildStatCard(context, '设备', '6', Icons.devices)),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(context, '场景', '5', Icons.auto_awesome),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(context, '自动化', '3', Icons.rule)),
          ],
        ),
        const SizedBox(height: 32),

        // 3. 核心功能区 (M3 Card 分组)
        Text(
          '核心管理',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: colorScheme.surfaceContainerLow,
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _buildListTile(
                context: context,
                icon: Icons.home_outlined,
                title: '家庭与房间管理',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeManagementPage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildListTile(
                context: context,
                icon: Icons.hub_outlined,
                title: '网关与 Matter 集成',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GatewayIntegrationPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 4. 服务与设置区
        Text(
          '服务与设置',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: colorScheme.surfaceContainerLow,
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _buildListTile(
                context: context,
                icon: Icons.notifications_outlined,
                title: '通知与告警中心',
                color: Colors.redAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationCenterPage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildListTile(
                context: context,
                icon: Icons.cloud_outlined,
                title: '云存储服务',
                subtitle: '摄像头云端回放',
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CloudStoragePage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildListTile(
                context: context,
                icon: Icons.settings_outlined,
                title: '通用设置',
                color: colorScheme.onSurfaceVariant,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GeneralSettingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String count,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }
}

// --- 二级界面：家庭管理 (Home Management) ---
class HomeManagementPage extends StatefulWidget {
  const HomeManagementPage({super.key});

  @override
  State<HomeManagementPage> createState() => _HomeManagementPageState();
}

class _HomeManagementPageState extends State<HomeManagementPage> {
  final List<Map<String, dynamic>> _members = [
    {
      'name': 'Aiden',
      'role': '管理员',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/png?seed=Felix',
    },
    {
      'name': '妈妈',
      'role': '成员',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/png?seed=Jane',
    },
    {
      'name': '爸爸',
      'role': '成员',
      'avatar': 'https://api.dicebear.com/7.x/avataaars/png?seed=John',
    },
  ];

  final List<Map<String, dynamic>> _rooms = [
    {'name': '客厅', 'deviceCount': 3, 'icon': Icons.weekend_outlined},
    {'name': '主卧', 'deviceCount': 1, 'icon': Icons.bed_outlined},
    {'name': '书房', 'deviceCount': 1, 'icon': Icons.desktop_mac_outlined},
    {'name': '大门', 'deviceCount': 1, 'icon': Icons.door_front_door_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '家庭与房间管理',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 当前家庭卡片
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '我的家',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '当前家庭',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '📍 深圳市南山区科技园',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 家庭成员
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '家庭成员',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('邀请'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _members.length,
              separatorBuilder: (context, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final m = _members[index];
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(m['avatar'] as String),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      m['name'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      m['role'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 32),

          // 房间管理
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '房间管理',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('添加'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: _rooms.length,
            itemBuilder: (context, index) {
              final r = _rooms[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      r['icon'] as IconData,
                      color: Colors.blueAccent,
                      size: 28,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r['name'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${r['deviceCount']} 个设备',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- 二级界面：网关与 Matter 集成 ---
class GatewayIntegrationPage extends StatelessWidget {
  const GatewayIntegrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '网关与 Matter 集成',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.hub, color: Colors.purple, size: 32),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '家庭中枢 (主网关)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '在线 · 固件版本 v2.1.4',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('重启')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Matter 设备集成',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  '支持扫描 Matter 二维码或输入配对码添加跨生态设备',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('添加 Matter 设备'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 二级界面：通知与告警中心 ---
class NotificationCenterPage extends StatelessWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '通知与告警',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
        actions: [TextButton(onPressed: () {}, child: const Text('全部已读'))],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        separatorBuilder: (context, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final alerts = [
            {
              'title': '门锁异常打开',
              'time': '10 分钟前',
              'icon': Icons.lock_open,
              'color': Colors.red,
            },
            {
              'title': '检测到客厅有人移动',
              'time': '2 小时前',
              'icon': Icons.directions_walk,
              'color': Colors.orange,
            },
            {
              'title': '固件更新可用',
              'time': '昨天',
              'icon': Icons.system_update,
              'color': Colors.blue,
            },
          ];
          final alert = alerts[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  alert['icon'] as IconData,
                  color: alert['color'] as Color,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert['time'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- 二级界面：云存储服务 ---
class CloudStoragePage extends StatelessWidget {
  const CloudStoragePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '云存储服务',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF334155)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '高级云端回放',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Icon(Icons.cloud_done, color: Colors.greenAccent),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '您的云存储服务将于 2026-10-01 到期',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[600],
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: const Text('立即续费 (享受 8 折优惠)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '服务设备',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            tileColor: Theme.of(context).colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: Icon(
              Icons.videocam,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('客厅摄像头'),
            subtitle: const Text('支持 30 天滚动事件录像'),
            trailing: Switch(value: true, onChanged: (v) {}),
          ),
        ],
      ),
    );
  }
}

// --- 二级界面：通用设置 ---
class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '通用设置',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('深色模式'),
                  trailing: Text(
                    '跟随系统',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('语言与地区'),
                  trailing: Text(
                    '简体中文',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.update),
                  title: const Text('检查更新'),
                  trailing: Text(
                    '已是最新',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                '退出登录',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

// --- 独立的 Agent 交互界面 ---
class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _chatHistory = [];
  bool _isInitializing = false;
  bool _isProcessing = false;
  bool _isListening = false; // 语音状态

  final List<String> _processingSteps = [];
  bool _isProcessingStepsExpanded = true;
  double _processingStepsFontSize = 12.0;

  late final SmartHomeAgent _agent;

  String? _pendingMessage;

  @override
  void initState() {
    super.initState();
    _agent = SmartHomeAgent();
    _initAgent();
  }

  Future<void> _initAgent() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      // 尝试真实加载底层模型
      await _agent.initialize(modelPath: "assets/models/gemma-2b-q4.bin");

      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        if (_agent.isLowMemory) {
          _chatHistory.add({
            "role": "system",
            "text": "⚠️ 检测到设备可用内存不足，已自动为您开启省内存模式 (可能会影响回复速度)。",
          });
        } else {
          _chatHistory.add({
            "role": "system",
            "text": "⚡️ 端侧 AI 已就绪。您的对话数据完全本地处理，无需联网。",
          });
        }
      });

      // 模拟主动推荐引擎 (Proactive Engine)
      _checkProactiveRecommendations();
      _processPendingMessage();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        // 如果没有 GGUF 文件，回退到 Mock 提示
        _chatHistory.add({
          "role": "system",
          "text": "⚠️ 未检测到本地模型文件。已自动切换到模拟推理模式。\n您可以说：“有点冷” 或 “把灯打开”",
        });
      });

      // Mock 模式下也触发主动推荐
      _checkProactiveRecommendations();
      _processPendingMessage();
    }
  }

  void _checkProactiveRecommendations() async {
    // 延迟一段时间，模拟后台分析
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // 基于时间的简单规则引擎 (Mock)
    final hour = DateTime.now().hour;
    if (hour >= 22 || hour < 6) {
      setState(() {
        _chatHistory.add({
          "role": "agent",
          "text": "🌙 发现现在已经很晚了，是否需要为您开启「睡眠模式」？(将关闭所有灯光和电视，空调调至 26度)",
          "isProactive": true,
          "suggestionAction": "睡眠模式",
        });
      });
      _scrollToBottom();
    } else if (hour >= 18 && hour < 22) {
      setState(() {
        _chatHistory.add({
          "role": "agent",
          "text": "👋 欢迎回家！检测到客厅光线较暗，是否为您开启「回家模式」？",
          "isProactive": true,
          "suggestionAction": "回家模式",
        });
      });
      _scrollToBottom();
    }
  }

  Future<void> _handleSendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _chatHistory.add({"role": "user", "text": text});
      _isProcessing = true;
      _textController.clear();
    });

    _scrollToBottom();

    if (_isInitializing) {
      _pendingMessage = text;
      setState(() {
        _chatHistory.add({
          "role": "system",
          "text": "正在唤醒 AI，准备完成后将立即为您执行该指令...",
          "isPendingTip": true,
        });
      });
      _scrollToBottom();
      return;
    }

    await _executeMessage(text);
  }

  Future<void> _processPendingMessage() async {
    setState(() {
      _chatHistory.removeWhere((msg) => msg['isPendingTip'] == true);
    });

    if (_pendingMessage != null) {
      final msg = _pendingMessage!;
      _pendingMessage = null;
      await _executeMessage(msg);
    }
  }

  Future<void> _executeMessage(String text) async {
    setState(() {
      _processingSteps.clear();
      _isProcessingStepsExpanded = true;
    });

    // 延迟一点以展示 UI 加载动画
    await Future.delayed(const Duration(milliseconds: 500));

    String responseText = "指令已执行。";
    List<Map<String, dynamic>> affectedDevices = [];
    Map<String, dynamic>? beforeState;
    Map<String, dynamic>? afterState;
    PerformanceMetrics? metrics;

    try {
      final result = await _agent.handleUserQuery(
        text,
        availableDevices: deviceManager.devices,
        onProgress: (step) {
          if (mounted) {
            setState(() {
              if (!_processingSteps.contains(step)) {
                _processingSteps.add(step);
              }
            });
            _scrollToBottom();
          }
        },
      );

      metrics = result.metrics;

      if (result.success) {
        if (result.intent != null && result.intent?.deviceId != 'system') {
          // 真正的设备控制
          final intent = result.intent!;
          final isOn = intent.action == 'turn_on' || intent.action == 'set_temp';
          
          final stateChanges = await deviceManager.setDeviceStateById(
            intent.deviceId, 
            isOn, 
            value: intent.value,
          );
          
          if (stateChanges != null) {
            beforeState = stateChanges['before'];
            afterState = stateChanges['after'];
            affectedDevices = [afterState!];
            
            // 只有成功找到设备并改变状态才算真正执行成功
            responseText = "🤖 已为您执行：${intent.action == 'turn_on' ? '打开' : intent.action == 'turn_off' ? '关闭' : '调节'}了 ${afterState['name'] ?? intent.deviceId}";
            if (intent.value != null) {
               responseText += " (参数: ${intent.value})";
            }
          } else {
            // 解析到了意图，但是设备管理器里没找到这个设备，可能只是想打开当前界面里的某个大类设备（如：有点冷->开空调）
            // 抛出异常走 Fallback 模糊意图降级体验
            throw Exception("Exact device not found by ID: ${intent.deviceId}, fallback to fuzzy match");
          }
        } else {
          // RAG 或纯回复
          responseText = "🤖 ${result.message ?? '已完成'}";
        }
      } else {
        responseText = "❌ 抱歉，未能识别该指令关联的设备。(${result.message ?? ''})";
      }
    } catch (e) {
      // 模拟一些处理步骤用于UI展示
      if (mounted) {
        setState(() => _processingSteps.add("理解用户意图并检索日志... \n[RAG] ${text.contains("日志") ? '命中记录' : '无需检索'}"));
      }
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() => _processingSteps.add("构建设备上下文环境... \n[Devices] 当前可控设备 ${deviceManager.devices.length} 台"));
      }
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() => _processingSteps.add("调用端侧大模型进行推理... \n[Prompt] 正在构建本地指令集及当前状态信息..."));
      }
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() => _processingSteps.add("解析并执行控制指令... \n[Action] 准备分发设备控制协议"));
      }

      // 获取当前对话上下文来增强 Fallback
      final isContinuing = _chatHistory.length > 2 && text.length < 5;

      // Fallback 体验，并联动全局状态 (重构后使用独立的 FallbackIntentService)
      final fallbackService = FallbackIntentService(deviceManager);
      final fallbackResult = await fallbackService.handleFallbackIntent(text, isContinuing);
      
      responseText = fallbackResult.responseText;
      affectedDevices = fallbackResult.affectedDevices;
      beforeState = fallbackResult.beforeState;
      afterState = fallbackResult.afterState;

      _agent.contextProvider.addMessage('user', text);
      _agent.contextProvider.addMessage('agent', responseText);
        _agent.contextProvider.addMessage('user', text);
        _agent.contextProvider.addMessage('agent', responseText);
      } else {
        responseText = "🤖 抱歉，我不太明白您的意思。您可以尝试让我控制空调、灯光或电视。";
      }
    }

    setState(() {
      _isProcessing = false;
      _chatHistory.add(<String, dynamic>{
        "role": "agent",
        "text": responseText,
        if (affectedDevices.isNotEmpty) "devices": affectedDevices,
        "beforeState": beforeState,
        "afterState": afterState,
        "metrics": metrics,
        "steps": List<String>.from(_processingSteps), // 保存当前的思维链
      }..removeWhere((key, value) => value == null));
    });

    _scrollToBottom();
  }

  void _toggleVoiceInput() async {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      // 模拟语音录入 UI 状态
      setState(() {
        _chatHistory.add({
          "role": "system",
          "text": "🎙️ 正在聆听 (端侧 ASR 识别中)...",
          "isVoiceIndicator": true,
        });
      });
      _scrollToBottom();

      // 模拟录音和端侧 ASR (Whisper) 转换时间
      await Future.delayed(const Duration(seconds: 2));

      // 移除聆听指示器
      setState(() {
        _chatHistory.removeWhere((msg) => msg['isVoiceIndicator'] == true);
        _isListening = false;
      });

      // 模拟 ASR 识别结果并直接发送
      final asrResult = "帮我把主卧空调温度调高一点";
      _textController.text = asrResult;
      // 稍微停留一下让用户看到识别结果
      await Future.delayed(const Duration(milliseconds: 500));
      _handleSendMessage(asrResult);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildWelcomeLoading() {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.smart_toy,
                        size: 32,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "正在唤醒端侧大模型...",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "您可以直接输入指令，就绪后将立即执行",
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCommands() {
    final commands = ["我有点冷", "看电影", "出门模式", "打扫一下", "关掉它", "调高一点"];
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: commands.length,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(
              commands[index],
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            onPressed: () {
              _textController.text = commands[index];
              _handleSendMessage(commands[index]);
            },
            backgroundColor: colorScheme.surfaceContainerHigh,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProcessingSteps() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isProcessingStepsExpanded = !_isProcessingStepsExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "AI 正在执行...",
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Font size controls
                  if (_isProcessingStepsExpanded) ...[
                    IconButton(
                      icon: const Icon(Icons.text_decrease, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _processingStepsFontSize = (_processingStepsFontSize - 2).clamp(10.0, 24.0);
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.text_increase, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _processingStepsFontSize = (_processingStepsFontSize + 2).clamp(10.0, 24.0);
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    _isProcessingStepsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          
          // Steps list
          if (_isProcessingStepsExpanded && _processingSteps.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 44.0, right: 16.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _processingSteps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isLast = index == _processingSteps.length - 1;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isLast ? Icons.pending_outlined : Icons.check_circle,
                          size: _processingStepsFontSize + 4,
                          color: isLast ? colorScheme.primary : colorScheme.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step,
                            style: TextStyle(
                              fontSize: _processingStepsFontSize,
                              color: isLast ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // 聊天记录展示区
        if (_isInitializing && _chatHistory.isEmpty)
          _buildWelcomeLoading()
        else
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final msg = _chatHistory[index];
                final role = msg['role'];
                final text = msg['text'];

                if (role == 'system') {
                  return _buildSystemMessage(text);
                }

                return _buildChatMessage(msg);
              },
            ),
          ),

        // 处理中的思考动画及进度
        if (_isProcessing)
          _buildProcessingSteps(),

        // 快捷指令推荐
        if (!_isInitializing && !_isProcessing) _buildQuickCommands(),

        // 底部输入区
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          decoration: BoxDecoration(color: colorScheme.surfaceContainer),
          child: SafeArea(
            child: Row(
              children: [
                // 语音输入按钮
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening
                        ? colorScheme.error
                        : colorScheme.primary,
                  ),
                  onPressed: (_isInitializing || _isProcessing)
                      ? null
                      : _toggleVoiceInput,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: TextField(
                        controller: _textController,
                        enabled: !_isProcessing,
                        decoration: InputDecoration(
                          hintText: _isInitializing
                              ? 'AI唤醒中，您可以直接输入...'
                              : '输入指令 (如: 我有点冷)',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: _handleSendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 发送按钮
                  IconButton.filled(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: _isProcessing
                        ? null
                        : () => _handleSendMessage(_textController.text.trim()),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemMessage(String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> msg) {
    final role = msg['role'];
    final text = msg['text'];
    final devices = msg['devices'] as List<Map<String, dynamic>>?;
    final beforeState = msg['beforeState'] as Map<String, dynamic>?;
    final afterState = msg['afterState'] as Map<String, dynamic>?;
    final metrics = msg['metrics'] as PerformanceMetrics?;
    final steps = msg['steps'] as List<String>?;
    
    final isProactive = msg['isProactive'] == true;
    final suggestionAction = msg['suggestionAction'] as String?;
    final isUser = role == 'user';
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser
                  ? colorScheme.primaryContainer
                  : (isProactive
                        ? colorScheme.secondaryContainer
                        : colorScheme.surfaceContainer),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 20),
              ),
              border: isProactive
                  ? Border.all(
                      color: colorScheme.secondary.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isProactive)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "主动推荐",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // 展示思维链步骤 (如果存在)
                if (!isUser && steps != null && steps.isNotEmpty) ...[
                  ExpansionTile(
                    title: Row(
                      children: [
                        Icon(Icons.psychology, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          "执行步骤",
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 12.0),
                    iconColor: colorScheme.primary,
                    collapsedIconColor: colorScheme.onSurfaceVariant,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: steps.map((step) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: colorScheme.tertiary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    step,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                ],

                Text(
                  text,
                  style: TextStyle(
                    color: isUser
                        ? colorScheme.onPrimaryContainer
                        : (isProactive
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurface),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                if (beforeState != null && afterState != null) ...[
                  const SizedBox(height: 12),
                  Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  Text(
                    "状态变化",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildStateChip(beforeState, colorScheme),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.arrow_forward, size: 16, color: colorScheme.onSurfaceVariant),
                      ),
                      _buildStateChip(afterState, colorScheme, isAfter: true),
                    ],
                  ),
                ],
                if (isProactive && suggestionAction != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: OutlinedButton(
                      onPressed: () {
                        _textController.text = "执行$suggestionAction";
                        _handleSendMessage("执行$suggestionAction");
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.secondary,
                        side: BorderSide(color: colorScheme.secondary),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 36),
                      ),
                      child: Text("一键执行", style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                if (!isUser && kDebugMode && metrics != null)
                  _buildMetricsPanel(metrics, colorScheme),
              ],
            ),
          ),
          if (devices != null && devices.isNotEmpty && !isUser && beforeState == null)
            Container(
              margin: const EdgeInsets.only(bottom: 16, left: 4),
              height: 120, // 稍微增加高度以适应可能有更多内容的卡片
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: devices.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return SizedBox(
                    width: 180, // 增加宽度以提供更好的阅读体验
                    child: ListenableBuilder(
                      listenable: deviceManager,
                      builder: (context, _) {
                        return DeviceCard(
                          device: device,
                          onTap: () => deviceManager.toggleDevice(
                            device['id'] as String,
                          ),
                          onMoreTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => DeviceDetailSheet(
                                deviceId: device['id'] as String,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStateChip(Map<String, dynamic> state, ColorScheme colorScheme, {bool isAfter = false}) {
    final isOn = state['on'] == true;
    final temp = state['temperature'];
    
    String stateText = isOn ? "开启" : "关闭";
    if (isOn && temp != null) {
      stateText += " ($temp°C)";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAfter ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAfter ? colorScheme.primary : Colors.transparent,
          width: 1,
        )
      ),
      child: Text(
        stateText,
        style: TextStyle(
          fontSize: 12,
          color: isAfter ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildMetricsPanel(PerformanceMetrics metrics, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, size: 14, color: colorScheme.tertiary),
              const SizedBox(width: 4),
              Text(
                "性能追踪 (Debug 专供)",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildMetricRow("端侧推理耗时:", "${metrics.inferenceTimeMs} ms", colorScheme),
          _buildMetricRow("全链路总耗时:", "${metrics.totalTimeMs} ms", colorScheme),
          _buildMetricRow("生成速度:", "${metrics.tokensPerSecond.toStringAsFixed(1)} tk/s", colorScheme),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
