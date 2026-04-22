import 'package:ben_kimim/presentation/all_decks/pages/all_decks.dart';
import 'package:ben_kimim/presentation/bottom_nav/bloc/bottom_nav_cubit.dart';
import 'package:ben_kimim/core/configs/ads/admob_ids.dart';
import 'package:ben_kimim/core/rate_app/rate_app_service.dart';
import 'package:ben_kimim/presentation/how_to_play/page/how_to_play.dart';
import 'package:ben_kimim/presentation/no_internet/bloc/internet_connection_state.dart';
import 'package:ben_kimim/presentation/no_internet/page/no_internet.dart';
import 'package:ben_kimim/presentation/premium/bloc/is_user_premium_cubit.dart';
import 'package:ben_kimim/presentation/premium/page/premium.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ben_kimim/presentation/no_internet/bloc/internet_connection_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ScreenUtil eklendi

class BottomNavPage extends StatefulWidget {
  final bool showRatePrompt;
  const BottomNavPage({super.key, this.showRatePrompt = false});

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: context.read<BottomNavCubit>().state);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      if (widget.showRatePrompt) {
        RateAppService.maybeShowRateSheet(context);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [
      PremiumPage(),
      AllDecksPage(),
      HowToPlayPage(),
    ];

    return BlocListener<InternetConnectionCubit, InternetConnectionState>(
      listener: (context, state) {
        if (state is InternetDisConnected) {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              barrierColor: Colors.black.withOpacity(0.3),
              pageBuilder: (_, __, ___) => const NoInternetPage(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        }
      },
      child: BlocBuilder<BottomNavCubit, int>(
        builder: (context, currentIndex) {
          return BlocListener<BottomNavCubit, int>(
            listener: (context, index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Scaffold(
              body: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: pages,
              ),
              bottomNavigationBar: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BottomNavigationBar(
                      backgroundColor: Colors.white,
                      currentIndex: currentIndex,
                      onTap: (index) =>
                          context.read<BottomNavCubit>().changePage(index),
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: Theme.of(context).primaryColor,
                      unselectedItemColor: Colors.grey,
                      iconSize: 28.sp, // ScreenUtil ile responsive
                      selectedFontSize: 14.sp,
                      unselectedFontSize: 13.sp,
                      items: const [
                        BottomNavigationBarItem(
                          icon: FaIcon(FontAwesomeIcons.crown),
                          label: 'VIP',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.style_outlined),
                          label: 'Desteler',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.help_outline),
                          label: 'Nasıl Oynanır',
                        ),
                      ],
                    ),
                    const BannerContainer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BannerContainer extends StatefulWidget {
  const BannerContainer({super.key});

  @override
  State<BannerContainer> createState() => _BannerContainerState();
}

class _BannerContainerState extends State<BannerContainer> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;
  AdSize? _adSize;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isPremium = context.read<IsUserPremiumCubit>().state;

      if (!isPremium) _loadBanner();
    });
  }

  Future<void> _loadBanner() async {
    final isPremium = context.read<IsUserPremiumCubit>().state;
    if (isPremium) return;
    if (_isLoading) return;
    _isLoading = true;

    _bannerAd?.dispose();
    _bannerAd = null;
    if (mounted) setState(() => _isAdLoaded = false);

    if (kDebugMode) {
      debugPrint('BannerAd(homePage) load start: adUnitId=${AdMobIds.homePageBanner}');
    }
    final int width = MediaQuery.of(context).size.width.toInt();
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      width,
    );
    if (size == null || !mounted) {
      _isLoading = false;
      if (kDebugMode) {
        debugPrint('BannerAd(homePage) size is null for width=$width');
      }
      return;
    }

    setState(() => _adSize = size);

    _bannerAd = BannerAd(
      adUnitId: AdMobIds.homePageBanner,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isLoading = false;
          if (mounted) setState(() => _isAdLoaded = true);
          if (kDebugMode) {
            debugPrint(
              'BannerAd(homePage) loaded: size=${size.width}x${size.height}',
            );
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isLoading = false;
          if (mounted) setState(() => _isAdLoaded = false);
          if (kDebugMode) {
            debugPrint(
              'BannerAd(homePage) failed: code=${error.code} domain=${error.domain} message=${error.message}',
            );
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<IsUserPremiumCubit>().state;

    if (isPremium) return const SizedBox.shrink();

    return BlocListener<InternetConnectionCubit, InternetConnectionState>(
      listener: (context, state) {
        if (state is InternetConnected && !isPremium) {
          // If it's not visible/loaded yet, retry when connection returns.
          if (!_isAdLoaded) _loadBanner();
        }
      },
      child: _isAdLoaded && _bannerAd != null && _adSize != null
          ? SizedBox(
              width: MediaQuery.of(context).size.width,
              height: _adSize!.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : const SizedBox.shrink(),
    );
  }
}
