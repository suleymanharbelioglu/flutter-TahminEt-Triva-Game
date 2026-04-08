import 'package:ben_kimim/core/configs/ads/admob_ids.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Interstitial'ı önceden yükleyip (preload) hazırsa anında gösterir.
/// Hazır değilse kullanıcıyı bekletmez; sadece arka planda hazırlamaya çalışır.
class InterstitialAdCache {
  InterstitialAd? _ad;
  bool _loading = false;
  DateTime? _loadedAt;

  bool get isReady => _ad != null;

  void preload(String adUnitId) {
    if (adUnitId.isEmpty) return;
    if (_loading || _ad != null) return;

    _loading = true;
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _ad = ad;
          _loadedAt = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          if (kDebugMode) {
            debugPrint('Interstitial preload failed: $error');
          }
        },
      ),
    );
  }

  /// Hazırsa gösterir ve kapanınca [onDone] çağırır. Hazır değilse false döner.
  bool showIfReady({required VoidCallback onDone}) {
    final ad = _ad;
    if (ad == null) return false;

    _ad = null;
    _loading = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        onDone();
      },
      onAdFailedToShowFullScreenContent: (a, error) {
        a.dispose();
        onDone();
      },
    );

    // Bazı cihazlarda show çağrısı anında hata verebiliyor; bir frame sonra daha stabil.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ad.show();
      } catch (_) {
        ad.dispose();
        onDone();
      }
    });

    return true;
  }

  /// Çok uzun süre beklemiş ad'leri kullanmayalım.
  void dropIfStale() {
    final t = _loadedAt;
    if (_ad == null || t == null) return;
    if (DateTime.now().difference(t) > const Duration(minutes: 55)) {
      _ad?.dispose();
      _ad = null;
      _loadedAt = null;
      _loading = false;
    }
  }
}

/// Uygulama genelinde iki ayrı interstitial cache.
class AppInterstitials {
  AppInterstitials._();

  static final gameStart = InterstitialAdCache();
  static final playAgain = InterstitialAdCache();

  static void preloadAll() {
    gameStart.dropIfStale();
    playAgain.dropIfStale();
    gameStart.preload(AdMobIds.gameStartInterstitial);
    playAgain.preload(AdMobIds.playAgainInterstitial);
  }
}

