import 'dart:io' show Platform;

import 'package:ben_kimim/core/configs/store_urls.dart';
import 'package:ben_kimim/core/configs/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class RateAppService {
  static const _kGamesCompleted = 'rate_app_games_completed';
  static const _kLastPromptMs = 'rate_app_last_prompt_ms';
  static const _kDidRate = 'rate_app_did_rate';

  // iOS App Store Connect numeric id (örn: 1234567890)
  static const String iosAppStoreId =
      String.fromEnvironment('APPSTORE_APP_ID', defaultValue: '');

  static const int minCompletedGamesToPrompt = 3;
  static const Duration repromptAfter = Duration(days: 7);

  static Future<void> recordGameCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_kGamesCompleted) ?? 0;
    await prefs.setInt(_kGamesCompleted, current + 1);
  }

  static Future<bool> hasRated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kDidRate) == true;
  }

  static Future<bool> maybeShowRateSheet(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kDidRate) == true) return false;

    final games = prefs.getInt(_kGamesCompleted) ?? 0;
    if (games < minCompletedGamesToPrompt) return false;

    final lastMs = prefs.getInt(_kLastPromptMs);
    if (lastMs != null) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
      if (DateTime.now().difference(last) < repromptAfter) return false;
    }

    if (!context.mounted) return false;

    final didAction = await showRateSheet(context, force: false);
    return didAction;
  }

  /// force=true → sayaç/7gün kuralını bypass eder (örn: üstteki yıldız butonu).
  static Future<bool> showRateSheet(
    BuildContext context, {
    required bool force,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kDidRate) == true) return false;

    if (!force) {
      final games = prefs.getInt(_kGamesCompleted) ?? 0;
      if (games < minCompletedGamesToPrompt) return false;

      final lastMs = prefs.getInt(_kLastPromptMs);
      if (lastMs != null) {
        final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
        if (DateTime.now().difference(last) < repromptAfter) return false;
      }
    }

    if (!context.mounted) return false;

    final result = await showModalBottomSheet<_RateSheetResult>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RateAppSheet(),
    );

    if (result == null || result == _RateSheetResult.dismissed) {
      await prefs.setInt(_kLastPromptMs, DateTime.now().millisecondsSinceEpoch);
      return true;
    }

    if (result == _RateSheetResult.rated) {
      await prefs.setBool(_kDidRate, true);
      await openStoreReview(context);
      return true;
    }

    return false;
  }

  static Future<void> openStoreReview(BuildContext context) async {
    try {
      if (Platform.isIOS) {
        if (StoreUrls.iosReview.trim().isNotEmpty) {
          final uri = Uri.parse(StoreUrls.iosReview);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
        if (iosAppStoreId.trim().isEmpty) {
          _toast(context, 'App Store ID ayarlı değil.');
          return;
        }
        final uri = Uri.parse(
          'itms-apps://apps.apple.com/app/id$iosAppStoreId?action=write-review',
        );
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }

      // Android
      if (StoreUrls.android.trim().isNotEmpty) {
        final uri = Uri.parse(StoreUrls.android);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
      final info = await PackageInfo.fromPlatform();
      final packageName = info.packageName;
      final marketUri = Uri.parse('market://details?id=$packageName');
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
        return;
      }
      final webUri = Uri.parse(
        'https://play.google.com/store/apps/details?id=$packageName',
      );
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _toast(context, 'Mağaza açılamadı. Lütfen daha sonra tekrar deneyin.');
    }
  }

  static void _toast(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _RateSheetResult { rated, dismissed }

class _RateAppSheet extends StatefulWidget {
  const _RateAppSheet();

  @override
  State<_RateAppSheet> createState() => _RateAppSheetState();
}

class _RateAppSheetState extends State<_RateAppSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primary;

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.star_rounded, color: primary, size: 26),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Deneyimini puanla',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Kapat',
                    onPressed: () =>
                        Navigator.of(context).pop(_RateSheetResult.dismissed),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: primary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return IconButton(
                      onPressed: () {
                        Navigator.of(context).pop(_RateSheetResult.rated);
                      },
                      iconSize: 36,
                      splashRadius: 22,
                      icon: Icon(
                        Icons.star_outline_rounded,
                        color: const Color(0xFFFFC107),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

