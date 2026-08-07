class ProductEntity {
  final String productId;
  final String title;
  final String description;
  final String price;
  final double rawPrice;

  const ProductEntity({
    required this.productId,
    required this.title,
    required this.description,
    required this.price,
    required this.rawPrice,
  });
}
