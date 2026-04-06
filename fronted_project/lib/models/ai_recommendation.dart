class AiRecommendation {
  final String id;
  final String userId;
  final String description;
  final String status;
  final Map<String, dynamic> actionPayload;

  AiRecommendation({
    required this.id,
    required this.userId,
    required this.description,
    required this.status,
    required this.actionPayload,
  });

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    return AiRecommendation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      actionPayload: json['action_payload'] as Map<String, dynamic>? ?? {},
    );
  }
}
