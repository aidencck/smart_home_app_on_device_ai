import 'dart:convert';
import 'package:http/http.dart' as http;

class DeviceApiClient {
  final String baseUrl;
  final http.Client _client;

  DeviceApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// 绑定新设备
  /// 调用 POST /v1/devices/bind（传入 device_id 或 mac_address）
  Future<Map<String, dynamic>> bindDevice({
    String? deviceId,
    String? macAddress,
    String? token,
  }) async {
    assert(deviceId != null || macAddress != null, '必须提供 deviceId 或 macAddress 之一');

    final uri = Uri.parse('$baseUrl/v1/devices/bind');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      if (deviceId != null) 'device_id': deviceId,
      if (macAddress != null) 'mac_address': macAddress,
    });

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 绑定成功，返回解析后的数据
        return jsonDecode(response.body);
      } else {
        // 处理错误响应
        throw Exception('绑定设备失败: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('网络请求发生错误: $e');
    }
  }
}
