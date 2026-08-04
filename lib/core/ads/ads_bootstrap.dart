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
      _preloadAds();
      return;
    }

    try {
      if (kDebugMode) {
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(
            testDeviceIds: const [
              'f227aa022f3f2850308c622f36a4782e',
              '9762f7d4d9f849eb9d3e5c9489e11fc9',
              'D09DE3465F0FF17A7C7AA0997E40DFCA',
              '15F6C1769B126AFCAE3DEF07F7836397',
            ],
          ),
        );
      }
      await MobileAds.instance.initialize();
      _initialized = true;
      if (kDebugMode) {
        debugPrint('AdsBootstrap: MobileAds.initialize completed');
      }
      _preloadAds();
    } catch (e, st) {
      debugPrint('AdsBootstrap: MobileAds.initialize failed: $e\n$st');
    }
  }
}
