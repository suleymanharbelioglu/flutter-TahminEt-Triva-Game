import 'package:ben_kimim/core/analytics/analytics_service.dart';
import 'package:ben_kimim/domain/app_purchase/entity/purchase_entity.dart';
import 'package:ben_kimim/domain/app_purchase/usecase/purchase_product.dart';
import 'package:ben_kimim/domain/app_purchase/usecase/restore_purchases.dart';
import 'package:ben_kimim/presentation/premium/bloc/purchase_state.dart';
import 'package:ben_kimim/presentation/premium/helper/friendly_purchase_errors.dart';
import 'package:ben_kimim/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PurchaseCubit extends Cubit<PurchaseState> {
  PurchaseCubit() : super(PurchaseInitial());

  String _baseId(String productId) {
    final beforeColon = productId.split(':').first;
    final dotParts = beforeColon.split('.');
    return dotParts.isNotEmpty ? dotParts.last : beforeColon;
  }

  Future<void> purchaseProduct(String productId) async {
    final baseProductId = _baseId(productId);
    if (isClosed) return;
    emit(PurchaseInProgress());
    sl<AnalyticsService>().logPurchaseStarted(productId: baseProductId);

    final result =
        await sl<PurchaseProductUseCase>().call(params: productId);

    if (isClosed) return;
    result.fold(
      (message) {
        sl<AnalyticsService>().logPurchaseFailed(
          productId: baseProductId,
          reason: message,
        );
        emit(
          PurchaseFailure(
            message: FriendlyPurchaseErrors.forPurchase(message),
          ),
        );
      },
      (PurchaseEntity purchase) {
        sl<AnalyticsService>().logPurchaseSuccess(productId: baseProductId);
        emit(PurchaseSuccess(purchase: purchase));
      },
    );
  }

  Future<void> restore() async {
    if (isClosed) return;
    emit(PurchaseInProgress());
    sl<AnalyticsService>().logRestoreStarted();

    final result = await sl<RestorePurchasesUseCase>().call();

    if (isClosed) return;
    result.fold(
      (message) {
        sl<AnalyticsService>().logRestoreFailed(reason: message);
        emit(
          PurchaseFailure(
            message: FriendlyPurchaseErrors.forPurchase(message),
          ),
        );
      },
      (PurchaseEntity purchase) {
        sl<AnalyticsService>().logRestoreSuccess(productId: purchase.productId);
        emit(PurchaseSuccess(purchase: purchase));
      },
    );
  }
}
