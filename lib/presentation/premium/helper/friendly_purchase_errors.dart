import 'dart:io' show Platform;

class FriendlyPurchaseErrors {
  static String forLoadProducts(Object error) {
    final s = error.toString();
    final lower = s.toLowerCase();

    // RevenueCat / store config issues
    if (lower.contains('configuration_error') ||
        lower.contains('there is an issue with your configuration') ||
        lower.contains('why-are-offerings-empty')) {
      if (Platform.isIOS) {
        return 'Üyelik seçenekleri şu an kullanılamıyor. App Store tarafında ürünler henüz onaylanmamış olabilir. Lütfen daha sonra tekrar deneyin.';
      }
      return 'Üyelik seçenekleri şu an kullanılamıyor. Google Play tarafında ürünler henüz aktif olmayabilir. Lütfen daha sonra tekrar deneyin.';
    }

    // Network
    if (lower.contains('network') ||
        lower.contains('socketexception') ||
        lower.contains('timed out') ||
        lower.contains('timeout')) {
      return 'Üyelik seçenekleri yüklenemedi. İnternet bağlantınızı kontrol edip tekrar deneyin.';
    }

    // Store not reachable / billing unavailable
    if (lower.contains('store_problem') ||
        lower.contains('storekit') ||
        lower.contains('billing') ||
        lower.contains('billing_unavailable') ||
        lower.contains('service unavailable')) {
      return 'Mağaza ile bağlantı kurulamadı. Lütfen biraz sonra tekrar deneyin.';
    }

    return 'Üyelik seçenekleri şu an yüklenemedi. Lütfen tekrar deneyin.';
  }

  static String forPurchase(Object errorOrMessage) {
    final s = errorOrMessage.toString();
    final lower = s.toLowerCase();

    if (lower.contains('purchase_cancelled') ||
        lower.contains('user_cancelled') ||
        lower.contains('cancelled')) {
      return 'Satın alma işlemi iptal edildi.';
    }

    if (lower.contains('configuration_error') ||
        lower.contains('there is an issue with your configuration')) {
      if (Platform.isIOS) {
        return 'Satın alma şu an kullanılamıyor. App Store tarafında ürünler henüz onaylanmamış olabilir.';
      }
      return 'Satın alma şu an kullanılamıyor. Google Play tarafında ürünler henüz aktif olmayabilir.';
    }

    if (lower.contains('product') && lower.contains('not found') ||
        lower.contains('item unavailable') ||
        lower.contains('product_not_available')) {
      return 'Seçilen üyelik şu an mağazada bulunamadı. Lütfen daha sonra tekrar deneyin.';
    }

    if (lower.contains('network') ||
        lower.contains('socketexception') ||
        lower.contains('timed out') ||
        lower.contains('timeout')) {
      return 'Satın alma tamamlanamadı. İnternet bağlantınızı kontrol edip tekrar deneyin.';
    }

    if (lower.contains('billing_unavailable') ||
        lower.contains('billing') ||
        lower.contains('store_problem') ||
        lower.contains('storekit')) {
      return 'Mağaza şu an kullanılamıyor. Lütfen daha sonra tekrar deneyin.';
    }

    if (lower.contains('purchase completed but not active') ||
        lower.contains('not active')) {
      return 'Satın alma alındı, üyelik henüz aktif değil. Biraz sonra tekrar deneyin.';
    }

    if (lower.contains('no active plan') ||
        lower.contains('no active') && lower.contains('plan')) {
      return 'Aktif abonelik bulunamadı. Doğru mağaza hesabıyla tekrar deneyin.';
    }

    return 'İşlem tamamlanamadı. Lütfen tekrar deneyin.';
  }
}

