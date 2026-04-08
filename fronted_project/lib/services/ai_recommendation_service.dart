import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_recommendation.dart';

class AiRecommendationService {
  final String baseUrl;
  final http.Client _client;

  AiRecommendationService({
    this.baseUrl = 'http://127.0.0.1:8000/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<List<AiRecommendation>> getRecommendations(String token) async {
    final uri = Uri.parse('$baseUrl/v1/ai/recommendations');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client.get(uri, headers: headers).timeout(
        const Duration(seconds: 3),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => AiRecommendation.fromJson(json)).toList();
      } else {
        // Log error but fallback to mock
        return _getMockRecommendations();
      }
    } catch (e) {
      // Fallback to mock on network error
      return _getMockRecommendations();
    }
  }

  List<AiRecommendation> _getMockRecommendations() {
    return [
      AiRecommendation(
        id: 'rec_001',
        userId: 'user_1',
        title: '开启「坠入梦境」助眠场景',
        description: '检测到您当前心率逐渐平稳，建议开启助眠环境：灯光调至琥珀色，床体升至 15° 零重力位。',
        status: 'pending',
        actionPayload: {'type': 'scene', 'action': 'activate_sleep_prep'},
      ),
      AiRecommendation(
        id: 'rec_002',
        userId: 'user_1',
        title: '优化主卧空调温度',
        description: '根据您的睡眠习惯，当前室温 24°C 略高，建议调至 26°C 以获得更深度的睡眠。',
        status: 'pending',
        actionPayload: {'type': 'device', 'action': 'set_ac_26'},
      ),
    ];
  }

  Future<void> acceptRecommendation(
    String recommendationId,
    String token,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/v1/ai/recommendations/$recommendationId/accept',
    );
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await _client.post(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to accept recommendation: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> rejectRecommendation(
    String recommendationId,
    String token,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/v1/ai/recommendations/$recommendationId/reject',
    );
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await _client.post(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to reject recommendation: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
