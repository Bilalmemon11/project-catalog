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

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Product(
      id: doc.id,
      brand: (data['brand'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      upc: (data['upc'] ?? '').toString(),
      itemSize: (data['itemSize'] ?? '').toString(),
      strPack: data['strPack'],
      bsp: data['bsp'],
      srp: data['srp'],
      imageUrl: (data['imageUrl'] ?? '').toString(),
    );
  }
}
