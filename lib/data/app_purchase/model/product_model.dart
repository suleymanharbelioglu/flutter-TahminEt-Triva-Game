import 'package:purchases_flutter/purchases_flutter.dart';

/// PRODUCT MODEL — data katmanı (StoreProduct mapping).
class ProductModel {
  final String productId;
  final String title;
  final String description;
  final String price;
  final double rawPrice;

  ProductModel({
    required this.productId,
    required this.title,
    required this.description,
    required this.price,
    required this.rawPrice,
  });

  factory ProductModel.fromStoreProduct(StoreProduct product) {
    return ProductModel(
      productId: product.identifier,
      title: product.title,
      description: product.description,
      price: product.priceString,
      rawPrice: product.price,
    );
  }
}
