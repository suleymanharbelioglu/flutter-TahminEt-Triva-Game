import 'package:ben_kimim/common/navigator/app_navigator.dart';
import 'package:ben_kimim/core/ads/ads_bootstrap.dart';
import 'package:ben_kimim/core/analytics/analytics_service.dart';
import 'package:ben_kimim/core/configs/assets/app_images.dart';
import 'package:ben_kimim/presentation/bottom_nav/page/bottom_nav.dart';
import 'package:ben_kimim/presentation/game/bloc/interstitial_scheduler_cubit.dart';
import 'package:ben_kimim/presentation/splash/bloc/splash_cubit.dart';
import 'package:ben_kimim/presentation/splash/bloc/splash_state.dart';
import 'package:ben_kimim/service_locator.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'dart:io' show Platform;

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    sl<AnalyticsService>().logScreenView(screenName: 'splash');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startOnce();
    });
  }

  Future<void> _startOnce() async {
    if (_started) return;
    _started = true;

    // 1) UMP (GDPR / IDFA bilgilendirme) tamamen bitsin
    // 2) Hâlâ ATT sorulmadıysa: bilgilendirme → ATT (üst üste binmez)
    // 3) Ads init/preload
    await _handleAdMobPrivacyMessaging();
    await _waitForUiSettle();
    await _handleATTOnSplash();
    await AdsBootstrap.initializeAndPreload();
    if (!mounted) return;

    // Geçiş reklamı timer'ı / preload sadece SDK hazır olduktan sonra başlar.
    context.read<InterstitialSchedulerCubit>().onAdsSdkReady();
    context.read<SplashCubit>().startSplash(context);
  }

  /// Modal/form kapandıktan sonra bir sonraki native dialog için nefes payı.
  Future<void> _waitForUiSettle({
    Duration delay = const Duration(milliseconds: 800),
  }) async {
    await Future.delayed(delay);
    if (!mounted) return;
    final frame = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!frame.isCompleted) frame.complete();
    });
    await frame.future;
  }

  /// AdMob "Privacy & messaging" (UMP) formları: IDFA explainer dahil.
  /// Form gerekmiyorsa callback anında döner.
  Future<void> _handleAdMobPrivacyMessaging() async {
    if (kIsWeb) return;

    final completer = Completer<void>();
    try {
      final params = ConsentRequestParameters();
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          // Form gerekiyorsa göster; gerekmiyorsa anında tamamlanır.
          ConsentForm.loadAndShowConsentFormIfRequired((error) {
            if (kDebugMode && error != null) {
              debugPrint(
                'UMP loadAndShowConsentFormIfRequired failed: code=${error.errorCode} message=${error.message}',
              );
            }
            if (!completer.isCompleted) completer.complete();
          });
        },
        (error) {
          if (kDebugMode) {
            debugPrint(
              'UMP requestConsentInfoUpdate failed: code=${error.errorCode} message=${error.message}',
            );
          }
          if (!completer.isCompleted) completer.complete();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('UMP flow threw: $e');
      }
      if (!completer.isCompleted) completer.complete();
    }

    // Callback gelmezse splash sonsuza takılmasın.
    try {
      await completer.future.timeout(const Duration(seconds: 12));
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('UMP flow timed out; continuing to ATT/ads');
      }
    }
  }

  Future<void> _handleATTOnSplash() async {
    if (kIsWeb || !Platform.isIOS) return;

    TrackingStatus status;
    try {
      status = await AppTrackingTransparency.trackingAuthorizationStatus;
    } catch (_) {
      return;
    }

    // UMP IDFA akışı ATT'yi zaten sorduysa tekrar açma (üst üste binmesin).
    if (status != TrackingStatus.notDetermined) {
      if (kDebugMode) {
        debugPrint('ATT already determined: $status — skip');
      }
      sl<AnalyticsService>().logAttResult(status: status.name);
      return;
    }
    if (!mounted) return;

    // Önce uygulama içi bilgilendirme; kullanıcı kapatınca sistem ATT.
    await _showAttPrePrompt();
    if (!mounted) return;

    await _waitForUiSettle(delay: const Duration(milliseconds: 400));
    if (!mounted) return;

    // Bilgilendirme sırasında UMP/başka akış ATT sormuş olabilir.
    try {
      status = await AppTrackingTransparency.trackingAuthorizationStatus;
    } catch (_) {
      return;
    }
    if (status != TrackingStatus.notDetermined) {
      sl<AnalyticsService>().logAttResult(status: status.name);
      return;
    }

    try {
      await AppTrackingTransparency.requestTrackingAuthorization();
      final after =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      sl<AnalyticsService>().logAttResult(status: after.name);
    } catch (_) {
      // iOS 14 altı / beklenmeyen durumlarda sessizce geç.
    }
    // Tracking denied olsa da AdsBootstrap reklam yüklemeye devam eder.
  }

  /// Sistem ATT'den önce kısa bilgilendirme; üst üste binmeyi önler.
  Future<void> _showAttPrePrompt() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Takip izni'),
          content: const Text(
            'Daha ilgili reklamlar gösterebilmek ve uygulama deneyimini '
            'iyileştirmek için bir sonraki ekranda takip izni isteyeceğiz.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Devam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigate) {
          AppNavigator.pushAndRemove(context, const BottomNavPage());
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AppImages.splashBackground,
              fit: BoxFit.cover,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 100.h,
                ),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
