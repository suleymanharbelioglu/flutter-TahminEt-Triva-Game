import 'dart:async';

import 'package:ben_kimim/core/configs/ads/admob_ids.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Interstitial'ı önceden yükleyip (preload) hazırsa anında gösterir.
///
/// Fail olunca [preloadRetryDelay] ile otomatik yeniden dener.
/// Show sırasında cache yoksa kısa süre yüklemeyi bekler.
class InterstitialAdCache {
  InterstitialAd? _ad;
  bool _loading = false;
  DateTime? _loadedAt;
  Timer? _retryTimer;
  String? _lastAdUnitId;

  /// Show anında cache yoksa yükleme için üst bekleme.
  static const Duration showWaitTimeout = Duration(seconds: 5);

  /// Preload fail sonrası yeniden deneme aralığı.
  static const Duration preloadRetryDelay = Duration(seconds: 10);

  bool get isReady => _ad != null;

  bool get isLoading => _loading;

  void preload(String adUnitId) {
    if (adUnitId.isEmpty) return;
    if (_loading || _ad != null) return;

    _lastAdUnitId = adUnitId;
    _retryTimer?.cancel();
    _retryTimer = null;
    _loading = true;
    _log('preload start adUnit=$adUnitId');

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _ad = ad;
          _loadedAt = DateTime.now();
          _log('preload OK (cached) adUnit=$adUnitId');
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          _log(
            'preload FAIL adUnit=$adUnitId '
            'code=${error.code} domain=${error.domain} message=${error.message}',
          );
          _schedulePreloadRetry(adUnitId);
        },
      ),
    );
  }

  void _schedulePreloadRetry(String adUnitId) {
    _retryTimer?.cancel();
    _retryTimer = Timer(preloadRetryDelay, () {
      _retryTimer = null;
      _log('preload retry adUnit=$adUnitId');
      preload(adUnitId);
    });
  }

  /// [timeout] dolana kadar reklamın hazır olmasını bekler.
  Future<bool> waitUntilReady(
    String adUnitId, {
    Duration timeout = showWaitTimeout,
  }) async {
    if (isReady) return true;
    if (adUnitId.isEmpty) return false;

    _log(
      'wait for load adUnit=$adUnitId '
      'timeout=${timeout.inSeconds}s loading=$isLoading',
    );
    preload(adUnitId);
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      if (isReady) return true;
      await Future.delayed(const Duration(milliseconds: 100));
      if (!_loading && _ad == null) {
        preload(adUnitId);
      }
    }

    _log('wait timeout → no fill adUnit=$adUnitId');
    return isReady;
  }

  /// Hazırsa gösterir ve kapanınca [onDone] çağırır. Hazır değilse false döner.
  bool showIfReady({required VoidCallback onDone}) {
    final ad = _ad;
    if (ad == null) return false;

    _ad = null;
    _loading = false;
    _loadedAt = null;

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
    _loadedAt = null;

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
      final unit = _lastAdUnitId;
      if (unit != null && unit.isNotEmpty) {
        _schedulePreloadRetry(unit);
      }
    }
  }

  void _log(String message) {
    // ignore: avoid_print
    print('[AdLoad] $message');
  }
}

/// Uygulama genelinde interstitial cache.
class AppInterstitials {
  AppInterstitials._();

  static final gameStart = InterstitialAdCache();

  static void preloadAll() {
    gameStart.dropIfStale();
    gameStart.preload(AdMobIds.gameStartInterstitial);
  }
}
