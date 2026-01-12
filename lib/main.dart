import 'package:ben_kimim/core/configs/theme/app_theme.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize(); // AdMob başlat
  // ✅ TEST DEVICE ID EKLE

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // varsayılan dikey
  ]);

  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("Width: ${MediaQuery.of(context).size.width}");
    print("Height: ${MediaQuery.of(context).size.height}");
    return ScreenUtilInit(
      designSize: const Size(392, 825),
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
