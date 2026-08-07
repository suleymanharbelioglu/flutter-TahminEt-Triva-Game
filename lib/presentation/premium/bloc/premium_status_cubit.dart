import 'package:ben_kimim/core/configs/revenuecat/revenuecat_config.dart';
import 'package:ben_kimim/domain/app_purchase/entity/purchase_entity.dart';
import 'package:ben_kimim/domain/app_purchase/repository/purchase_repository.dart';
import 'package:ben_kimim/domain/app_purchase/usecase/get_premium_status.dart';
import 'package:ben_kimim/presentation/premium/bloc/premium_status_state.dart';
import 'package:ben_kimim/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PremiumStatusCubit extends Cubit<PremiumStatusState> {
  PremiumStatusCubit() : super(PremiumLoading()) {
    checkPremiumStatus();
  }

  void Function(PurchaseEntity)? _listener;

  Future<void> checkPremiumStatus() async {
    if (isClosed) return;
    emit(PremiumLoading());
    if (!RevenueCatConfig.isConfigured) {
      emit(PremiumInactive());
      return;
    }

    final result = await sl<GetPremiumStatusUseCase>().call();

    if (isClosed) return;
    result.fold(
      (message) {
        if (kDebugMode) {
          debugPrint('PremiumStatusCubit.checkPremiumStatus failed: $message');
        }
        emit(PremiumStatusFailure(message));
      },
      (purchase) {
        _emitPurchase(purchase);
        _listenUpdates();
      },
    );
  }

  void _listenUpdates() {
    if (_listener != null) return;
    _listener = _emitPurchase;
    sl<PurchaseRepository>().addPremiumStatusListener(_listener!);
  }

  void _emitPurchase(PurchaseEntity purchase) {
    if (isClosed) return;
    if (purchase.isActive) {
      emit(PremiumActive(purchase));
    } else {
      emit(PremiumInactive());
    }
  }

  @override
  Future<void> close() {
    if (_listener != null) {
      sl<PurchaseRepository>().removePremiumStatusListener(_listener!);
      _listener = null;
    }
    return super.close();
  }
}
