import 'dart:async';

import 'package:ben_kimim/core/ads/ad_exit_tracker.dart';
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
  DateTime? _loadingStartedAt;
  Timer? _retryTimer;
  String? _lastAdUnitId;

  /// Show anında cache yoksa yükleme için üst bekleme.
  static const Duration showWaitTimeout = Duration(seconds: 5);

  /// Preload fail sonrası yeniden deneme aralığı.
  static const Duration preloadRetryDelay = Duration(seconds: 10);

  /// SDK init öncesi / takılı load için üst süre.
  static const Duration loadWatchdog = Duration(seconds: 30);

  bool get isReady => _ad != null;

  bool get isLoading => _loading;

  void preload(String adUnitId) {
    if (adUnitId.isEmpty) return;
    // MobileAds.initialize tamamlanmadan load → callback gelmeyebilir / _loading kilitlenir.
    if (!AppInterstitials.sdkInitialized) {
      _log('preload skipped (Ads SDK not initialized) adUnit=$adUnitId');
      return;
    }
    if (_ad != null) return;

    if (_loading) {
      final started = _loadingStartedAt;
      final stuck = started != null &&
          DateTime.now().difference(started) > loadWatchdog;
      if (!stuck) return;
      _log('preload watchdog → unlock stuck load adUnit=$adUnitId');
      _loading = false;
      _loadingStartedAt = null;
    }

    _lastAdUnitId = adUnitId;
    _retryTimer?.cancel();
    _retryTimer = null;
    _loading = true;
    _loadingStartedAt = DateTime.now();
    _log('preload start adUnit=$adUnitId');

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _loadingStartedAt = null;
          _ad = ad;
          _loadedAt = DateTime.now();
          _log('preload OK (cached) adUnit=$adUnitId');
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          _loadingStartedAt = null;
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
    if (!AppInterstitials.sdkInitialized) {
      _log('wait skipped (Ads SDK not initialized)');
      return false;
    }

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
      } else if (_loading) {
        final started = _loadingStartedAt;
        if (started != null &&
            DateTime.now().difference(started) > loadWatchdog) {
          _log('wait watchdog → unlock stuck load');
          _loading = false;
          _loadingStartedAt = null;
          preload(adUnitId);
        }
      }
    }

    _log('wait timeout → no fill adUnit=$adUnitId');
    return isReady;
  }

  /// Hazırsa gösterir ve kapanınca [onDone] çağırır. Hazır değilse false döner.
  bool showIfReady({
    required VoidCallback onDone,
    String placement = 'timed_interstitial',
  }) {
    dropIfStale();
    final ad = _ad;
    if (ad == null) return false;

    _ad = null;
    _loading = false;
    _loadingStartedAt = null;
    _loadedAt = null;

    var settled = false;
    void settle() {
      if (settled) return;
      settled = true;
      unawaited(AdExitTracker.markFinished());
      onDone();
    }

    unawaited(
      AdExitTracker.markShowing(
        format: 'interstitial',
        placement: placement,
      ),
    );

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        settle();
      },
      onAdFailedToShowFullScreenContent: (a, error) {
        if (kDebugMode) {
          debugPrint(
            'Interstitial failed to show: code=${error.code} domain=${error.domain} message=${error.message}',
          );
        }
        a.dispose();
        settle();
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
        settle();
      }
    });

    return true;
  }

  /// Hazırsa gösterir; kapanınca true döner. Gösterilemezse false.
  Future<bool> showAndAwait({
    required VoidCallback onDone,
    String placement = 'timed_interstitial',
  }) async {
    dropIfStale();
    final ad = _ad;
    if (ad == null) return false;

    _ad = null;
    _loading = false;
    _loadingStartedAt = null;
    _loadedAt = null;

    final completer = Completer<bool>();
    var settled = false;

    void settle(bool shown) {
      if (settled) return;
      settled = true;
      unawaited(AdExitTracker.markFinished());
      onDone();
      if (!completer.isCompleted) completer.complete(shown);
    }

    unawaited(
      AdExitTracker.markShowing(
        format: 'interstitial',
        placement: placement,
      ),
    );

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        settle(true);
      },
      onAdFailedToShowFullScreenContent: (a, error) {
        if (kDebugMode) {
          debugPrint(
            'Interstitial failed to show: code=${error.code} domain=${error.domain} message=${error.message}',
          );
        }
        a.dispose();
        settle(false);
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
        settle(false);
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
      _loadingStartedAt = null;
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

  /// [AdsBootstrap] MobileAds.initialize sonrası true yapar.
  static bool sdkInitialized = false;

  static final gameStart = InterstitialAdCache();

  static void markSdkInitialized() {
    sdkInitialized = true;
  }

  static void preloadAll() {
    gameStart.dropIfStale();
    gameStart.preload(AdMobIds.gameStartInterstitial);
  }
}
