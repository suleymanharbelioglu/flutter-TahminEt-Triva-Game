import 'dart:async';

import 'package:ben_kimim/data/app_purchase/model/purchase_model.dart';
import 'package:ben_kimim/presentation/premium/bloc/purchase_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseCubit extends Cubit<PurchaseState> {
  PurchaseCubit() : super(PurchaseInitial());

  String _baseId(String productId) => productId.split(':').first;

  /// RevenueCat ile satın alma.
  Future<void> purchaseProduct(String productId) async {
    emit(PurchaseInProgress());

    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;
      if (offering == null) {
        emit(PurchaseFailure(message: 'RevenueCat offering bulunamadı.'));
        return;
      }

      final package = offering.availablePackages.firstWhere(
        (p) => _baseId(p.storeProduct.identifier) == _baseId(productId),
        orElse: () => throw StateError('Package not found for $productId'),
      );

      final customerInfo = await Purchases.purchasePackage(package);
      final model = PurchaseModel.fromCustomerInfo(customerInfo);

      if (model.isActive) {
        emit(PurchaseSuccess(purchase: model));
      } else {
        emit(PurchaseFailure(message: 'Purchase completed but not active.'));
      }
    } catch (e) {
      emit(PurchaseFailure(message: 'Error purchasing product: $e'));
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
        emit(PurchaseFailure(message: 'Restore completed but no active plan.'));
      }
    } catch (e) {
      emit(PurchaseFailure(message: 'Error restoring purchases: $e'));
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
