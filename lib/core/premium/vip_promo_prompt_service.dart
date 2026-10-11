import 'package:ben_kimim/common/widget/alert/vip_discount_dialog.dart';
import 'package:ben_kimim/core/analytics/analytics_service.dart';
import 'package:ben_kimim/domain/rate_app/repository/rate_app_repository.dart';
import 'package:ben_kimim/presentation/bottom_nav/bloc/bottom_nav_cubit.dart';
import 'package:ben_kimim/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 2 tamamlanmış oyundan sonra, yalnızca bir kez VIP plan alert’i.
class VipPromoPromptService {
  VipPromoPromptService._();

  static const _shownKey = 'vip_promo_shown_once';

  /// Test için `true`: anasayfa her açılışında alert.
  /// Release / normal kullanım: `false` (yalnızca 2 oyun sonrası, bir kez).
  static const bool forceShowOnHomeForTesting = false;

  /// İlk (ve tek) alert için gereken tamamlanmış oyun sayısı.
  static const int minCompletedGames = 2;

  /// Anasayfaya gelince gösterim gecikmesi.
  static const Duration showDelay = Duration(seconds: 1);

  /// Paywall’daki pazarlama indirimiyle uyumlu (aylık kart %50).
  static const int discountPercent = 50;

  static Future<bool> shouldShow({required bool isPremium}) async {
    if (isPremium) return false;
    if (forceShowOnHomeForTesting) return true;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_shownKey) == true) return false;

    final games = await sl<RateAppRepository>().getGamesCompleted();
    return games >= minCompletedGames;
  }

  static Future<void> markShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shownKey, true);
  }

  /// Anasayfada; uygunsa dialog gösterir.
  /// `true` = dialog gösterildi.
  static Future<bool> maybeShow(
    BuildContext context, {
    required bool isPremium,
  }) async {
    final due = await shouldShow(isPremium: isPremium);
    if (!due || !context.mounted) return false;

    if (!forceShowOnHomeForTesting) {
      await markShown();
    }

    sl<AnalyticsService>().logVipPromoShown(
      deckName: 'n/a',
      accessType: forceShowOnHomeForTesting
          ? 'home_test'
          : 'after_two_games',
    );

    if (!context.mounted) return true;

    final accepted = await VipDiscountDialog.show(context);

    sl<AnalyticsService>().logVipPromoCta(
      deckName: 'n/a',
      accepted: accepted,
    );

    if (accepted && context.mounted) {
      context.read<BottomNavCubit>().changePage(
            0,
            premiumSource: forceShowOnHomeForTesting
                ? 'home_test_promo'
                : 'after_two_games_promo',
          );
    }

    return true;
  }
}
