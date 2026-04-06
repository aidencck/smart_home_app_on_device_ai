import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 模拟的全局状态 Provider，用于切换是否展示骨架屏
final sceneLoadingProvider = StateProvider<bool>((ref) => false);

class SceneScreen extends ConsumerStatefulWidget {
  const SceneScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SceneScreen> createState() => _SceneScreenState();
}

class _SceneScreenState extends ConsumerState<SceneScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(sceneLoadingProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('场景空间', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: '预设'),
            Tab(text: '我的'),
            Tab(text: '收藏'),
          ],
        ),
        actions: [
          Switch(
            value: isLoading,
            activeColor: colorScheme.primary,
            onChanged: (val) => ref.read(sceneLoadingProvider.notifier).state = val,
          )
        ],
      ),
      body: isLoading 
          ? const _SceneListSkeleton() 
          : TabBarView(
              controller: _tabController,
              children: [
                const _PresetScenesList(),
                const Center(child: Text('我的场景空空如也')),
                const Center(child: Text('暂无收藏场景')),
              ],
            ),
    );
  }
}

class _SceneListSkeleton extends StatelessWidget {
  const _SceneListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _SkeletonBox(height: 24, width: 100, borderRadius: 4),
                  _SkeletonBox(height: 24, width: 40, borderRadius: 12),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  3,
                  (index) => const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: _SkeletonBox(height: 32, width: 32, borderRadius: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PresetScenesList extends StatelessWidget {
  const _PresetScenesList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scenes = [
      {'name': '睡前', 'status': 'Active', 'icon': Icons.bedtime},
      {'name': '夜起', 'status': 'Inactive', 'icon': Icons.nights_stay},
      {'name': '晨起', 'status': 'Inactive', 'icon': Icons.wb_sunny},
      {'name': '阅读', 'status': 'Inactive', 'icon': Icons.menu_book},
      {'name': '放松', 'status': 'Inactive', 'icon': Icons.spa},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: scenes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final scene = scenes[index];
        final isActive = scene['status'] == 'Active';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SceneDetailScreen(sceneName: scene['name'] as String),
              ),
            );
          },
          child: Card(
            elevation: isActive ? 2 : 0,
            color: isActive ? colorScheme.primaryContainer : colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: isActive ? colorScheme.primary.withOpacity(0.5) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isActive ? colorScheme.primary.withOpacity(0.2) : colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      scene['icon'] as IconData,
                      color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scene['name'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isActive ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isActive ? '运行中' : '点击激活',
                          style: TextStyle(
                            color: isActive ? colorScheme.onPrimaryContainer.withOpacity(0.8) : colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        )
                      ],
                    ),
                  ),
                  if (isActive)
                    Icon(Icons.check_circle, color: colorScheme.primary)
                  else
                    Icon(Icons.play_circle_outline, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// 场景详情页与骨架屏
class SceneDetailScreen extends ConsumerWidget {
  final String sceneName;
  const SceneDetailScreen({Key? key, required this.sceneName}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 复用列表页的加载状态或独立状态
    final isLoading = ref.watch(sceneLoadingProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('$sceneName 详情', style: TextStyle(color: colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: isLoading ? const _SceneDetailSkeleton() : Center(child: Text('场景详细配置区域', style: TextStyle(color: colorScheme.onSurface))),
    );
  }
}

class _SceneDetailSkeleton extends StatelessWidget {
  const _SceneDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部封面图/状态卡片骨架
          const _SkeletonBox(height: 200, width: double.infinity, borderRadius: 24),
          const SizedBox(height: 24),
          // 场景执行动作标题骨架
          const _SkeletonBox(height: 24, width: 150, borderRadius: 4),
          const SizedBox(height: 16),
          // 场景关联设备列表骨架
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: _SkeletonBox(height: 80, width: double.infinity, borderRadius: 20),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// 通用骨架屏占位组件
class _SkeletonBox extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const _SkeletonBox({
    required this.height,
    required this.width,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
