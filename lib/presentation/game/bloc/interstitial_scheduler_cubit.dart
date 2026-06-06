import 'dart:async';

import 'package:ben_kimim/core/ads/interstitial_ad_cache.dart';
import 'package:ben_kimim/core/configs/ads/admob_ids.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Geçiş reklamı: 90 saniyede bir gösterilir.
/// [PhoneToForeheadPage] ve [GamePage] üzerindeyken asla gösterilmez;
/// süre dolmuşsa bu sayfalardan çıkınca gösterilir.
class InterstitialSchedulerCubit extends Cubit<void> {
  InterstitialSchedulerCubit() : super(null);

  static const _interval = Duration(seconds: 90);

  Timer? _timer;
  int _blockedDepth = 0;
  bool _pending = false;
  bool _enabled = true;

  bool get isBlocked => _blockedDepth > 0;

  void setEnabled(bool enabled) {
    _enabled = enabled;
    if (!enabled) {
      _stop();
      _pending = false;
    } else {
      _start();
    }
  }

  void _start() {
    if (!_enabled) return;
    _timer?.cancel();
    AppInterstitials.gameStart.preload(AdMobIds.gameStartInterstitial);
    _timer = Timer.periodic(_interval, (_) => _onIntervalElapsed());
    if (kDebugMode) {
      debugPrint('InterstitialScheduler: started (${_interval.inSeconds}s interval)');
    }
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
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
