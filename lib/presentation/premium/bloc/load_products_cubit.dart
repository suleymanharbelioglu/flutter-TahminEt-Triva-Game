import 'package:ben_kimim/domain/app_purchase/usecase/load_products.dart';
import 'package:ben_kimim/presentation/premium/bloc/load_products_state.dart';
import 'package:ben_kimim/presentation/premium/helper/friendly_purchase_errors.dart';
import 'package:ben_kimim/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadProductsCubit extends Cubit<LoadProductsState> {
  LoadProductsCubit() : super(LoadProductsInitial());

  static const _baseProductIds = <String>[
    'weekly_premium',
    'monthly_premium',
    'yearly_premium',
  ];

  Future<void> loadProducts() async {
    if (isClosed) return;
    emit(LoadProductsLoading());

    final result =
        await sl<LoadProductsUseCase>().call(params: _baseProductIds);

    if (isClosed) return;
    result.fold(
      (message) {
        if (kDebugMode) {
          debugPrint('LoadProductsCubit.loadProducts failed: $message');
        }
        emit(
          LoadProductsFailure(
            message: FriendlyPurchaseErrors.forLoadProducts(message),
          ),
        );
      },
      (products) => emit(LoadProductsSuccess(products: products)),
    );
  }
}
