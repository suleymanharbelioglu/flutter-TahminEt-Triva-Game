import 'package:flutter/foundation.dart';

class AdMobIds {
  /// true iken iOS'ta Google test birim ID'leri kullanılır.
  /// Yayın / gerçek reklamlar için false (üretim birimleri).
  static const bool _useTestAdsOnIOS = false;

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
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS && _useTestAdsOnIOS;

  static String get gameStartInterstitial {
    if (kIsWeb) return '';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return _useTestIos ? _testInterstitial : _prodGameStartInterstitialIOS;
      case TargetPlatform.android:
        return _prodGameStartInterstitialAndroid;
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
        return _prodPlayAgainInterstitialAndroid;
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
        return _prodHomePageBannerAndroid;
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
        return _prodGameResultBannerAndroid;
      default:
        return '';
    }
  }
}

