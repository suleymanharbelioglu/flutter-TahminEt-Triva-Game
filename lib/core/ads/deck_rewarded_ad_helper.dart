import 'package:ben_kimim/common/widget/ads/rewarded_ad_loading_page.dart';
import 'package:ben_kimim/core/ads/rewarded_ad_cache.dart';
import 'package:ben_kimim/core/analytics/analytics_service.dart';
import 'package:ben_kimim/core/configs/ads/admob_ids.dart';
import 'package:ben_kimim/presentation/game/bloc/interstitial_scheduler_cubit.dart';
import 'package:ben_kimim/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Deste kilidi için rewarded reklam akışı.
class DeckRewardedAdHelper {
  DeckRewardedAdHelper._();

  static const Duration loadTimeout = Duration(seconds: 5);
  static const String _placement = 'deck_unlock';
  static const String _format = 'rewarded';

  /// Yükleme sayfası gösterir, reklam hazırsa oynatır.
  /// 5 sn içinde yüklenmezse ödül verilip true döner (devam edilebilir).
  /// Tıklanınca zamanlı geçiş reklamına +30 sn eklenir.
  static Future<bool> watchForDeckUnlock({
    required BuildContext context,
    required VoidCallback onReward,
  }) async {
    if (!context.mounted) return false;

    context.read<InterstitialSchedulerCubit>().postponeNextShow();

    final cache = AppRewardedAds.deckUnlock;
    final analytics = sl<AnalyticsService>();
    cache.preload(AdMobIds.deckRewarded);

    final navigator = Navigator.of(context);
    navigator.push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.45),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const RewardedAdLoadingPage(),
      ),
    );

    final ready = await cache.waitUntilReady(
      AdMobIds.deckRewarded,
      timeout: loadTimeout,
    );

    if (context.mounted) {
      navigator.pop();
    }

    if (ready) {
      await analytics.logAdsShown(format: _format, placement: _placement);
      final watched = await cache.showIfReady(
        onReward: onReward,
        onDone: () => cache.preload(AdMobIds.deckRewarded),
        placement: _placement,
      );
      await analytics.logRewardedAdWatched(
        placement: _placement,
        earnedReward: watched,
      );
      if (!watched) {
        await analytics.logAdsIncomplete(
          format: _format,
          placement: _placement,
          reason: 'closed_without_reward',
        );
      }
      return watched;
    }

    await analytics.logAdsFailed(
      format: _format,
      placement: _placement,
      reason: 'load_timeout',
    );
    await analytics.logRewardedAdSkipped(
      placement: _placement,
      reason: 'load_timeout',
    );
    onReward();
    cache.preload(AdMobIds.deckRewarded);
    return true;
  }
}
