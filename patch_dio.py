content = """import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/auth_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com/v1', // Replace with real API
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Logging Interceptor (脱敏处理，仅在Debug模式下完整输出)
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestHeader: false, // 隐藏包含 Token 的 Header
      requestBody: true,
      responseBody: true,
    ));
  }

  // Auth Interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await ref.read(authRepositoryProvider).getToken();
      options.headers['Accept-Language'] = PlatformDispatcher.instance.locale.languageCode;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (DioException err, handler) async {
      if (err.response?.statusCode == 401) {
        // Here you would implement silent token refresh logic
        // For now, we just logout
        ref.read(authStateProvider.notifier).logout();
      }
      return handler.next(err);
    },
  ));

  // Smart Retry Interceptor for weak networks
  dio.interceptors.add(RetryInterceptor(
    dio: dio,
    logPrint: (String message) { if (kDebugMode) { print(message); } }, // 生产环境不输出重试日志
    retries: 3,
    retryDelays: const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
  ));

  return dio;
});
"""

with open("/Users/aiden/Projects/macinit/smarthome APP/smart_home_app/lib/core/network/dio_client.dart", "w") as f:
    f.write(content)
