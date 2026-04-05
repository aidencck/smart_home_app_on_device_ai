import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 模拟的全局状态 Provider，用于切换是否展示骨架屏
final sceneLoadingProvider = StateProvider<bool>((ref) => true);

class SceneScreen extends ConsumerWidget {
  const SceneScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(sceneLoadingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('场景空间', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Switch(
            value: isLoading,
            activeColor: Colors.black87,
            onChanged: (val) => ref.read(sceneLoadingProvider.notifier).state = val,
          )
        ],
      ),
      body: isLoading ? const _SceneListSkeleton() : const _SceneListContent(),
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
          height: 140,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
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

class _SceneListContent extends StatelessWidget {
  const _SceneListContent();

  @override
  Widget build(BuildContext context) {
    final scenes = [
      {'name': '坠入梦境', 'status': 'Active', 'icon': Icons.nights_stay, 'color': [const Color(0xFF2C3E50), const Color(0xFF3498DB)]},
      {'name': '晨起唤醒', 'status': 'Inactive', 'icon': Icons.wb_sunny, 'color': [Colors.white, Colors.white]},
      {'name': '专注模式', 'status': 'Inactive', 'icon': Icons.computer, 'color': [Colors.white, Colors.white]},
      {'name': '离家安防', 'status': 'Inactive', 'icon': Icons.security, 'color': [Colors.white, Colors.white]},
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: scenes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final scene = scenes[index];
        final isDark = index == 0;
        final gradientColors = scene['color'] as List<Color>;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SceneDetailScreen(sceneName: scene['name'] as String),
              ),
            );
          },
          child: Container(
            height: 140,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      scene['name'] as String,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Icon(
                      scene['icon'] as IconData,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  isDark ? '正在运行中...' : '点击进入详情',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black38,
                    fontSize: 14,
                  ),
                )
              ],
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text('$sceneName 详情', style: const TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: isLoading ? const _SceneDetailSkeleton() : const Center(child: Text('场景详细配置区域')),
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
          const _SkeletonBox(height: 200, width: double.infinity, borderRadius: 16),
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
                child: _SkeletonBox(height: 80, width: double.infinity, borderRadius: 12),
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
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
