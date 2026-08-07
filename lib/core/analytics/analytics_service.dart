import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Merkezi Analytics katmanı.
/// Tüm custom event / user property çağrıları buradan geçer.
class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      if (kDebugMode) {
        debugPrint('Analytics: $name ${parameters ?? {}}');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Analytics logEvent failed ($name): $e\n$st');
      }
    }
  }

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      if (kDebugMode) {
        debugPrint('Analytics screen: $screenName');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Analytics screenView failed ($screenName): $e\n$st');
      }
    }
  }

  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      if (kDebugMode) {
        debugPrint('Analytics userProperty: $name=$value');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Analytics setUserProperty failed ($name): $e\n$st');
      }
    }
  }

  Future<void> logDeckOpened({
    required String deckName,
    required String category,
    required bool isPremium,
    required bool isAdDeck,
  }) {
    return logEvent(
      'deck_opened',
      parameters: {
        'deck_name': _truncate(deckName),
        'category': _truncate(category),
        'is_premium': isPremium ? 1 : 0,
        'is_ad_deck': isAdDeck ? 1 : 0,
      },
    );
  }

  Future<void> logGameStarted({
    required String deckName,
    required String category,
    String source = 'deck',
  }) {
    return logEvent(
      'game_started',
      parameters: {
        'deck_name': _truncate(deckName),
        'category': _truncate(category),
        'source': source,
      },
    );
  }

  Future<void> logGameFinished({
    required String deckName,
    required String category,
    required int score,
    required int correctCount,
    required int passCount,
    required int durationSeconds,
  }) {
    return logEvent(
      'game_finished',
      parameters: {
        'deck_name': _truncate(deckName),
        'category': _truncate(category),
        'score': score,
        'correct_count': correctCount,
        'pass_count': passCount,
        'cards_played': correctCount + passCount,
        'duration_seconds': durationSeconds,
      },
    );
  }

  Future<void> logGameAbandoned({
    required String deckName,
    required String category,
    required int score,
    required int correctCount,
    required int passCount,
    required int remainingSeconds,
    required int durationSeconds,
  }) {
    return logEvent(
      'game_abandoned',
      parameters: {
        'deck_name': _truncate(deckName),
        'category': _truncate(category),
        'score': score,
        'correct_count': correctCount,
        'pass_count': passCount,
        'cards_played': correctCount + passCount,
        'remaining_seconds': remainingSeconds,
        'duration_seconds': durationSeconds,
      },
    );
  }

  /// Tüm formatlar için tek gösterim event'i (avg ads/user hesabı için).
  /// [format]: `interstitial` | `rewarded` | `banner`
  Future<void> logAdsShown({
    required String format,
    required String placement,
  }) {
    return logEvent(
      'ads_shown',
      parameters: {
        'ad_format': _truncate(format),
        'placement': _truncate(placement),
      },
    );
  }

  /// Yükleme / gösterim başarısız.
  Future<void> logAdsFailed({
    required String format,
    required String placement,
    required String reason,
  }) {
    return logEvent(
      'ads_failed',
      parameters: {
        'ad_format': _truncate(format),
        'placement': _truncate(placement),
        'reason': _truncate(reason),
      },
    );
  }

  /// Gösterildi ama tamamlanmadı (ör. rewarded ödülsüz kapatıldı).
  Future<void> logAdsIncomplete({
    required String format,
    required String placement,
    required String reason,
  }) {
    return logEvent(
      'ads_incomplete',
      parameters: {
        'ad_format': _truncate(format),
        'placement': _truncate(placement),
        'reason': _truncate(reason),
      },
    );
  }

  /// Tam ekran reklam açıkken uygulama kapatıldı / öldürüldü
  /// (bir sonraki oturumda tespit edilir).
  Future<void> logAdsClosedApp({
    required String format,
    required String placement,
  }) {
    return logEvent(
      'ads_closed_app',
      parameters: {
        'ad_format': _truncate(format),
        'placement': _truncate(placement),
      },
    );
  }

  Future<void> logRewardedAdWatched({
    required String placement,
    required bool earnedReward,
  }) {
    return logEvent(
      'rewarded_ad_watched',
      parameters: {
        'placement': _truncate(placement),
        'earned_reward': earnedReward ? 1 : 0,
      },
    );
  }

  Future<void> logRewardedAdSkipped({
    required String placement,
    required String reason,
  }) {
    return logEvent(
      'rewarded_ad_skipped',
      parameters: {
        'placement': _truncate(placement),
        'reason': _truncate(reason),
      },
    );
  }

  Future<void> logInterstitialShown({required String placement}) async {
    await logAdsShown(format: 'interstitial', placement: placement);
    await logEvent(
      'interstitial_shown',
      parameters: {'placement': _truncate(placement)},
    );
  }

  Future<void> logInterstitialFailed({
    required String placement,
    required String reason,
  }) async {
    await logAdsFailed(
      format: 'interstitial',
      placement: placement,
      reason: reason,
    );
    await logEvent(
      'interstitial_failed',
      parameters: {
        'placement': _truncate(placement),
        'reason': _truncate(reason),
      },
    );
  }

  Future<void> logPremiumViewed({String source = 'tab'}) {
    return logEvent(
      'premium_viewed',
      parameters: {'source': _truncate(source)},
    );
  }

  Future<void> logPurchaseStarted({required String productId}) {
    return logEvent(
      'purchase_started',
      parameters: {'product_id': _truncate(productId)},
    );
  }

  Future<void> logPurchaseSuccess({required String productId}) {
    return logEvent(
      'purchase_success',
      parameters: {'product_id': _truncate(productId)},
    );
  }

  Future<void> logPurchaseFailed({
    required String productId,
    required String reason,
  }) {
    return logEvent(
      'purchase_failed',
      parameters: {
        'product_id': _truncate(productId),
        'reason': _truncate(reason),
      },
    );
  }

  Future<void> logRestoreStarted() {
    return logEvent('restore_started');
  }

  Future<void> logRestoreSuccess({required String productId}) {
    return logEvent(
      'restore_success',
      parameters: {'product_id': _truncate(productId)},
    );
  }

  Future<void> logRestoreFailed({required String reason}) {
    return logEvent(
      'restore_failed',
      parameters: {'reason': _truncate(reason)},
    );
  }

  Future<void> setIsPremium(bool isPremium) {
    return setUserProperty(
      name: 'is_premium',
      value: isPremium ? 'true' : 'false',
    );
  }

  Future<void> logCardResult({
    required String deckName,
    required bool isCorrect,
  }) {
    return logEvent(
      isCorrect ? 'card_correct' : 'card_pass',
      parameters: {
        'deck_name': _truncate(deckName),
      },
    );
  }

  Future<void> logPlayAgain({
    required String deckName,
    required String category,
  }) {
    return logEvent(
      'play_again',
      parameters: {
        'deck_name': _truncate(deckName),
        'category': _truncate(category),
      },
    );
  }

  Future<void> logTimerChanged({
    required int seconds,
    required String direction,
  }) {
    return logEvent(
      'timer_changed',
      parameters: {
        'seconds': seconds,
        'direction': direction,
      },
    );
  }

  Future<void> logVipLockedTap({required String deckName}) {
    return logEvent(
      'vip_locked_tap',
      parameters: {'deck_name': _truncate(deckName)},
    );
  }

  Future<void> logDeckPlayBlocked({
    required String deckName,
    required String reason,
  }) {
    return logEvent(
      'deck_play_blocked',
      parameters: {
        'deck_name': _truncate(deckName),
        'reason': _truncate(reason),
      },
    );
  }

  Future<void> logAttResult({required String status}) {
    return logEvent(
      'att_result',
      parameters: {'status': _truncate(status)},
    );
  }

  Future<void> logRatePromptShown({required String source}) {
    return logEvent(
      'rate_prompt_shown',
      parameters: {'source': _truncate(source)},
    );
  }

  Future<void> logRatePromptAction({required String action}) {
    return logEvent(
      'rate_prompt_action',
      parameters: {'action': _truncate(action)},
    );
  }

  Future<void> logNoInternetShown() {
    return logEvent('no_internet_shown');
  }

  String _truncate(String value, [int max = 100]) {
    if (value.length <= max) return value;
    return value.substring(0, max);
  }
}
