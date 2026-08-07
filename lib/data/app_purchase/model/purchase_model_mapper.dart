import 'package:ben_kimim/domain/app_purchase/entity/purchase_entity.dart';
import 'package:ben_kimim/data/app_purchase/model/purchase_model.dart';

extension PurchaseModelX on PurchaseModel {
  PurchaseEntity toEntity() => PurchaseEntity(
        productId: productId,
        isActive: isActive,
        purchaseDate: purchaseDate,
        isSubscription: isSubscription,
      );
}

extension PurchaseEntityX on PurchaseEntity {
  PurchaseModel toModel() => PurchaseModel(
        productId: productId,
        isActive: isActive,
        purchaseDate: purchaseDate,
        isSubscription: isSubscription,
      );
}
