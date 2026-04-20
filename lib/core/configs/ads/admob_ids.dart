import 'package:flutter/foundation.dart';

class AdMobIds {
  /// [InterstitialAd.load] yanıtı gelmezse oyuna geçiş için üst süre (reklam gösterilmeden).
  static const Duration interstitialLoadTimeout = Duration(seconds: 3);

  /// **Android — tek anahtar (tüm reklam türleri):**
  /// - `true` → oyun başı / tekrar interstitial + ana sayfa + sonuç banner hepsi Google **test** birimi.
  /// - `false` → hepsi **üretim** birimleri. Mağaza / iç yayın öncesi mutlaka `false`.
  static const bool useTestAdsOnAndroid = false;

  /// iOS'ta Google test birim ID'leri kullanılsın mı?
  ///
  /// Not: iOS'ta reklam görünmüyorsa teşhis için bunu geçici olarak `true` yap.
  /// Yayın / gerçek reklamlar için `false` (üretim birimleri).
  static bool useTestAdsOnIOS = false;

  // Google test ad unit IDs (safe for development).
  static const String _testBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/4411468910';

  // Production ad unit IDs (senin gerçek ID'lerin).
  static const String _prodGameStartInterstitialIOS =
      'ca-app-pub-6970688308215711/5859365403';
  static const String _prodGameStartInterstitialAndroid =
      'ca-app-pub-6970688308215711/3866393700';

  static const String _prodPlayAgainInterstitialIOS =
      'ca-app-pub-6970688308215711/4546283734';
  static const String _prodPlayAgainInterstitialAndroid =
      'ca-app-pub-6970688308215711/5433027759';

  static const String _prodHomePageBannerIOS =
      'ca-app-pub-6970688308215711/1213543385';
  static const String _prodHomePageBannerAndroid =
      'ca-app-pub-6970688308215711/7606026846';

  static const String _prodGameResultBannerIOS =
      'ca-app-pub-6970688308215711/8381586964';
  static const String _prodGameResultBannerAndroid =
      'ca-app-pub-6970688308215711/4715714592';

  static bool get _useTestIos =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.iOS &&
      useTestAdsOnIOS;

  static bool get _useTestAndroid =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      useTestAdsOnAndroid;

  static String get gameStartInterstitial {
    if (kIsWeb) return '';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return _useTestIos ? _testInterstitial : _prodGameStartInterstitialIOS;
      case TargetPlatform.android:
        return _useTestAndroid
            ? _testInterstitial
            : _prodGameStartInterstitialAndroid;
      default:
        return '';
    }
  }

  static String get playAgainInterstitial {
    if (kIsWeb) return '';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return _useTestIos ? _testInterstitial : _prodPlayAgainInterstitialIOS;
      case TargetPlatform.android:
        return _useTestAndroid
            ? _testInterstitial
            : _prodPlayAgainInterstitialAndroid;
      default:
        return '';
    }
  }

  static String get homePageBanner {
    if (kIsWeb) return '';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return _useTestIos ? _testBanner : _prodHomePageBannerIOS;
      case TargetPlatform.android:
        return _useTestAndroid ? _testBanner : _prodHomePageBannerAndroid;
      default:
        return '';
    }
  }

  static String get gameResultBanner {
    if (kIsWeb) return '';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return _useTestIos ? _testBanner : _prodGameResultBannerIOS;
      case TargetPlatform.android:
        return _useTestAndroid ? _testBanner : _prodGameResultBannerAndroid;
      default:
        return '';
    }
  }
}
