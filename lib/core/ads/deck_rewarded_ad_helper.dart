import 'package:ben_kimim/common/widget/ads/rewarded_ad_loading_page.dart';
import 'package:ben_kimim/core/ads/rewarded_ad_cache.dart';
import 'package:ben_kimim/core/configs/ads/admob_ids.dart';
import 'package:ben_kimim/presentation/game/bloc/interstitial_scheduler_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Deste kilidi için rewarded reklam akışı.
class DeckRewardedAdHelper {
  DeckRewardedAdHelper._();

  static const Duration loadTimeout = Duration(seconds: 5);

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
      return cache.showIfReady(
        onReward: onReward,
        onDone: () => cache.preload(AdMobIds.deckRewarded),
      );
    }

    onReward();
    cache.preload(AdMobIds.deckRewarded);
    return true;
  }
}
