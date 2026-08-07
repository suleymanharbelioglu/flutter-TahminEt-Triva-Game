import 'dart:async';

import 'package:ben_kimim/core/ads/interstitial_ad_cache.dart';
import 'package:ben_kimim/core/analytics/analytics_service.dart';
import 'package:ben_kimim/core/configs/ads/admob_ids.dart';
import 'package:ben_kimim/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Geçiş reklamı: Ads SDK hazır + non-premium olduktan 60 sn sonra ilk gösterim,
/// sonrasında reklam kapandıktan 60 saniye sonra tekrar.
/// [PhoneToForeheadPage] ve [GamePage] üzerindeyken asla gösterilmez;
/// süre dolmuşsa bu sayfalardan çıkınca gösterilir.
class InterstitialSchedulerCubit extends Cubit<void> {
  InterstitialSchedulerCubit() : super(null);

  static const _interval = Duration(seconds: 60);

  /// Yüklenemedi / henüz hazır değilse kısa süre sonra tekrar dene.
  static const _retryWhenNotReady = Duration(seconds: 15);

  /// Rewarded "Reklam İzle" tıklanınca bir sonraki geçişe eklenen süre.
  static const rewardedWatchBonus = Duration(seconds: 30);

  /// Rota geçişi bittikten sonra göster (show fail oranını düşürür).
  static const _showAfterRouteSettle = Duration(milliseconds: 400);

  static const _placement = 'timed_interstitial';

  Timer? _timer;
  Timer? _tickTimer;
  Timer? _pendingShowTimer;
  DateTime? _nextFireAt;
  int _blockedDepth = 0;
  bool _pending = false;
  bool _enabled = false;
  bool _adsReady = false;
  bool _armed = false;

  bool get isBlocked => _blockedDepth > 0;

  void setEnabled(bool enabled) {
    if (!enabled) {
      _enabled = false;
      _armed = false;
      _pending = false;
      _pendingShowTimer?.cancel();
      _pendingShowTimer = null;
      _stop();
      debugPrint('InterstitialScheduler: DISABLED');
      return;
    }

    _enabled = true;
    if (AppInterstitials.sdkInitialized) {
      _adsReady = true;
    }
    _tryArm(reason: 'enabled');
  }

  /// Splash'te [AdsBootstrap.initializeAndPreload] bittikten sonra çağrılmalı.
  void onAdsSdkReady() {
    _adsReady = true;
    debugPrint('InterstitialScheduler: ads SDK ready');
    _tryArm(reason: 'ads ready');
  }

  void _tryArm({required String reason}) {
    if (!_enabled || !_adsReady) {
      debugPrint(
        'InterstitialScheduler: arm deferred '
        '(enabled=$_enabled, adsReady=$_adsReady, reason=$reason)',
      );
      return;
    }
    if (_armed) return;

    _armed = true;
    AppInterstitials.gameStart.preload(AdMobIds.gameStartInterstitial);
    _scheduleNext(_interval, reason: reason);
  }

  /// Bir sonraki zamanlanmış geçiş reklamını [bonus] kadar geciktirir.
  void postponeNextShow({Duration bonus = rewardedWatchBonus}) {
    if (!_enabled || !_armed) return;

    _pending = false;
    _pendingShowTimer?.cancel();
    _pendingShowTimer = null;
    final remaining = _nextFireAt == null
        ? Duration.zero
        : _nextFireAt!.difference(DateTime.now());
    final base = remaining.isNegative ? Duration.zero : remaining;
    _scheduleNext(base + bonus, reason: 'postpone +${bonus.inSeconds}s');
  }

  void _scheduleNext(Duration delay, {required String reason}) {
    _timer?.cancel();
    _nextFireAt = DateTime.now().add(delay);
    _timer = Timer(delay, _onTimerFire);
    _startTickLog();
    debugPrint(
      'InterstitialScheduler: timer set → ${delay.inSeconds}s '
      '(reason=$reason, blocked=$isBlocked, pending=$_pending)',
    );
  }

