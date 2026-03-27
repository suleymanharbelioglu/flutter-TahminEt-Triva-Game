import 'dart:io';

import 'package:ben_kimim/core/configs/revenuecat/revenuecat_keys.dart';
import 'package:flutter/foundation.dart';

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

    if (Platform.isIOS) {
      if (iosApiKeyEnv.isNotEmpty) return iosApiKeyEnv;
      if (kRevenueCatIosPublicKey.isNotEmpty) return kRevenueCatIosPublicKey;
      if (kDebugMode && kRevenueCatTestApiKey.isNotEmpty) {
        return kRevenueCatTestApiKey;
      }
      return '';
    }

    if (Platform.isAndroid) {
      if (androidApiKeyEnv.isNotEmpty) return androidApiKeyEnv;
      if (kRevenueCatAndroidPublicKey.isNotEmpty) {
        return kRevenueCatAndroidPublicKey;
      }
      if (kDebugMode && kRevenueCatTestApiKey.isNotEmpty) {
        return kRevenueCatTestApiKey;
      }
      return '';
    }

    if (kDebugMode && kRevenueCatTestApiKey.isNotEmpty) {
      return kRevenueCatTestApiKey;
    }
    return '';
  }

  static bool get isConfigured => apiKey.isNotEmpty;
}

