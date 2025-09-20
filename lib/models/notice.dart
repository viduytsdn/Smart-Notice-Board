import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  Notice({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.deviceIds,
    this.createdAt,
  });

  factory Notice.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Notice(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      deviceIds: List<String>.from(data['deviceIds'] as List<dynamic>? ?? []),
      createdAt: data['timestamp'] as Timestamp?,
    );
  }

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> deviceIds;
  final Timestamp? createdAt;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'deviceIds': deviceIds,
      'timestamp': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}
