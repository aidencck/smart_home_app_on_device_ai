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

    final response = await _client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => AiRecommendation.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load recommendations: ${response.statusCode} - ${response.body}',
      );
    }
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
