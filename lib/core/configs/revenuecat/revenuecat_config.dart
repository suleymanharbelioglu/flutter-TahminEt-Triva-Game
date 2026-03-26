import 'dart:io';

import 'package:ben_kimim/core/configs/revenuecat/revenuecat_keys.dart';

/// RevenueCat API keys — öncelik sırası:
/// 1) `--dart-define` (CI / gizli build için)
/// 2) `revenuecat_keys.dart` içindeki sabitler (doğrudan projede)
class RevenueCatConfig {
  /// Tek key (çoğunlukla test): `--dart-define=REVENUECAT_API_KEY=...`
  static const String apiKeyAnyPlatform =
      String.fromEnvironment('REVENUECAT_API_KEY');

  static const String iosApiKeyEnv =
      String.fromEnvironment('REVENUECAT_IOS_API_KEY');
  static const String androidApiKeyEnv =
      String.fromEnvironment('REVENUECAT_ANDROID_API_KEY');

  static String get apiKey {
    if (apiKeyAnyPlatform.isNotEmpty) return apiKeyAnyPlatform;
    if (kRevenueCatTestApiKey.isNotEmpty) return kRevenueCatTestApiKey;

    if (Platform.isIOS) {
      if (iosApiKeyEnv.isNotEmpty) return iosApiKeyEnv;
      return kRevenueCatIosPublicKey;
    }

    if (androidApiKeyEnv.isNotEmpty) return androidApiKeyEnv;
    return kRevenueCatAndroidPublicKey;
  }

  static bool get isConfigured => apiKey.isNotEmpty;
}

