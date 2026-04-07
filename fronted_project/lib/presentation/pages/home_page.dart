import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/widgets.dart';
import '../../application/providers.dart';
import '../../models/device.dart';

class HomePage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? homeData;

  const HomePage({super.key, this.homeData});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _currentMode = '睡前模式已开启';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final deviceManager = ref.watch(deviceManagerProvider);

    return CustomScrollView(
      slivers: [
        // 1. 顶部导航区 (Top Navigation)
        _buildTopNavigation(context, colorScheme),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              // 2. 当前状态区 (Current State)
              _buildCurrentState(theme, colorScheme, deviceManager),
              const SizedBox(height: 24),
              // 3. 快捷控制区 (Quick Control)
              _buildQuickControl(theme, colorScheme, deviceManager),
              const SizedBox(height: 24),
              // 4. 常用场景区 (Common Scenes)
              _buildCommonScenes(theme, colorScheme),
              const SizedBox(height: 24),
              // 5. AI 推荐区 (AI Recommendations)
              _buildAiRecommendations(theme, colorScheme),
              const SizedBox(height: 24),
              // 6. 自动化状态区 (Automation State)
              _buildAutomationState(theme, colorScheme),
              const SizedBox(height: 24),
              // 7. 设备摘要区 (Device Summary)
              _buildDeviceSummary(theme, colorScheme),
              const SizedBox(height: 48), // Bottom padding
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTopNavigation(BuildContext context, ColorScheme colorScheme) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent, // 改为透明，让其融入 Scaffold 背景
      elevation: 0,
      title: Row(
        children: [
          const Text(
            '主卧',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white, // 深色模式字体
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.7)),
        ],
      ),
      actions: [
        IconButton(
          icon: Badge(
            backgroundColor: Colors.redAccent,
            smallSize: 8,
            child: const Icon(Icons.notifications_none, color: Colors.white70),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white70),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCurrentState(ThemeData theme, ColorScheme colorScheme, dynamic deviceManager) {
    final devicesCount = deviceManager.devices.length;
    final onlineCount = deviceManager.devices.where((d) => d.isOnline).length;
    
    // 找到第一个灯光设备展示其状态
    LightDevice? mainLight;
    try {
      mainLight = deviceManager.devices.firstWhere((d) => d is LightDevice) as LightDevice;
    } catch (_) {}

    final lightStatusText = mainLight != null 
        ? '${mainLight.isOn ? '已开启' : '已关闭'} · 亮度 ${mainLight.brightness.toInt()}% · 暖橘光 2700K'
        : '无灯光设备';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '晚上好',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E2E5A), Color(0xFF1E1E3F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigoAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bedtime, color: Colors.indigoAccent, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _currentMode,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                lightStatusText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.tealAccent),
                  const SizedBox(width: 6),
                  Text(
                    '$onlineCount/$devicesCount 台设备在线 · Edge Hub 正常',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickControl(ThemeData theme, ColorScheme colorScheme, dynamic deviceManager) {
    LightDevice? mainLight;
    try {
      mainLight = deviceManager.devices.firstWhere((d) => d is LightDevice) as LightDevice;
    } catch (_) {}

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快捷控制',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        mainLight?.name ?? '主卧灯光',
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  Switch(
                    value: mainLight?.isOn ?? false,
                    activeColor: Colors.indigoAccent,
                    onChanged: mainLight == null ? null : (val) {
                      deviceManager.toggleDevice(mainLight!.id);
                      setState(() {
                        _currentMode = '手动调整（已熔断）';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.brightness_low, color: Colors.white54, size: 20),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 6,
                        activeTrackColor: Colors.indigoAccent,
                        inactiveTrackColor: Colors.white10,
                        thumbColor: Colors.indigoAccent,
                        overlayColor: Colors.indigoAccent.withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: mainLight?.brightness ?? 0,
                        min: 0,
                        max: 100,
                        onChanged: mainLight == null ? null : (val) {
                          deviceManager.setDeviceStateById(mainLight!.id, mainLight.isOn, value: val);
                          setState(() {
                            _currentMode = '手动调整（已熔断）';
                          });
                        },
                      ),
                    ),
                  ),
                  const Icon(Icons.brightness_high, color: Colors.white, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.thermostat, color: Colors.orangeAccent, size: 20),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 6,
                        activeTrackColor: Colors.orangeAccent,
                        inactiveTrackColor: Colors.white10,
                        thumbColor: Colors.orangeAccent,
                        overlayColor: Colors.orangeAccent.withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: 2700, // mock temp
                        min: 2700,
                        max: 6500,
                        onChanged: mainLight == null ? null : (val) {
                          setState(() {
                            _currentMode = '手动调整（已熔断）';
                          });
                        },
                      ),
                    ),
                  ),
                  const Icon(Icons.thermostat, color: Colors.lightBlueAccent, size: 20),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommonScenes(ThemeData theme, ColorScheme colorScheme) {
    final scenes = [
      {'icon': Icons.bedtime, 'label': '睡前'},
      {'icon': Icons.nightlight_round, 'label': '夜起'},
      {'icon': Icons.wb_sunny, 'label': '晨起'},
      {'icon': Icons.menu_book, 'label': '阅读'},
      {'icon': Icons.movie, 'label': '放松'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '常用场景',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: scenes.map((scene) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: IconButton(
                        icon: Icon(scene['icon'] as IconData, color: Colors.indigoAccent.withOpacity(0.8)),
                        onPressed: () {
                          setState(() {
                            _currentMode = '${scene['label']}模式已开启';
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      scene['label'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAiRecommendations(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.indigoAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              'AI 推荐',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.indigoAccent.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.indigoAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '基于本地 7 天使用计算',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.indigoAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '场景保存建议',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '最近连续 5 天在 23:40 将亮度调到 20%，是否保存为睡前模式？',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('忽略', style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('立即采纳'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAutomationState(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flash_on, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              '自动化状态',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.greenAccent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '已运行 3 个自动化',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '最近运行: 离家模式 (08:30)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceSummary(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.devices, color: Colors.tealAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              '设备摘要',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildDeviceStatusCard(
              theme,
              colorScheme,
              icon: Icons.router,
              title: '网关',
              status: '在线',
              color: Colors.tealAccent,
            ),
            const SizedBox(width: 16),
            _buildDeviceStatusCard(
              theme,
              colorScheme,
              icon: Icons.sensors,
              title: '传感器',
              status: '2 异常',
              color: Colors.redAccent,
              isError: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeviceStatusCard(
    ThemeData theme,
    ColorScheme colorScheme, {
    required IconData icon,
    required String title,
    required String status,
    required Color color,
    bool isError = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isError ? color.withOpacity(0.5) : Colors.white.withOpacity(0.05), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isError ? color : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