  void _startTickLog() {
    _tickTimer?.cancel();
    if (!kDebugMode) return;

    _tickTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final next = _nextFireAt;
      if (!_enabled || next == null) {
        _tickTimer?.cancel();
        _tickTimer = null;
        return;
      }
      final remaining = next.difference(DateTime.now()).inSeconds;
      debugPrint(
        'InterstitialScheduler: timer → ${remaining > 0 ? remaining : 0}s '
        '(blocked=$isBlocked, pending=$_pending)',
      );
    });
  }

  void _onTimerFire() {
    if (!_enabled) return;
    debugPrint('InterstitialScheduler: timer FIRED (blocked=$isBlocked)');
    _onIntervalElapsed();
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _tickTimer?.cancel();
    _tickTimer = null;
    _nextFireAt = null;
  }

  void enterBlockedScreen() {
    _blockedDepth++;
    _pendingShowTimer?.cancel();
    _pendingShowTimer = null;
    debugPrint('InterstitialScheduler: blocked depth=$_blockedDepth');
  }

  void leaveBlockedScreen() {
    if (_blockedDepth > 0) _blockedDepth--;
    debugPrint(
      'InterstitialScheduler: leave blocked depth=$_blockedDepth pending=$_pending',
    );
    if (_blockedDepth == 0 && _pending) {
      _pending = false;
      _pendingShowTimer?.cancel();
      _pendingShowTimer = Timer(_showAfterRouteSettle, () {
        _pendingShowTimer = null;
        if (!_enabled) return;
        if (isBlocked) {
          _pending = true;
          debugPrint(
            'InterstitialScheduler: re-pending (entered blocked during settle)',
          );
          return;
        }
        unawaited(_tryShowInterstitial());
      });
    }
  }

  void _onIntervalElapsed() {
    if (!_enabled) return;
    if (isBlocked) {
      // Timer durur; engelli ekrandan çıkınca gösterilir, süre o zaman başlar.
      _pending = true;
      _tickTimer?.cancel();
      _tickTimer = null;
      debugPrint(
        'InterstitialScheduler: pending (blocked) — show on leave',
      );
    } else {
      unawaited(_tryShowInterstitial());
    }
  }

  Future<void> _tryShowInterstitial() async {
    final cache = AppInterstitials.gameStart;
    final adUnitId = AdMobIds.gameStartInterstitial;

    debugPrint(
      'InterstitialScheduler: show attempt start '
      '(ready=${cache.isReady}, loading=${cache.isLoading}, '
      'sdk=${AppInterstitials.sdkInitialized})',
    );

    if (!AppInterstitials.sdkInitialized) {
      sl<AnalyticsService>().logInterstitialFailed(
        placement: _placement,
        reason: 'sdk_not_ready',
      );
      _scheduleNext(_retryWhenNotReady, reason: 'sdk not ready');
      return;
    }

    // Timer ateşlendiğinde yükleme sürüyorsa kısa bekle; yoksa yeniden dene.
    final ready = await cache.waitUntilReady(
      adUnitId,
      timeout: const Duration(seconds: 5),
    );

    if (!_enabled) return;

    if (!ready) {
      debugPrint(
        'InterstitialScheduler: show attempt → not ready '
        '(ready=${cache.isReady}, loading=${cache.isLoading})',
      );
      sl<AnalyticsService>().logInterstitialFailed(
        placement: _placement,
        reason: 'not_ready',
      );
      _scheduleNext(_retryWhenNotReady, reason: 'not ready retry');
      return;
    }

    if (isBlocked) {
      _pending = true;
      debugPrint('InterstitialScheduler: became blocked during wait — pending');
      return;
    }

    final shown = cache.showIfReady(
      placement: _placement,
      onDone: () {
        cache.preload(adUnitId);
        if (_enabled) {
          _scheduleNext(_interval, reason: 'after dismiss');
        }
      },
    );

    debugPrint(
      'InterstitialScheduler: show attempt → ${shown ? "shown" : "not ready"}',
    );

    if (shown) {
      sl<AnalyticsService>().logInterstitialShown(placement: _placement);
    } else if (_enabled) {
      sl<AnalyticsService>().logInterstitialFailed(
        placement: _placement,
        reason: 'show_failed',
      );
      _scheduleNext(_retryWhenNotReady, reason: 'not ready retry');
    }
  }

  @override
  Future<void> close() {
    _pendingShowTimer?.cancel();
    _stop();
    return super.close();
  }
}
