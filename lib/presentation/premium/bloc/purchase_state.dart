import 'package:ben_kimim/domain/app_purchase/entity/purchase_entity.dart';

abstract class PurchaseState {}

class PurchaseInitial extends PurchaseState {}

class PurchaseInProgress extends PurchaseState {}

class PurchaseSuccess extends PurchaseState {
  final PurchaseEntity purchase;
  PurchaseSuccess({required this.purchase});
}

class PurchaseFailure extends PurchaseState {
  final String message;
  PurchaseFailure({required this.message});
}
