import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/widgets.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // Mock State Variables
  bool _isLightOn = true;
  double _brightness = 28.0;
  double _colorTemp = 2700.0;
  String _currentMode = '睡前模式已开启';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // 1. 顶部导航区 (Top Navigation)
          _buildTopNavigation(context, colorScheme),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                // 2. 当前状态区 (Current State)
                _buildCurrentState(theme, colorScheme),
                const SizedBox(height: 24),
                // 3. 快捷控制区 (Quick Control)
                _buildQuickControl(theme, colorScheme),
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
      ),
    );
  }

  Widget _buildTopNavigation(BuildContext context, ColorScheme colorScheme) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: colorScheme.surface,
      elevation: 0,
      title: Row(
        children: [
          Text(
            '主卧',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
      actions: [
        IconButton(
          icon: Badge(
            child: const Icon(Icons.notifications_none),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCurrentState(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '晚上好',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bedtime, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    _currentMode,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$_isLightOn · 亮度 ${_brightness.toInt()}% · 暖橘光 ${_colorTemp.toInt()}K',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '2 台设备在线 · Edge Hub 正常',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.8),
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

  Widget _buildQuickControl(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快捷控制',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '主卧灯光',
                    style: theme.textTheme.titleMedium,
                  ),
                  Switch(
                    value: _isLightOn,
                    onChanged: (val) {
                      setState(() {
                        _isLightOn = val;
                        _currentMode = '手动调整（已熔断）';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.brightness_low),
                  Expanded(
                    child: Slider(
                      value: _brightness,
                      min: 0,
                      max: 100,
                      onChanged: (val) {
                        setState(() {
                          _brightness = val;
                          _currentMode = '手动调整（已熔断）';
                        });
                      },
                    ),
                  ),
                  const Icon(Icons.brightness_high),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.thermostat, color: Colors.orange),
                  Expanded(
                    child: Slider(
                      value: _colorTemp,
                      min: 2700,
                      max: 6500,
                      activeColor: Colors.orange.shade300,
                      onChanged: (val) {
                        setState(() {
                          _colorTemp = val;
                          _currentMode = '手动调整（已熔断）';
                        });
                      },
                    ),
                  ),
                  const Icon(Icons.thermostat, color: Colors.blue),
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
      {'name': '睡前', 'icon': Icons.bedtime},
      {'name': '夜起', 'icon': Icons.nightlight},
      {'name': '晨起', 'icon': Icons.wb_sunny},
      {'name': '阅读', 'icon': Icons.menu_book},
      {'name': '放松', 'icon': Icons.self_improvement},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '常用场景',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: scenes.length,
            itemBuilder: (context, index) {
              final scene = scenes[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(scene['icon'] as IconData, size: 32, color: colorScheme.primary),
                    const SizedBox(height: 8),
                    Text(
                      scene['name'] as String,
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
              );
            },
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
            Icon(Icons.auto_awesome, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'AI 推荐',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.secondaryContainer),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '基于本地 7 天使用计算',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '场景保存建议',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '最近连续 5 天在 23:40 将亮度调到 20%，是否保存为睡前模式？',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('忽略'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {},
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
        Text(
          '自动化状态',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.rule, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '已启用 3 个自动化',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '下次执行: 23:00 睡前模式',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
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
        Text(
          '设备摘要',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.router, color: colorScheme.primary),
                    const SizedBox(height: 8),
                    Text('2', style: theme.textTheme.headlineMedium),
                    Text('设备在线', style: theme.textTheme.labelMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.cloud_off, color: colorScheme.error),
                    const SizedBox(height: 8),
                    Text('0', style: theme.textTheme.headlineMedium),
                    Text('设备离线', style: theme.textTheme.labelMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.system_update, color: colorScheme.tertiary),
                    const SizedBox(height: 8),
                    Text('1', style: theme.textTheme.headlineMedium),
                    Text('固件可升级', style: theme.textTheme.labelMedium),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
