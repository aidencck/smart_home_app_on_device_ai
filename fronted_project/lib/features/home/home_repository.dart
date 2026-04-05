import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeRepository {
  final String baseUrl;
  final http.Client _client;

  HomeRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> getHomeSummary({String? token}) async {
    final uri = Uri.parse('$baseUrl/v1/home/summary');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('获取首页数据失败: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('网络请求发生错误: $e');
    }
  }
}
