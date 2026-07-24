import 'dart:async';

import 'package:ben_kimim/core/ads/interstitial_ad_cache.dart';
import 'package:ben_kimim/core/configs/ads/admob_ids.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Geçiş reklamı: uygulama açılışında ilk gösterim 2 dk sonra,
/// sonrasında 120 saniyede bir.
/// [PhoneToForeheadPage] ve [GamePage] üzerindeyken asla gösterilmez;
/// süre dolmuşsa bu sayfalardan çıkınca gösterilir.
class InterstitialSchedulerCubit extends Cubit<void> {
  InterstitialSchedulerCubit() : super(null);

  static const _initialDelay = Duration(seconds: 120);
  static const _interval = Duration(seconds: 120);
  static const deckWatchBonus = Duration(seconds: 40);

  Timer? _timer;
  DateTime? _nextFireAt;
  int _blockedDepth = 0;
  bool _pending = false;
  bool _enabled = true;
  bool _pastInitial = false;

  bool get isBlocked => _blockedDepth > 0;

  void setEnabled(bool enabled) {
    _enabled = enabled;
    if (!enabled) {
      _stop();
      _pending = false;
      _pastInitial = false;
    } else {
      _start();
    }
  }

  /// "Reklam İzle Oyna" sonrası: bir sonraki zamanlanmış geçiş reklamını
  /// tek seferlik [bonus] kadar geciktirir.
  void postponeNextShow({Duration bonus = deckWatchBonus}) {
    if (!_enabled) return;

    final remaining = _nextFireAt == null
        ? (_pastInitial ? _interval : _initialDelay)
        : _nextFireAt!.difference(DateTime.now());
    final base = remaining.isNegative ? Duration.zero : remaining;
    _scheduleNext(base + bonus);

    if (kDebugMode) {
      debugPrint(
        'InterstitialScheduler: next show postponed by ${bonus.inSeconds}s '
        '(wait ${(base + bonus).inSeconds}s)',
      );
    }
  }

  void _start() {
    if (!_enabled) return;
    _pastInitial = false;
    AppInterstitials.gameStart.preload(AdMobIds.gameStartInterstitial);
    _scheduleNext(_initialDelay);
    if (kDebugMode) {
      debugPrint(
        'InterstitialScheduler: started '
        '(first in ${_initialDelay.inSeconds}s, then every ${_interval.inSeconds}s)',
      );
    }
  }

  void _scheduleNext(Duration delay) {
    _timer?.cancel();
    _nextFireAt = DateTime.now().add(delay);
    _timer = Timer(delay, _onTimerFire);
  }

  void _onTimerFire() {
    if (!_enabled) return;
    _pastInitial = true;
    _onIntervalElapsed();
    _scheduleNext(_interval);
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _nextFireAt = null;
  }

  void enterBlockedScreen() {
    _blockedDepth++;
    if (kDebugMode) {
      debugPrint('InterstitialScheduler: blocked depth=$_blockedDepth');
    }
  }

  void leaveBlockedScreen() {
    if (_blockedDepth > 0) _blockedDepth--;
    if (kDebugMode) {
      debugPrint(
        'InterstitialScheduler: leave blocked depth=$_blockedDepth pending=$_pending',
      );
    }
    if (_blockedDepth == 0 && _pending) {
      _pending = false;
      _tryShowInterstitial();
    }
  }

  void _onIntervalElapsed() {
    if (!_enabled) return;
    if (kDebugMode) {
      debugPrint(
        'InterstitialScheduler: interval elapsed blocked=$isBlocked',
      );
    }
    if (isBlocked) {
      _pending = true;
    } else {
      _tryShowInterstitial();
    }
  }

  void _tryShowInterstitial() {
    AppInterstitials.gameStart.preload(AdMobIds.gameStartInterstitial);
    final shown = AppInterstitials.gameStart.showIfReady(
      onDone: () {
        AppInterstitials.gameStart.preload(AdMobIds.gameStartInterstitial);
      },
    );
    if (kDebugMode) {
      debugPrint('InterstitialScheduler: show attempt → ${shown ? "shown" : "not ready"}');
    }
  }

  @override
  Future<void> close() {
    _stop();
    return super.close();
  }
}
