import 'package:ben_kimim/domain/app_purchase/entity/product_entity.dart';

abstract class LoadProductsState {}

class LoadProductsInitial extends LoadProductsState {}

class LoadProductsLoading extends LoadProductsState {}

class LoadProductsSuccess extends LoadProductsState {
  final List<ProductEntity> products;

  LoadProductsSuccess({required this.products});
}

class LoadProductsFailure extends LoadProductsState {
  final String message;

  LoadProductsFailure({required this.message});
}
