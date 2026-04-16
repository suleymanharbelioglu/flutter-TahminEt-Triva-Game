import 'dart:async';

import 'package:ben_kimim/data/app_purchase/model/purchase_model.dart';
import 'package:ben_kimim/presentation/premium/bloc/purchase_state.dart';
import 'package:ben_kimim/presentation/premium/helper/friendly_purchase_errors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseCubit extends Cubit<PurchaseState> {
  PurchaseCubit() : super(PurchaseInitial());

  /// iOS: `com.company.app.weekly_premium` → `weekly_premium`
  /// Android: `weekly_premium:weekly-plan` → `weekly_premium`
  String _baseId(String productId) {
    final beforeColon = productId.split(':').first;
    final dotParts = beforeColon.split('.');
    return dotParts.isNotEmpty ? dotParts.last : beforeColon;
  }

  /// RevenueCat ile satın alma.
  Future<void> purchaseProduct(String productId) async {
    emit(PurchaseInProgress());

    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;
      if (offering == null) {
        emit(
          PurchaseFailure(
            message:
                'Üyelik seçenekleri şu an kullanılamıyor. Lütfen daha sonra tekrar deneyin.',
          ),
        );
        return;
      }

      final base = _baseId(productId);
      Package? package;
      for (final p in offering.availablePackages) {
        if (_baseId(p.storeProduct.identifier) == base) {
          package = p;
          break;
        }
      }

      final CustomerInfo customerInfo;
      if (package != null) {
        customerInfo = await Purchases.purchasePackage(package);
      } else {
        // Offering'de paket yoksa (ör. Weekly eksik) doğrudan Store ürününden satın al.
        final storeId = productId.split(':').first;
        final products = await Purchases.getProducts([storeId]);
        if (products.isEmpty) {
          emit(
            PurchaseFailure(
              message: FriendlyPurchaseErrors.forPurchase(
                'product not found: $storeId',
              ),
            ),
          );
          return;
        }
        final storeProduct = products.firstWhere(
          (sp) => _baseId(sp.identifier) == base,
          orElse: () => products.first,
        );
        customerInfo = await Purchases.purchaseStoreProduct(storeProduct);
      }
      // Sonuç ekranında doğru planı göstermek için:
      // - RevenueCat aktif aboneliği bazen birden fazla döndürebilir
      // - PurchaseModel.fromCustomerInfo öncelik sırasına göre "seçilmiş" bir plan döndürür
      // Bu yüzden, satın alınan planı (base) açıkça yazıyoruz.
      final fromInfo = PurchaseModel.fromCustomerInfo(customerInfo);
      final model = PurchaseModel(
        productId: base,
        isActive: fromInfo.isActive,
        purchaseDate: DateTime.now(),
        isSubscription: true,
      );

      if (model.isActive) {
        emit(PurchaseSuccess(purchase: model));
      } else {
        emit(
          PurchaseFailure(
            message: FriendlyPurchaseErrors.forPurchase(
              'purchase completed but not active',
            ),
          ),
        );
      }
    } catch (e) {
      emit(PurchaseFailure(message: FriendlyPurchaseErrors.forPurchase(e)));
    }
  }

  Future<void> restore() async {
    emit(PurchaseInProgress());
    try {
      final info = await Purchases.restorePurchases();
      final model = PurchaseModel.fromCustomerInfo(info);
      if (model.isActive) {
        emit(PurchaseSuccess(purchase: model));
      } else {
        emit(
          PurchaseFailure(
            message: FriendlyPurchaseErrors.forPurchase(
              'no active plan',
            ),
          ),
        );
      }
    } catch (e) {
      emit(PurchaseFailure(message: FriendlyPurchaseErrors.forPurchase(e)));
    }
  }
}
