import 'package:ben_kimim/data/app_purchase/model/product_model_mapper.dart';
import 'package:ben_kimim/data/app_purchase/model/purchase_model.dart';
import 'package:ben_kimim/data/app_purchase/model/purchase_model_mapper.dart';
import 'package:ben_kimim/data/app_purchase/source/revenuecat_purchase_service.dart';
import 'package:ben_kimim/domain/app_purchase/entity/product_entity.dart';
import 'package:ben_kimim/domain/app_purchase/entity/purchase_entity.dart';
import 'package:ben_kimim/domain/app_purchase/repository/purchase_repository.dart';
import 'package:ben_kimim/service_locator.dart';
import 'package:dartz/dartz.dart';

class PurchaseRepoImpl implements PurchaseRepository {
  RevenueCatPurchaseService get _source => sl<RevenueCatPurchaseService>();

  final Map<
      void Function(PurchaseEntity),
      void Function(PurchaseModel)> _listenerBridges = {};

  @override
  Future<Either<String, List<ProductEntity>>> loadProducts(
    List<String> productIds,
  ) async {
    final result = await _source.loadProducts(productIds);
    return result.map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<Either<String, PurchaseEntity>> purchaseProduct(
    String productId,
  ) async {
    final result = await _source.purchaseProduct(productId);
    return result.map((m) => m.toEntity());
  }

  @override
  Future<Either<String, PurchaseEntity>> restorePurchases() async {
    final result = await _source.restorePurchases();
    return result.map((m) => m.toEntity());
  }

  @override
  Future<Either<String, PurchaseEntity>> getPremiumStatus() async {
    final result = await _source.getPremiumStatus();
    return result.map((m) => m.toEntity());
  }

  @override
  void addPremiumStatusListener(
    void Function(PurchaseEntity purchase) onUpdate,
  ) {
    if (_listenerBridges.containsKey(onUpdate)) return;
    void bridge(PurchaseModel model) => onUpdate(model.toEntity());
    _listenerBridges[onUpdate] = bridge;
    _source.addCustomerInfoListener(bridge);
  }

  @override
  void removePremiumStatusListener(
    void Function(PurchaseEntity purchase) onUpdate,
  ) {
    final bridge = _listenerBridges.remove(onUpdate);
    if (bridge != null) {
      _source.removeCustomerInfoListener(bridge);
    }
  }
}
