import 'package:purchases_flutter/purchases_flutter.dart';

/// PURCHASE MODEL — data katmanı (CustomerInfo mapping).
class PurchaseModel {
  final String productId;
  final bool isActive;
  final DateTime purchaseDate;
  final bool isSubscription;

  PurchaseModel({
    required this.productId,
    required this.isActive,
    required this.purchaseDate,
    required this.isSubscription,
  });

  factory PurchaseModel.fromCustomerInfo(
    CustomerInfo info, {
    bool? isActiveOverride,
  }) {
    String baseId(String id) => id.split(':').first;

    const preferredEntitlementIds = <String>['VIP', 'premium'];
    String chosenBaseId = '';

    for (final entId in preferredEntitlementIds) {
      final ent = info.entitlements.active[entId];
      if (ent != null && ent.productIdentifier.isNotEmpty) {
        chosenBaseId = baseId(ent.productIdentifier);
        break;
      }
    }

    if (chosenBaseId.isEmpty) {
      final activeBaseIds = info.activeSubscriptions.map(baseId).toSet();
      const priority = <String>[
        'yearly_premium',
        'monthly_premium',
        'weekly_premium',
        'yearly',
        'monthly',
        'weekly',
      ];
      chosenBaseId = priority.firstWhere(
        activeBaseIds.contains,
        orElse: () => activeBaseIds.isNotEmpty ? activeBaseIds.first : '',
      );
    }

    final isActive = isActiveOverride ??
        info.entitlements.active.isNotEmpty ||
            info.activeSubscriptions.isNotEmpty;
    return PurchaseModel(
      productId: isActive ? chosenBaseId : '',
      isActive: isActive,
      purchaseDate: DateTime.now(),
      isSubscription: true,
    );
  }
}
