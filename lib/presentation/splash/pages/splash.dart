import 'package:ben_kimim/common/navigator/app_navigator.dart';
import 'package:ben_kimim/core/ads/ads_bootstrap.dart';
import 'package:ben_kimim/core/configs/assets/app_images.dart';
import 'package:ben_kimim/presentation/bottom_nav/page/bottom_nav.dart';
import 'package:ben_kimim/presentation/splash/bloc/splash_cubit.dart';
import 'package:ben_kimim/presentation/splash/bloc/splash_state.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startOnce();
    });
  }

  Future<void> _startOnce() async {
    if (_started) return;
    _started = true;

    // 1) UMP → 2) ATT → 3) Ads init/preload (ATT reddedilse bile reklam yüklenir)
    await _handleAdMobPrivacyMessaging();
    await _handleATTOnSplash();
    await AdsBootstrap.initializeAndPreload();
    if (!mounted) return;

    context.read<SplashCubit>().startSplash(context);
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

    if (status != TrackingStatus.notDetermined) return;
    if (!mounted) return;

    // UMP modalı kapandıktan hemen sonra ATT bazen görünmez; kısa gecikme.
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    try {
      await AppTrackingTransparency.requestTrackingAuthorization();
    } catch (_) {
      // iOS 14 altı / beklenmeyen durumlarda sessizce geç.
    }
    // Tracking denied olsa da AdsBootstrap reklam yüklemeye devam eder.
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
