import 'package:ben_kimim/domain/app_purchase/entity/purchase_entity.dart';

abstract class PremiumStatusState {}

class PremiumInitial extends PremiumStatusState {}

class PremiumLoading extends PremiumStatusState {}

class PremiumInactive extends PremiumStatusState {}

class PremiumActive extends PremiumStatusState {
  final PurchaseEntity purchase;

  PremiumActive(this.purchase);
}

class PremiumStatusFailure extends PremiumStatusState {
  final String message;
  PremiumStatusFailure(this.message);
}
