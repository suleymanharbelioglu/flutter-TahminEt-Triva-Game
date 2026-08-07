import 'package:ben_kimim/core/usecase/usecase.dart';
import 'package:ben_kimim/domain/app_purchase/entity/product_entity.dart';
import 'package:ben_kimim/domain/app_purchase/repository/purchase_repository.dart';
import 'package:ben_kimim/service_locator.dart';
import 'package:dartz/dartz.dart';

class LoadProductsUseCase
    implements UseCase<Either<String, List<ProductEntity>>, List<String>> {
  @override
  Future<Either<String, List<ProductEntity>>> call({
    List<String>? params,
  }) async {
    return sl<PurchaseRepository>().loadProducts(params ?? const []);
  }
}
