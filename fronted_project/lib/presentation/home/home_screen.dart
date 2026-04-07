import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/home_provider.dart';
import '../pages/home_page.dart'; // 引入真实的漂亮 UI 页面

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeSummaryAsync = ref.watch(homeSummaryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF14142B), // Match Scaffold background
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homeSummaryProvider);
          try {
            await ref.read(homeSummaryProvider.future);
          } catch (_) {}
        },
        child: homeSummaryAsync.when(
          data: (data) => HomePage(homeData: data), // Pass data
          loading: () => const _HomeSkeleton(),
          error: (error, stackTrace) => ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text('加载失败', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(error.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(homeSummaryProvider),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        // 1. 顶部问候与环境概览骨架
        const _SkeletonBox(height: 40, width: 200, borderRadius: 8),
        const SizedBox(height: 8),
        const _SkeletonBox(height: 20, width: 120, borderRadius: 4),
        const SizedBox(height: 24),

        // 2. 环境概览骨架 (温湿度、空气质量等)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            3,
            (index) => const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: _SkeletonBox(height: 80, width: double.infinity, borderRadius: 16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 3. 生理状态环骨架 (睡眠、心率等)
        const Center(
          child: _SkeletonBox(height: 180, width: 180, borderRadius: 90),
        ),
        const SizedBox(height: 24),

        // 4. 快捷控制骨架 (灯光、窗帘等)
        const _SkeletonBox(height: 24, width: 100, borderRadius: 4),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: 4,
          itemBuilder: (_, __) => const _SkeletonBox(height: 60, width: double.infinity, borderRadius: 12),
        ),
        const SizedBox(height: 24),

        // 5. 当前运行场景 (Active Scenes)
        const _SkeletonBox(height: 24, width: 120, borderRadius: 4),
        const SizedBox(height: 12),
        const _SkeletonBox(height: 100, width: double.infinity, borderRadius: 16),
        const SizedBox(height: 24),

        // 6. 设备状态网格骨架
        const _SkeletonBox(height: 24, width: 100, borderRadius: 4),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: 4,
          itemBuilder: (_, __) => const _SkeletonBox(height: double.infinity, width: double.infinity, borderRadius: 12),
        ),
        const SizedBox(height: 24),

        // 7. 近期活动与异常警报骨架 (Recent Activities / Alerts)
        const _SkeletonBox(height: 24, width: 150, borderRadius: 4),
        const SizedBox(height: 12),
        const _SkeletonBox(height: 80, width: double.infinity, borderRadius: 16),
        const SizedBox(height: 40), // 底部留白
      ],
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
