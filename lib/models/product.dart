import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  const Product({
    required this.id,
    required this.brand,
    required this.description,
    required this.upc,
    required this.itemSize,
    required this.strPack,
    required this.bsp,
    required this.srp,
    required this.imageUrl,
    required this.imageUrls,
    required this.imageKey,
  });

  final String id;
  final String brand;
  final String description;
  final String upc;
  final String itemSize;
  final dynamic strPack;
  final dynamic bsp;
  final dynamic srp;
  final String imageUrl;
  final List<String> imageUrls;
  final String imageKey;

  String get primaryImageUrl {
    if (imageUrls.isNotEmpty) return imageUrls.first;
    return imageUrl;
  }

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final imageUrlsRaw = (data['imageUrls'] as List?) ?? const [];
    final imageUrls = imageUrlsRaw
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toList();
    final legacyImageUrl = (data['imageUrl'] ?? '').toString();
    if (legacyImageUrl.isNotEmpty && !imageUrls.contains(legacyImageUrl)) {
      imageUrls.insert(0, legacyImageUrl);
    }

    return Product(
      id: doc.id,
      brand: (data['brand'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      upc: (data['upc'] ?? '').toString(),
      itemSize: (data['itemSize'] ?? '').toString(),
      strPack: data['strPack'],
      bsp: data['bsp'],
      srp: data['srp'],
      imageUrl: legacyImageUrl,
      imageUrls: imageUrls,
      imageKey: (data['imageKey'] ?? '').toString(),
    );
  }
}
