import 'dart:async';

import 'package:ben_kimim/core/configs/ads/admob_ids.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Interstitial'ı önceden yükleyip (preload) hazırsa anında gösterir.
class InterstitialAdCache {
  InterstitialAd? _ad;
  bool _loading = false;
  DateTime? _loadedAt;

  bool get isReady => _ad != null;

  bool get isLoading => _loading;

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
          if (kDebugMode) {
            debugPrint('Interstitial loaded: adUnitId=$adUnitId');
          }
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          if (kDebugMode) {
            debugPrint(
              'Interstitial preload failed: adUnitId=$adUnitId code=${error.code} domain=${error.domain} message=${error.message}',
            );
          }
        },
      ),
    );
  }

  /// [timeout] dolana kadar reklamın hazır olmasını bekler.
  Future<bool> waitUntilReady(
    String adUnitId, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (isReady) return true;
    if (adUnitId.isEmpty) return false;

    preload(adUnitId);
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      if (isReady) return true;
      await Future.delayed(const Duration(milliseconds: 100));
      if (!_loading && _ad == null) {
        preload(adUnitId);
      }
    }

    return isReady;
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
        if (kDebugMode) {
          debugPrint(
            'Interstitial failed to show: code=${error.code} domain=${error.domain} message=${error.message}',
          );
        }
        a.dispose();
        onDone();
      },
    );

    // Bazı cihazlarda show çağrısı anında hata verebiliyor; bir frame sonra daha stabil.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ad.show();
      } catch (_) {
        if (kDebugMode) {
          debugPrint('Interstitial show threw exception');
        }
        ad.dispose();
        onDone();
      }
    });

    return true;
  }

  /// Hazırsa gösterir; kapanınca true döner. Gösterilemezse false.
  Future<bool> showAndAwait({required VoidCallback onDone}) async {
    final ad = _ad;
    if (ad == null) return false;

    _ad = null;
    _loading = false;

    final completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        onDone();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (a, error) {
        if (kDebugMode) {
          debugPrint(
            'Interstitial failed to show: code=${error.code} domain=${error.domain} message=${error.message}',
          );
        }
        a.dispose();
        onDone();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ad.show();
      } catch (_) {
        if (kDebugMode) {
          debugPrint('Interstitial show threw exception');
        }
        ad.dispose();
        onDone();
        if (!completer.isCompleted) completer.complete(false);
      }
    });

    return completer.future;
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

/// Uygulama genelinde interstitial cache.
class AppInterstitials {
  AppInterstitials._();

  static final gameStart = InterstitialAdCache();

  /// "Reklam İzle Oyna" desteleri için ayrı cache (scheduler ile çakışmasın).
  static final deckUnlock = InterstitialAdCache();

  static void preloadAll() {
    gameStart.dropIfStale();
    gameStart.preload(AdMobIds.gameStartInterstitial);
    deckUnlock.dropIfStale();
    deckUnlock.preload(AdMobIds.gameStartInterstitial);
  }
}
