import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/home_provider.dart';
import '../widgets/skeleton_card.dart';
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
          error: (error, stackTrace) => _buildErrorView(context, ref, error),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, WidgetRef ref, Object error) {
    return ListView(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ],
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
        const SizedBox(height: 48),
        const SkeletonCard(height: 40, width: 200),
        const SizedBox(height: 12),
        const SkeletonCard(height: 160),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: SkeletonCard(height: 120)),
            const SizedBox(width: 12),
            Expanded(child: SkeletonCard(height: 120)),
          ],
        ),
        const SizedBox(height: 24),
        const SkeletonCard(height: 180),
        const SizedBox(height: 24),
        const SkeletonCard(height: 200),
      ],
    );
  }
}
