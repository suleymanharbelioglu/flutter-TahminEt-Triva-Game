import 'package:purchases_flutter/purchases_flutter.dart';

/// PURCHASE MODEL
/// Kullanıcının satın aldığı ürünün bilgilerini tutar.
/// Bu modeli kendi domain katmanında kullanırsın.
/// UI veya repository içinde PurchaseDetails yerine bu model döner.

class PurchaseModel {
  /// Google Play ürün ID'si (örn: weekly_premium)
  final String productId;

  /// Satın alma başarılı mı?
  final bool isActive;

  /// Satın alma zamanı (milisaniye formatında gelir)
  final DateTime purchaseDate;

  /// Abonelik mi tek seferlik ürün mü?
  final bool isSubscription;

  PurchaseModel({
    required this.productId,
    required this.isActive,
    required this.purchaseDate,
    required this.isSubscription,
  });

  /// RevenueCat CustomerInfo → PurchaseModel dönüşümü (özet model).
  ///
  /// Not: RevenueCat’te doğrulama/aktiflik backend tarafından yönetilir.
  factory PurchaseModel.fromCustomerInfo(
    CustomerInfo info, {
    bool? isActiveOverride,
  }) {
    String baseId(String id) => id.split(':').first;

    // Öncelik: aktif entitlement'ın productIdentifier'ı.
    // Böylece uygulama aç-kapa sonrası yanlış plan fiyatı gösterme (örn. weekly yerine monthly) engellenir.
    const preferredEntitlementIds = <String>['VIP', 'premium'];
    String chosenBaseId = '';

    for (final entId in preferredEntitlementIds) {
      final ent = info.entitlements.active[entId];
      if (ent != null && ent.productIdentifier.isNotEmpty) {
        chosenBaseId = baseId(ent.productIdentifier);
        break;
      }
    }

    // Fallback: entitlement id eşleşmezse aktif aboneliklerden seç.
    if (chosenBaseId.isEmpty) {
      // RevenueCat `activeSubscriptions` sırası garanti değil.
      final activeBaseIds = info.activeSubscriptions.map(baseId).toSet();
      const priority = <String>[
        // Production product ids
        'yearly_premium',
        'monthly_premium',
        'weekly_premium',
        // Test Store product ids (RevenueCat test store)
        'yearly',
        'monthly',
        'weekly',
      ];
      chosenBaseId = priority.firstWhere(
        activeBaseIds.contains,
        orElse: () => activeBaseIds.isNotEmpty ? activeBaseIds.first : '',
      );
    }

    // RevenueCat purchaseDate bilgisi her platformda farklı alanlarda olabilir.
    // En güvenlisi: model oluşturulduğu anı kullanıp UI’yı beslemek.
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
