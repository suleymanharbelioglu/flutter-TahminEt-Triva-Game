import 'package:ben_kimim/data/app_purchase/model/product_model.dart';
import 'package:ben_kimim/presentation/premium/bloc/load_products_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class LoadProductsCubit extends Cubit<LoadProductsState> {
  LoadProductsCubit() : super(LoadProductsInitial());
  static const _baseProductIds = <String>{
    'weekly_premium',
    'monthly_premium',
    'yearly_premium',
  };

  String _baseId(String productId) => productId.split(':').first;

  /// Ürün ID listesi vererek ürünleri yükle
  Future<void> loadProducts() async {
    emit(LoadProductsLoading()); // Önce loading state

    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;

      if (offering == null) {
        emit(
          LoadProductsFailure(
            message: 'RevenueCat offering bulunamadı (current null).',
          ),
        );
        return;
      }

      final byBaseId = <String, ProductModel>{};
      for (final p in offering.availablePackages.map((p) => p.storeProduct)) {
        final base = _baseId(p.identifier);
        if (_baseProductIds.contains(base)) {
          byBaseId.putIfAbsent(base, () => ProductModel.fromStoreProduct(p));
        }
      }

      final products = byBaseId.values.toList();

      final missing = _baseProductIds.where((id) => !byBaseId.containsKey(id));
      if (missing.isNotEmpty) {
        emit(
          LoadProductsFailure(
            message:
                'Bazı ürünler RevenueCat offering içinde yok: ${missing.join(', ')}',
          ),
        );
        return;
      }

      emit(LoadProductsSuccess(products: products));
    } catch (e) {
      emit(LoadProductsFailure(message: 'Ürünler yüklenemedi: $e'));
    }
  }
}
