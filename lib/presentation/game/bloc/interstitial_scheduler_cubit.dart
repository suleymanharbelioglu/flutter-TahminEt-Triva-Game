import 'dart:async';

import 'package:ben_kimim/core/ads/interstitial_ad_cache.dart';
import 'package:ben_kimim/core/configs/ads/admob_ids.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Geçiş reklamı: uygulama açılışından itibaren 60 sn sonra ilk gösterim,
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

  Timer? _timer;
  Timer? _tickTimer;
  DateTime? _nextFireAt;
  int _blockedDepth = 0;
  bool _pending = false;
  bool _enabled = true;

  bool get isBlocked => _blockedDepth > 0;

  void setEnabled(bool enabled) {
    _enabled = enabled;
    if (!enabled) {
      _stop();
      _pending = false;
      debugPrint('InterstitialScheduler: DISABLED');
    } else {
      _start();
    }
  }

  /// Bir sonraki zamanlanmış geçiş reklamını [bonus] kadar geciktirir.
  void postponeNextShow({Duration bonus = rewardedWatchBonus}) {
    if (!_enabled) return;

    _pending = false;
    final remaining = _nextFireAt == null
        ? Duration.zero
        : _nextFireAt!.difference(DateTime.now());
    final base = remaining.isNegative ? Duration.zero : remaining;
    _scheduleNext(base + bonus, reason: 'postpone +${bonus.inSeconds}s');
  }

  void _start() {
    if (!_enabled) return;
    AppInterstitials.gameStart.preload(AdMobIds.gameStartInterstitial);
    _scheduleNext(_interval, reason: 'start');
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
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = _nextFireAt;
      if (!_enabled || next == null) {
        _tickTimer?.cancel();
        _tickTimer = null;
        return;
      }
      final remaining = next.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        debugPrint(
          'InterstitialScheduler: timer → 0s '
          '(blocked=$isBlocked, pending=$_pending)',
        );
        return;
      }
      debugPrint(
        'InterstitialScheduler: timer → ${remaining}s '
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
    debugPrint('InterstitialScheduler: blocked depth=$_blockedDepth');
  }

  void leaveBlockedScreen() {
    if (_blockedDepth > 0) _blockedDepth--;
    debugPrint(
      'InterstitialScheduler: leave blocked depth=$_blockedDepth pending=$_pending',
    );
    if (_blockedDepth == 0 && _pending) {
      _pending = false;
      unawaited(_tryShowInterstitial());
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
      '(ready=${cache.isReady}, loading=${cache.isLoading})',
    );

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
      _scheduleNext(_retryWhenNotReady, reason: 'not ready retry');
      return;
    }

    final shown = cache.showIfReady(
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

    if (!shown && _enabled) {
      _scheduleNext(_retryWhenNotReady, reason: 'not ready retry');
    }
  }

  @override
  Future<void> close() {
    _stop();
    return super.close();
  }
}
