import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth/auth_provider.dart';
import 'home_repository.dart';

// 提供 HomeRepository 实例
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  // 假定默认基地址，实际开发中可以从环境配置中获取
  return HomeRepository(baseUrl: 'http://127.0.0.1:8000/api');
});

// 管理首页聚合状态的数据流
// 使用 autoDispose 可以在页面销毁时释放，或根据需求保留
final homeSummaryProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  final authState = ref.watch(authProvider);
  
  return await repository.getHomeSummary(token: authState.token);
});
