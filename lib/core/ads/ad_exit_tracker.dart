import 'package:ben_kimim/core/analytics/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tam ekran reklam açıkken uygulama öldürülürse bir sonraki açılışta event atar.
///
/// Reklam show → bayrak set; dismiss/fail → bayrak temizlenir.
/// Bayrak hâlâ duruyorsa kullanıcı reklam sırasında uygulamayı kapatmış demektir.
class AdExitTracker {
  AdExitTracker._();

  static const _activeKey = 'ad_exit_in_progress';
  static const _formatKey = 'ad_exit_format';
  static const _placementKey = 'ad_exit_placement';

  static Future<void> markShowing({
    required String format,
    required String placement,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_activeKey, true);
    await prefs.setString(_formatKey, format);
    await prefs.setString(_placementKey, placement);
  }

  static Future<void> markFinished() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeKey);
    await prefs.remove(_formatKey);
    await prefs.remove(_placementKey);
  }

  /// Uygulama açılışında bir kez çağır.
  static Future<void> flushIfNeeded(AnalyticsService analytics) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_activeKey) != true) return;

    final format = prefs.getString(_formatKey) ?? 'unknown';
    final placement = prefs.getString(_placementKey) ?? 'unknown';
    await markFinished();
    await analytics.logAdsClosedApp(
      format: format,
      placement: placement,
    );
  }
}
