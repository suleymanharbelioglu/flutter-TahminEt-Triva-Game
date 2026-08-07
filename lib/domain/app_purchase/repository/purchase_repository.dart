import 'package:ben_kimim/domain/app_purchase/entity/product_entity.dart';
import 'package:ben_kimim/domain/app_purchase/entity/purchase_entity.dart';
import 'package:dartz/dartz.dart';

abstract class PurchaseRepository {
  Future<Either<String, List<ProductEntity>>> loadProducts(
    List<String> productIds,
  );

  Future<Either<String, PurchaseEntity>> purchaseProduct(String productId);

  Future<Either<String, PurchaseEntity>> restorePurchases();

  Future<Either<String, PurchaseEntity>> getPremiumStatus();

  /// RevenueCat customer info güncellemelerini dinler.
  void addPremiumStatusListener(void Function(PurchaseEntity purchase) onUpdate);

  void removePremiumStatusListener(
    void Function(PurchaseEntity purchase) onUpdate,
  );
}
