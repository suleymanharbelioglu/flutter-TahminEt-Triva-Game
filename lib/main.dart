import 'package:ben_kimim/core/configs/theme/app_theme.dart';
import 'package:ben_kimim/core/configs/revenuecat/revenuecat_config.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/bilim_ve_genelk_decks_cubit.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/canlandir_decks_cubit.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/ciz_decks_cubit.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/cizgifilm_anime_decks_cubit.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/dizi_film_decks_cubit.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/gunluk_yasam_decks_cubit.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/muzik_decks_cubit.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/popular_decks_cubit.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/spor_decks_cubit.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/unluler_decks_cubit.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/yemeker_decks_cubit.dart';
import 'package:ben_kimim/presentation/bottom_nav/bloc/bottom_nav_cubit.dart';
import 'package:ben_kimim/presentation/game/bloc/current_name_cubit.dart';
import 'package:ben_kimim/presentation/game/bloc/display_current_card_list_cubit.dart';
import 'package:ben_kimim/presentation/game/bloc/game_interstitial_counter_cubit.dart';
import 'package:ben_kimim/presentation/game/bloc/score_cubit.dart';
import 'package:ben_kimim/presentation/game/bloc/timer_cubit.dart';
import 'package:ben_kimim/presentation/game_result/bloc/result_cubit.dart';
import 'package:ben_kimim/presentation/no_internet/bloc/internet_connection_cubit.dart';
import 'package:ben_kimim/presentation/premium/bloc/ads_counter_cubit.dart';
import 'package:ben_kimim/presentation/premium/bloc/is_user_premium_cubit.dart';
import 'package:ben_kimim/presentation/premium/bloc/premium_status_cubit.dart';
import 'package:ben_kimim/presentation/premium/bloc/purchase_cubit.dart';
import 'package:ben_kimim/presentation/premium/bloc/unlock_premium.dart';
import 'package:ben_kimim/presentation/splash/bloc/splash_cubit.dart';
import 'package:ben_kimim/presentation/splash/pages/splash.dart';
import 'package:ben_kimim/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'dart:io' show Platform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // RevenueCat init (API key'ler dart-define ile verilir)
  if (RevenueCatConfig.isConfigured) {
    if (kDebugMode) {
      await Purchases.setLogLevel(LogLevel.debug);
      final key = RevenueCatConfig.apiKey;
      final prefix = key.length >= 5 ? key.substring(0, 5) : key;
      debugPrint(
        'RevenueCat configure: keyPrefix=$prefix keyLen=${key.length} platform=$defaultTargetPlatform',
      );
    }
    await Purchases.configure(
      PurchasesConfiguration(RevenueCatConfig.apiKey)..appUserID = null,
    );
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // varsayılan dikey
  ]);

  await initializeDependencies();

  // AdMob: runApp öncesi await — aksi halde ilk interstitial/banner yükleme sıklıkla başarısız olur.
  try {
    await MobileAds.instance.initialize();
  } catch (e, st) {
    debugPrint('MobileAds.initialize failed: $e\n$st');
  }

  runApp(const MyApp());

  // iOS ATT (Tracking izni): ilk açılışta bir kez sorulur.
  // Not: İzin verilmezse reklamlar yine gösterilebilir, sadece kişiselleştirme etkilenir.
  _requestATTIfNeeded();
}

Future<void> _requestATTIfNeeded() async {
  if (kIsWeb || !Platform.isIOS) return;
  try {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  } catch (_) {
    // iOS 14 altı / beklenmeyen durumlarda sessizce geç.
  }
}

/// Telefon için dar tasarım; tablet/iPad için [designSize] küçüldükçe
/// [ScreenUtil] `.sp` ölçeği artar — yazılar büyür.
Size _responsiveDesignSize() {
  final views = WidgetsBinding.instance.platformDispatcher.views;
  if (views.isEmpty) return const Size(392, 825);
  final view = views.first;
  final logical = view.physicalSize / view.devicePixelRatio;
  final shortest =
      logical.width < logical.height ? logical.width : logical.height;
  if (shortest >= 600) {
    return const Size(600, 800);
  }
  return const Size(392, 825);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: _responsiveDesignSize(),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => PremiumStatusCubit()),
            BlocProvider(create: (context) => UnlockPremiumCubit()),
            BlocProvider(create: (context) => SplashCubit()),
            BlocProvider(create: (context) => TimerCubit()),
            BlocProvider(create: (context) => DisplayCurrentCardListCubit()),
            BlocProvider(create: (context) => ScoreCubit()),
            BlocProvider(create: (context) => ResultCubit()),
            BlocProvider(
              create: (context) => CurrentNameCubit(
                context.read<DisplayCurrentCardListCubit>(),
              ),
            ),
            BlocProvider(create: (context) => PopularDecksCubit()),
            BlocProvider(create: (context) => MuzikDecksCubit()),
            BlocProvider(create: (context) => SporDecksCubit()),
            BlocProvider(create: (context) => DiziFilmDecksCubit()),
            BlocProvider(create: (context) => CanlandirDecksCubit()),
            BlocProvider(create: (context) => GunlukYasamDecksCubit()),
            BlocProvider(create: (context) => BilimVeGenelKDecksCubit()),
            BlocProvider(create: (context) => CizDecksCubit()),
            BlocProvider(create: (context) => UnlulerDecksCubit()),
            BlocProvider(create: (context) => YemeklerDecksCubit()),
            BlocProvider(create: (context) => CizgiFilmAnimeDecksCubit()),
            BlocProvider(
              create: (context) => IsUserPremiumCubit(
                context.read<PremiumStatusCubit>(),
                context.read<UnlockPremiumCubit>(),
              ),
            ),
            BlocProvider(create: (context) => BottomNavCubit()),
            BlocProvider(create: (context) => InternetConnectionCubit()),
            BlocProvider(create: (context) => PurchaseCubit()),
            BlocProvider(create: (context) => AdsCounterCubit()),
            BlocProvider(create: (context) => GameInterstitialCounterCubit()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.appTheme,
            title: 'Tahmin Et',
            home: SplashPage(),
          ),
        );
      },
    );
  }
}
