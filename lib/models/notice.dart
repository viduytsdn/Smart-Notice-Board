class Notice {
  const Notice({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.deviceIds,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> deviceIds;
  final DateTime createdAt;

  Notice copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? deviceIds,
    DateTime? createdAt,
  }) {
    return Notice(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      deviceIds: deviceIds ?? this.deviceIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
