import 'package:cloud_firestore/cloud_firestore.dart';

class DisplayItem {
  const DisplayItem({
    required this.id,
    required this.displayName,
    required this.description,
    required this.images,
    required this.order,
    required this.isActive,
  });

  final String id;
  final String displayName;
  final String description;
  final List<String> images;
  final int order;
  final bool isActive;

  factory DisplayItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final imagesRaw = (data['images'] as List?) ?? const [];
    return DisplayItem(
      id: doc.id,
      displayName: (data['displayName'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      images: imagesRaw.map((e) => e.toString()).toList(),
      order: (data['order'] is num) ? (data['order'] as num).toInt() : 0,
      isActive: data['isActive'] == true,
    );
  }
}
