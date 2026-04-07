class SmartAutomation {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isEnabled;
  final bool isRecommended;
  final String? lastRun;
  final String? error;

  SmartAutomation({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isEnabled = false,
    this.isRecommended = false,
    this.lastRun,
    this.error,
  });

  SmartAutomation copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    bool? isEnabled,
    bool? isRecommended,
    String? lastRun,
    String? error,
  }) {
    return SmartAutomation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isEnabled: isEnabled ?? this.isEnabled,
      isRecommended: isRecommended ?? this.isRecommended,
      lastRun: lastRun ?? this.lastRun,
      error: error ?? this.error,
    );
  }
}
