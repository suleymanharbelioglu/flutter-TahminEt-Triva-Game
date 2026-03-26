import 'package:ben_kimim/data/app_purchase/model/product_model.dart';
import 'package:dartz/dartz.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class RevenueCatPurchaseService {
  Future<Either<String, List<ProductModel>>> loadProducts(
    List<String> productIds,
  );
}

class RevenueCatPurchaseServiceImpl implements RevenueCatPurchaseService {
  @override
  Future<Either<String, List<ProductModel>>> loadProducts(
    List<String> productIds,
  ) async {
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;

      if (offering == null) {
        return const Left('RevenueCat offering bulunamadı (current null).');
      }

      // RevenueCat "packages" içinden StoreProduct’ları alıp filtreliyoruz.
      final products = offering.availablePackages
          .map((p) => p.storeProduct)
          .where((p) => productIds.contains(p.identifier))
          .map(ProductModel.fromStoreProduct)
          .toList();

      // Bazı ürünler offering’de olmayabilir → UI tarafında hata gösterilsin
      final foundIds = products.map((e) => e.productId).toSet();
      final missing = productIds.where((id) => !foundIds.contains(id)).toList();
      if (missing.isNotEmpty) {
        return Left(
          'Bazı ürünler RevenueCat offering içinde yok: ${missing.join(', ')}',
        );
      }

      return Right(products);
    } catch (e) {
      return Left('RevenueCat ürünleri yüklenemedi: $e');
    }
  }
}

