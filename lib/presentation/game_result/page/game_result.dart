import 'package:ben_kimim/common/navigator/app_navigator.dart';
import 'package:ben_kimim/core/configs/ads/admob_ids.dart';
import 'package:ben_kimim/core/configs/theme/app_color.dart';
import 'package:ben_kimim/data/card/model/card_result.dart';
import 'package:ben_kimim/presentation/bottom_nav/page/bottom_nav.dart';
import 'package:ben_kimim/presentation/game/bloc/current_name_cubit.dart';
import 'package:ben_kimim/presentation/game/bloc/score_cubit.dart';
import 'package:ben_kimim/presentation/game_result/bloc/result_cubit.dart';
import 'package:ben_kimim/presentation/no_internet/page/no_internet.dart';
import 'package:ben_kimim/presentation/phone_to_forhead/page/phone_to_forhead.dart';
import 'package:ben_kimim/presentation/no_internet/bloc/internet_connection_cubit.dart';
import 'package:ben_kimim/presentation/no_internet/bloc/internet_connection_state.dart';
import 'package:ben_kimim/presentation/premium/bloc/is_user_premium_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GameResultPage extends StatefulWidget {
  const GameResultPage({super.key});

  @override
  State<GameResultPage> createState() => _GameResultPageState();
}

class _GameResultPageState extends State<GameResultPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0.0;
  double _scrollMax = 1.0;

  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _scrollController.addListener(_onScroll);

    if (kDebugMode) {
      // Debug modda test cihazı
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: ["D09DE3465F0FF17A7C7AA0997E40DFCA"],
        ),
      );
    }

    // Interstitial yükle
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInterstitial());
  }

  Widget _withInternetListener(Widget child) {
    return BlocListener<InternetConnectionCubit, InternetConnectionState>(
      listener: (context, state) {
        if (state is InternetDisConnected) {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              barrierColor: Colors.black.withOpacity(0.3),
              pageBuilder: (_, __, ___) => const NoInternetPage(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      },
      child: child,
    );
  }

  void _loadInterstitial() {
    if (context.read<IsUserPremiumCubit>().state) return;
    final adUnitId = AdMobIds.playAgainInterstitial;
    if (adUnitId.isEmpty) return;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdReady = true;
          _interstitialAd?.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _navigateToGamePage();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _navigateToGamePage();
            },
          );
        },
        onAdFailedToLoad: (_) => _isAdReady = false,
      ),
    );
  }

  Future<void> _showInterstitialThenNavigate() async {
    if (context.read<IsUserPremiumCubit>().state) {
      return _navigateToGamePage();
    }

    int attempts = 0;
    while (_interstitialAd == null && attempts < 20) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    if (_isAdReady)
      _interstitialAd?.show();
    else
      _navigateToGamePage();
  }

  void _navigateToGamePage() =>
      AppNavigator.pushReplacement(context, PhoneToForeheadPage());

  void _navigateToHome(BuildContext context) {
    _resetCubits(context);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const BottomNavPage()));
  }

  void _resetCubits(BuildContext context) {
    context.read<CurrentNameCubit>().reset();
    context.read<ScoreCubit>().reset();
    context.read<ResultCubit>().reset();
  }

  Future<void> _onPlayAgainPressed(BuildContext context) async {
    await _showInterstitialThenNavigate();
    if (mounted) _resetCubits(context);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    setState(() {
      _scrollPosition = _scrollController.offset;
      _scrollMax = _scrollController.position.maxScrollExtent == 0
          ? 1
          : _scrollController.position.maxScrollExtent;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToHome(context);
        return false;
      },
      child: _withInternetListener(
        Scaffold(
          backgroundColor: AppColors.primary,
          body: SafeArea(
            child: BlocBuilder<ResultCubit, List<CardResultModel>>(
              builder: (context, resultList) {
                final correctCount =
                    resultList.where((r) => r.isCorrect).length;
                return Column(
                  children: [
                    _buildTopBar(context),
                    _buildHeader(correctCount),
                    SizedBox(height: 8.h),
                    Expanded(child: _buildScrollableResultList(resultList)),
                    _buildPlayAgainButton(context),
                    // BURAYA BANNER EKLENDİ
                    const BannerContainer(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 12.h),
      color: AppColors.primary,
      child: Row(
        children: [
          IconButton(
            onPressed: () => _navigateToHome(context),
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 28.sp),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHeader(int correctCount) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        "Toplam $correctCount kelime bildin!",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white, fontSize: 26.sp, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildScrollableResultList(List<CardResultModel> resultList) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackHeight = constraints.maxHeight;
        final thumbHeight =
            trackHeight * (trackHeight / (_scrollMax + trackHeight));
        final thumbTop =
            (_scrollPosition / _scrollMax) * (trackHeight - thumbHeight);

        return Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              itemCount: resultList.length,
              itemBuilder: (context, index) =>
                  _ResultListItem(result: resultList[index]),
            ),
            Positioned(
              right: 10.w,
              top: thumbTop.isNaN ? 0 : thumbTop,
              child: Container(
                width: 3.w,
                height: thumbHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayAgainButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: SizedBox(
        height: 56.h,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _onPlayAgainPressed(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
          ),
          child: Text(
            "Tekrar Oyna",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _ResultListItem extends StatelessWidget {
  final CardResultModel result;
  const _ResultListItem({required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Center(
        child: Text(
          result.word,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30.sp,
            fontWeight: result.isCorrect ? FontWeight.w900 : FontWeight.w600,
            color: result.isCorrect ? Colors.white : Colors.black87,
          ),
        ),
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final internetState = context.read<InternetConnectionCubit>().state;

      if (internetState is InternetConnected) {
        _loadBanner();
      }
    });
  }

  Future<void> _loadBanner() async {
    if (!mounted) return;
    if (context.read<IsUserPremiumCubit>().state) return;

    _bannerAd?.dispose();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

// Küçük olanı al
    final int width =
        (screenWidth < screenHeight ? screenWidth : screenHeight).toInt();
    // 🔥 getAnchoredAdaptiveBannerAdSize entegrasyonu
    AdSize? size = await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait, // Çünkü uygulaman portrait locked
      width,
    );

    if (size == null) {
      return;
    }

    final BannerAd banner = BannerAd(
      adUnitId: AdMobIds.gameResultBanner,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _bannerAd = ad as BannerAd;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );

    await banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InternetConnectionCubit, InternetConnectionState>(
      listener: (context, state) {
        if (state is InternetConnected) {
          _loadBanner();
        }
      },
      child: _isAdLoaded && _bannerAd != null
          ? Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
