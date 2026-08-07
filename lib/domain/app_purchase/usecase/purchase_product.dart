import 'package:ben_kimim/core/usecase/usecase.dart';
import 'package:ben_kimim/domain/app_purchase/entity/purchase_entity.dart';
import 'package:ben_kimim/domain/app_purchase/repository/purchase_repository.dart';
import 'package:ben_kimim/service_locator.dart';
import 'package:dartz/dartz.dart';

class PurchaseProductUseCase
    implements UseCase<Either<String, PurchaseEntity>, String> {
  @override
  Future<Either<String, PurchaseEntity>> call({String? params}) async {
    return sl<PurchaseRepository>().purchaseProduct(params!);
  }
}
