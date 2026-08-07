import 'package:ben_kimim/data/app_purchase/model/product_model.dart';
import 'package:ben_kimim/data/app_purchase/model/purchase_model.dart';
import 'package:dartz/dartz.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class RevenueCatPurchaseService {
  Future<Either<String, List<ProductModel>>> loadProducts(
    List<String> productIds,
  );

  Future<Either<String, PurchaseModel>> purchaseProduct(String productId);

  Future<Either<String, PurchaseModel>> restorePurchases();

  Future<Either<String, PurchaseModel>> getPremiumStatus();

  void addCustomerInfoListener(void Function(PurchaseModel purchase) onUpdate);

  void removeCustomerInfoListener(
    void Function(PurchaseModel purchase) onUpdate,
  );
}

class RevenueCatPurchaseServiceImpl implements RevenueCatPurchaseService {
  static const _preferredEntitlementIds = {'VIP', 'premium'};

  final Map<void Function(PurchaseModel), void Function(CustomerInfo)>
      _listenerMap = {};

  /// iOS: `com.company.app.weekly_premium` → `weekly_premium`
  /// Android: `weekly_premium:weekly-plan` → `weekly_premium`
  String _baseId(String productId) {
    final beforeColon = productId.split(':').first;
    final dotParts = beforeColon.split('.');
    return dotParts.isNotEmpty ? dotParts.last : beforeColon;
  }

  Future<List<ProductModel>> _loadViaProductsFallback(
    Set<String> baseProductIds,
  ) async {
    final storeProducts = await Purchases.getProducts(baseProductIds.toList());
    final byBaseId = <String, ProductModel>{};
    for (final sp in storeProducts) {
      final base = _baseId(sp.identifier);
      if (baseProductIds.contains(base)) {
        byBaseId.putIfAbsent(base, () => ProductModel.fromStoreProduct(sp));
      }
    }

    final missing = baseProductIds.where((id) => !byBaseId.containsKey(id));
    if (missing.isNotEmpty) {
      throw StateError(
        'Store ürünleri içinde eksik ürün var: ${missing.join(', ')}',
      );
    }
    return byBaseId.values.toList();
  }

  @override
  Future<Either<String, List<ProductModel>>> loadProducts(
    List<String> productIds,
  ) async {
    if (productIds.isEmpty) return const Right([]);

    final baseProductIds = productIds.map(_baseId).toSet();

    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;

      if (offering == null) {
        final products = await _loadViaProductsFallback(baseProductIds);
        return Right(products);
      }

      final byBaseId = <String, ProductModel>{};
      for (final p in offering.availablePackages.map((p) => p.storeProduct)) {
        final base = _baseId(p.identifier);
        if (baseProductIds.contains(base)) {
          byBaseId.putIfAbsent(base, () => ProductModel.fromStoreProduct(p));
        }
      }

      final missing = baseProductIds.where((id) => !byBaseId.containsKey(id));
      if (missing.isNotEmpty) {
        final products = await _loadViaProductsFallback(baseProductIds);
        return Right(products);
      }

      return Right(byBaseId.values.toList());
    } catch (e) {
      return Left('RevenueCat ürünleri yüklenemedi: $e');
    }
  }

  @override
  Future<Either<String, PurchaseModel>> purchaseProduct(
    String productId,
  ) async {
    final baseProductId = _baseId(productId);

    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;
      if (offering == null) {
        return const Left(
          'Üyelik seçenekleri şu an kullanılamıyor. Lütfen daha sonra tekrar deneyin.',
        );
      }

      Package? package;
      for (final p in offering.availablePackages) {
        if (_baseId(p.storeProduct.identifier) == baseProductId) {
          package = p;
          break;
        }
      }

      final CustomerInfo customerInfo;
      if (package != null) {
        final result = await Purchases.purchase(
          PurchaseParams.package(package),
        );
        customerInfo = result.customerInfo;
      } else {
        final storeId = productId.split(':').first;
        final products = await Purchases.getProducts([storeId]);
        if (products.isEmpty) {
          return Left('product not found: $storeId');
        }
        final storeProduct = products.firstWhere(
          (sp) => _baseId(sp.identifier) == baseProductId,
          orElse: () => products.first,
        );
        final result = await Purchases.purchase(
          PurchaseParams.storeProduct(storeProduct),
        );
        customerInfo = result.customerInfo;
      }

      final fromInfo = PurchaseModel.fromCustomerInfo(customerInfo);
      final model = PurchaseModel(
        productId: baseProductId,
        isActive: fromInfo.isActive,
        purchaseDate: DateTime.now(),
        isSubscription: true,
      );

      if (!model.isActive) {
        return const Left('purchase completed but not active');
      }
      return Right(model);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, PurchaseModel>> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      final model = PurchaseModel.fromCustomerInfo(info);
      if (!model.isActive) {
        return const Left('no active plan');
      }
      return Right(model);
    } catch (e) {
      return Left(e.toString());
    }
  }

  PurchaseModel _statusFromCustomerInfo(CustomerInfo info) {
    final hasActiveEntitlement = _preferredEntitlementIds.any(
      (id) => info.entitlements.active.containsKey(id),
    );
    final fallbackHasAnyEntitlement = info.entitlements.active.isNotEmpty;
    final isActive = hasActiveEntitlement || fallbackHasAnyEntitlement;
    return PurchaseModel.fromCustomerInfo(
      info,
      isActiveOverride: isActive,
    );
  }

  @override
  Future<Either<String, PurchaseModel>> getPremiumStatus() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return Right(_statusFromCustomerInfo(info));
    } catch (e) {
      return Left(
        'Üyelik durumu şu an doğrulanamadı. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.',
      );
    }
  }

  @override
  void addCustomerInfoListener(
    void Function(PurchaseModel purchase) onUpdate,
  ) {
    if (_listenerMap.containsKey(onUpdate)) return;
    void listener(CustomerInfo info) => onUpdate(_statusFromCustomerInfo(info));
    _listenerMap[onUpdate] = listener;
    Purchases.addCustomerInfoUpdateListener(listener);
  }

  @override
  void removeCustomerInfoListener(
    void Function(PurchaseModel purchase) onUpdate,
  ) {
    final listener = _listenerMap.remove(onUpdate);
    if (listener != null) {
      Purchases.removeCustomerInfoUpdateListener(listener);
    }
  }
}
