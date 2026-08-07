import 'package:ben_kimim/domain/app_purchase/entity/product_entity.dart';
import 'package:ben_kimim/data/app_purchase/model/product_model.dart';

extension ProductModelX on ProductModel {
  ProductEntity toEntity() => ProductEntity(
        productId: productId,
        title: title,
        description: description,
        price: price,
        rawPrice: rawPrice,
      );
}

extension ProductEntityX on ProductEntity {
  ProductModel toModel() => ProductModel(
        productId: productId,
        title: title,
        description: description,
        price: price,
        rawPrice: rawPrice,
      );
}
