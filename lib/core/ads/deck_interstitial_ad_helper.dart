import 'package:ben_kimim/common/widget/ads/rewarded_ad_loading_page.dart';
import 'package:ben_kimim/core/ads/interstitial_ad_cache.dart';
import 'package:ben_kimim/core/configs/ads/admob_ids.dart';
import 'package:ben_kimim/presentation/game/bloc/interstitial_scheduler_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Deste kilidi için geçiş (interstitial) reklam akışı.
class DeckInterstitialAdHelper {
  DeckInterstitialAdHelper._();

  static const Duration loadTimeout = Duration(seconds: 5);

  /// Yükleme sayfası gösterir, geçiş reklamı hazırsa oynatır.
  /// 5 sn içinde yüklenmezse hak verilip true döner (devam edilebilir).
  static Future<bool> watchForDeckUnlock({
    required BuildContext context,
    required VoidCallback onUnlocked,
  }) async {
    if (!context.mounted) return false;

    final cache = AppInterstitials.deckUnlock;
    final adUnitId = AdMobIds.gameStartInterstitial;
    cache.preload(adUnitId);

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
      adUnitId,
      timeout: loadTimeout,
    );

    if (context.mounted) {
      navigator.pop();
    }

    if (ready) {
      final shown = await cache.showAndAwait(
        onDone: () => cache.preload(adUnitId),
      );
      if (shown) {
        onUnlocked();
        if (context.mounted) {
          context.read<InterstitialSchedulerCubit>().postponeNextShow();
        }
        return true;
      }
      return false;
    }

    // Reklam yüklenemezse oyunu engelleme.
    onUnlocked();
    cache.preload(adUnitId);
    return true;
  }
}
