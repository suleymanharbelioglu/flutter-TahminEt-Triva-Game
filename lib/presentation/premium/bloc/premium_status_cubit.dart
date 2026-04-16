import 'package:ben_kimim/data/app_purchase/model/purchase_model.dart';
import 'package:ben_kimim/core/configs/revenuecat/revenuecat_config.dart';
import 'package:ben_kimim/presentation/premium/bloc/premium_status_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PremiumStatusCubit extends Cubit<PremiumStatusState> {
  PremiumStatusCubit() : super(PremiumLoading()) {
    checkPremiumStatus();
  }

  static const _preferredEntitlementIds = {'VIP', 'premium'};

  void Function(CustomerInfo)? _listener;

  Future<void> checkPremiumStatus() async {
    emit(PremiumLoading());
    if (!RevenueCatConfig.isConfigured) {
      emit(PremiumInactive());
      return;
    }
    try {
      final info = await Purchases.getCustomerInfo();
      _emitFromCustomerInfo(info);
      _listenCustomerInfo();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PremiumStatusCubit.checkPremiumStatus failed: $e');
      }
      emit(
        PremiumStatusFailure(
          'Üyelik durumu şu an doğrulanamadı. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.',
        ),
      );
    }
  }

  void _listenCustomerInfo() {
    if (_listener != null) return;
    _listener = (info) => _emitFromCustomerInfo(info);
    Purchases.addCustomerInfoUpdateListener(_listener!);
  }

  void _emitFromCustomerInfo(CustomerInfo info) {
    final hasActiveEntitlement = _preferredEntitlementIds.any(
      (id) => info.entitlements.active.containsKey(id),
    );
    final fallbackHasAnyEntitlement = info.entitlements.active.isNotEmpty;
    final isActive = hasActiveEntitlement || fallbackHasAnyEntitlement;

    final model = PurchaseModel.fromCustomerInfo(
      info,
      isActiveOverride: isActive,
    );
    if (model.isActive) {
      emit(PremiumActive(model));
    } else {
      emit(PremiumInactive());
    }
  }

  @override
  Future<void> close() {
    if (_listener != null) {
      Purchases.removeCustomerInfoUpdateListener(_listener!);
      _listener = null;
    }
    return super.close();
  }
}
