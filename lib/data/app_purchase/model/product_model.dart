import 'package:purchases_flutter/purchases_flutter.dart';

/// PRODUCT MODEL
/// Google Play’den gelen ürün listesini UI’da göstermek için kullanırsın.
/// Örn: Aylık, Haftalık, Yıllık planların fiyat ve açıklama bilgileri.

class ProductModel {
  /// Google Play ürün ID'si (örn: weekly_premium)
  final String productId;

  /// Ürünün görünen adı (ör: "Haftalık Üyelik")
  final String title;

  /// Ürünün açıklaması (ör: "7 gün premium erişim")
  final String description;

  /// Formatlı fiyat (ör: ₺19,99)
  final String price;

  /// Ham fiyat (ör: 19.99)
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
