class PurchaseEntity {
  final String productId;
  final bool isActive;
  final DateTime purchaseDate;
  final bool isSubscription;

  const PurchaseEntity({
    required this.productId,
    required this.isActive,
    required this.purchaseDate,
    required this.isSubscription,
  });
}
