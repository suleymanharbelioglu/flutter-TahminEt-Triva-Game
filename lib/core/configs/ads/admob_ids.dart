import 'package:flutter/foundation.dart';

class AdMobIds {
  static String get gameStartInterstitial {
    if (kIsWeb) return '';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ca-app-pub-6970688308215711/5859365403';
      case TargetPlatform.android:
        return 'ca-app-pub-6970688308215711/3866393700';
      default:
        return '';
    }
  }

  static String get playAgainInterstitial {
    if (kIsWeb) return '';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ca-app-pub-6970688308215711/4546283734';
      case TargetPlatform.android:
        return 'ca-app-pub-6970688308215711/5433027759';
      default:
        return '';
    }
  }

  static String get homePageBanner {
    if (kIsWeb) return '';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ca-app-pub-6970688308215711/1213543385';
      case TargetPlatform.android:
        return 'ca-app-pub-6970688308215711/7606026846';
      default:
        return '';
    }
  }

  static String get gameResultBanner {
    if (kIsWeb) return '';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ca-app-pub-6970688308215711/8381586964';
      case TargetPlatform.android:
        return 'ca-app-pub-6970688308215711/4715714592';
      default:
        return '';
    }
  }
}

