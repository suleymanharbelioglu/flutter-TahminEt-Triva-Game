import 'dart:async';

import 'package:ben_kimim/core/ads/ad_exit_tracker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Rewarded reklamı önceden yükler; tam izlenince [onReward] çağrılır.
class RewardedAdCache {
  RewardedAd? _ad;
  bool _loading = false;

  bool get isReady => _ad != null;

  bool get isLoading => _loading;

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

  void preload(String adUnitId) {
    if (adUnitId.isEmpty) return;
    if (_loading || _ad != null) return;

    _loading = true;
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _ad = ad;
          if (kDebugMode) {
            debugPrint('Rewarded loaded: adUnitId=$adUnitId');
          }
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          if (kDebugMode) {
            debugPrint(
              'Rewarded preload failed: adUnitId=$adUnitId code=${error.code} message=${error.message}',
            );
          }
        },
      ),
    );
  }

  /// Reklam hazırsa gösterir. Ödül kazanılırsa true döner.
  Future<bool> showIfReady({
    required VoidCallback onDone,
    required VoidCallback onReward,
    String placement = 'deck_unlock',
  }) async {
    final ad = _ad;
    if (ad == null) return false;

    _ad = null;
    _loading = false;

    final completer = Completer<bool>();
    var rewarded = false;
    var settled = false;

    void settle() {
      if (settled) return;
      settled = true;
      unawaited(AdExitTracker.markFinished());
      onDone();
      if (!completer.isCompleted) completer.complete(rewarded);
    }

    unawaited(
      AdExitTracker.markShowing(
        format: 'rewarded',
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
            'Rewarded failed to show: code=${error.code} message=${error.message}',
          );
        }
        a.dispose();
        settle();
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ad.show(
          onUserEarnedReward: (_, __) {
            rewarded = true;
            onReward();
          },
        );
      } catch (_) {
        ad.dispose();
        settle();
      }
    });

    return completer.future;
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
    _loading = false;
  }
}

class AppRewardedAds {
  AppRewardedAds._();

  static final deckUnlock = RewardedAdCache();
}
