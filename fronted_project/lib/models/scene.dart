class SmartScene {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isActive;
  final bool isPreset;

  SmartScene({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isActive = false,
    this.isPreset = false,
  });

  SmartScene copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    bool? isActive,
    bool? isPreset,
  }) {
    return SmartScene(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      isPreset: isPreset ?? this.isPreset,
    );
  }
}
