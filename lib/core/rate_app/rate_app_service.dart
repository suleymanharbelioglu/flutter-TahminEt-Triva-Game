import 'package:ben_kimim/domain/rate_app/repository/rate_app_repository.dart';
import 'package:ben_kimim/domain/rate_app/usecase/rate_app_usecases.dart';
import 'package:ben_kimim/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ben_kimim/core/analytics/analytics_service.dart';
import 'package:ben_kimim/core/configs/store_urls.dart';
import 'package:ben_kimim/core/configs/theme/app_color.dart';
import 'dart:io' show Platform;

/// Presentation facade: eligibility usecase + UI sheet / store launch.
class RateAppService {
  static const String iosAppStoreId =
      String.fromEnvironment('APPSTORE_APP_ID', defaultValue: '');

  static Future<void> recordGameCompleted() {
    return sl<RecordGameCompletedUseCase>().call();
  }

  static Future<bool> hasRated() {
    return sl<RateAppRepository>().hasRated();
  }

  static Future<bool> maybeShowRateSheet(BuildContext context) async {
    final should = await sl<ShouldShowRatePromptUseCase>().call(params: false);
    if (!should) return false;
    if (!context.mounted) return false;
    return showRateSheet(context, force: false);
  }

  static Future<bool> showRateSheet(
    BuildContext context, {
    required bool force,
  }) async {
    final should = await sl<ShouldShowRatePromptUseCase>().call(params: force);
    if (!should) return false;
    if (!context.mounted) return false;

    sl<AnalyticsService>().logRatePromptShown(
      source: force ? 'manual' : 'auto',
    );

    final result = await showModalBottomSheet<_RateSheetResult>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RateAppSheet(),
    );

    if (result == null || result == _RateSheetResult.dismissed) {
      sl<AnalyticsService>().logRatePromptAction(action: 'dismissed');
      await sl<MarkRatePromptDismissedUseCase>().call();
      return true;
    }

    if (result == _RateSheetResult.rated) {
      sl<AnalyticsService>().logRatePromptAction(action: 'rated');
      await sl<MarkAppRatedUseCase>().call();
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

class _RateAppSheet extends StatelessWidget {
  const _RateAppSheet();

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
                      icon: const Icon(
                        Icons.star_outline_rounded,
                        color: Color(0xFFFFC107),
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
