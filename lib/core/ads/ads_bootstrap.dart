import 'package:ben_kimim/core/ads/interstitial_ad_cache.dart';
import 'package:ben_kimim/core/ads/rewarded_ad_cache.dart';
import 'package:ben_kimim/core/configs/ads/admob_ids.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// UMP / ATT sonrası Mobile Ads init + interstitial/rewarded preload.
///
/// ATT reddedilse bile reklam yüklenir (kişiselleştirilmemiş olabilir).
class AdsBootstrap {
  AdsBootstrap._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static void _preloadAds() {
    AppInterstitials.preloadAll();
    AppRewardedAds.deckUnlock.preload(AdMobIds.deckRewarded);
  }

  static Future<void> initializeAndPreload() async {
    if (_initialized) {
      AppInterstitials.markSdkInitialized();
      _preloadAds();
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _initialized = true;
      AppInterstitials.markSdkInitialized();
      if (kDebugMode) {
        debugPrint('AdsBootstrap: MobileAds.initialize completed');
      }
      _preloadAds();
    } catch (e, st) {
      debugPrint('AdsBootstrap: MobileAds.initialize failed: $e\n$st');
    }
  }
}
