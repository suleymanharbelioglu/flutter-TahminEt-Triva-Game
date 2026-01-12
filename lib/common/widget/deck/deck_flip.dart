import 'dart:math';
import 'package:ben_kimim/common/navigator/app_navigator.dart';
import 'package:ben_kimim/core/configs/theme/app_color.dart';
import 'package:ben_kimim/presentation/bottom_nav/bloc/bottom_nav_cubit.dart';
import 'package:ben_kimim/presentation/game/bloc/display_current_card_list_cubit.dart';
import 'package:ben_kimim/presentation/game/bloc/timer_cubit.dart';
import 'package:ben_kimim/presentation/phone_to_forhead/page/phone_to_forhead.dart';
import 'package:ben_kimim/presentation/premium/bloc/ads_counter_cubit.dart';
import 'package:ben_kimim/presentation/premium/bloc/is_user_premium_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ben_kimim/domain/deck/entity/deck.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class DeckFlip extends StatefulWidget {
  final DeckEntity deck;
  const DeckFlip({super.key, required this.deck});

  @override
  State<DeckFlip> createState() => _DeckFlipState();
}

class _DeckFlipState extends State<DeckFlip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnim;
  bool isFront = true;
  bool canTap = false;

  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _autoFlip();
    _loadInterstitial();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-6970688308215711/3866393700', // Test ID
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
        onAdFailedToLoad: (error) {
          _isAdReady = false;
          print("Interstitial failed to load: $error");
        },
      ),
    );
  }

  Future<void> _showInterstitialThenNavigate() async {
    context.read<AdsCounterCubit>().next();
    if (context.read<IsUserPremiumCubit>().state ||
        context.read<AdsCounterCubit>().state == false) {
      _navigateToGamePage();
      return;
    }

    // Reklam yüklenene kadar bekle
    int attempts = 0;
    while (_interstitialAd == null && attempts < 20) {
      // max 5 saniye bekle
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    if (_interstitialAd != null && _isAdReady) {
      _interstitialAd?.show();
    } else {
      _navigateToGamePage();
    }
  }

  void _navigateToGamePage() {
    AppNavigator.push(context, PhoneToForeheadPage());
  }

  @override
  void dispose() {
    _controller.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackAction,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.2),
        body: Stack(
          children: [
            Center(
              child: AnimatedBuilder(
                animation: _flipAnim,
                builder: (context, child) {
                  final isBack = _flipAnim.value > pi / 2;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_flipAnim.value),
                    child: isBack ? buildBackCard() : buildFrontCard(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFrontCard() {
    return Stack(
      children: [
        Hero(
          tag: "image_${widget.deck.deckName}",
          child: _buildCard(widget.deck.onGorselAdress, null),
        ),
        Positioned(
          top: 20.h,
          left: 0,
          right: 0,
          child: Hero(
            tag: "title_${widget.deck.deckName}",
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Stack(
                  children: [
                    Text(
                      widget.deck.deckName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 4.sp
                          ..color = Colors.black,
                      ),
                    ),
                    Text(
                      widget.deck.deckName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        BlocBuilder<IsUserPremiumCubit, bool>(
          builder: (context, userIsPremium) {
            // Kilit gösterme koşulları
            if (!widget.deck.isPremium ||
                (widget.deck.isPremium && userIsPremium)) {
              return const SizedBox.shrink();
            }

            // Kilit gösterilecek durum: deck premium ve kullanıcı premium değil
            return Positioned(
              right: 8,
              bottom: 8,
              child: Hero(
                tag: "lock_${widget.deck.deckName}",
                child: Container(
                  width: 72.h,
                  height: 72.h,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 40.h,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildBackCard() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: _buildCard(
        widget.deck.arkaGorselAdress,
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20.h),
              child: Stack(
                children: [
                  Text(
                    widget.deck.deckName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 4.sp
                        ..color = Colors.black,
                    ),
                  ),
                  Text(
                    widget.deck.deckName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Text(
                          widget.deck.deckDescription,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 3.sp
                              ..color = Colors.black,
                          ),
                        ),
                        Text(
                          widget.deck.deckDescription,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    BlocBuilder<IsUserPremiumCubit, bool>(
                      builder: (context, userIsPremium) {
                        // Eğer deck premium değilse Timer göster
                        if (!widget.deck.isPremium) {
                          return BlocBuilder<TimerCubit, int>(
                            builder: (context, state) {
                              return Padding(
                                padding:
                                    EdgeInsets.only(top: 40.h, bottom: 30.h),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                    child: Container(
                                      width: 160,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(25.r),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: 50.h,
                                            height: 50.h,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF339CFF),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(25.r),
                                                bottomLeft:
                                                    Radius.circular(25.r),
                                              ),
                                            ),
                                            child: IconButton(
                                              icon: Icon(Icons.remove,
                                                  color: Colors.white,
                                                  size: 24.sp),
                                              onPressed: () => context
                                                  .read<TimerCubit>()
                                                  .decrease(),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                "${state}s",
                                                style: TextStyle(
                                                  fontSize: 22.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF339CFF),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 50.h,
                                            height: 50.h,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF339CFF),
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(25.r),
                                                bottomRight:
                                                    Radius.circular(25.r),
                                              ),
                                            ),
                                            child: IconButton(
                                              icon: Icon(Icons.add,
                                                  color: Colors.white,
                                                  size: 24.sp),
                                              onPressed: () => context
                                                  .read<TimerCubit>()
                                                  .increase(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        // Deck premium ve kullanıcı premium değilse Timer yok
                        if (widget.deck.isPremium && !userIsPremium) {
                          return const SizedBox.shrink();
                        }

                        // Deck premium ve kullanıcı premium ise Timer göster
                        return BlocBuilder<TimerCubit, int>(
                          builder: (context, state) {
                            return Padding(
                              padding: EdgeInsets.only(top: 40.h, bottom: 30.h),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Container(
                                    width: 160.h,
                                    height: 35.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25.r),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 50.h,
                                          height: 50.h,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF339CFF),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(25.r),
                                              bottomLeft: Radius.circular(25.r),
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.remove,
                                                color: Colors.white,
                                                size: 24.sp),
                                            onPressed: () => context
                                                .read<TimerCubit>()
                                                .decrease(),
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              "${state}s",
                                              style: TextStyle(
                                                fontSize: 22.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF339CFF),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 50.h,
                                          height: 50.h,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF339CFF),
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(25.r),
                                              bottomRight:
                                                  Radius.circular(25.r),
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.add,
                                                color: Colors.white,
                                                size: 24.sp),
                                            onPressed: () => context
                                                .read<TimerCubit>()
                                                .increase(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String imagePath, Widget? child) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.width * 1.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 20)],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            gaplessPlayback: true,
          ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Geri buton
          GestureDetector(
            onTap: _flipBackAndClose,
            child: BlocBuilder<IsUserPremiumCubit, bool>(
              builder: (context, userIsPremium) {
                Color backgroundColor;

                // deck.isPremium false → mavi
                // deck.isPremium true & userIsPremium false → yeşil
                // diğer durumlar → mavi
                if (!widget.deck.isPremium ||
                    (widget.deck.isPremium && userIsPremium)) {
                  backgroundColor = AppColors.primary; // mavi
                } else {
                  backgroundColor = const Color(0xFF28A745); // yeşil
                }

                return CustomPaint(
                  painter:
                      _ArrowBackgroundPainter(backgroundColor: backgroundColor),
                  child: SizedBox(
                    width: 60.h,
                    height: 45.h,
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, // ok hep beyaz
                        size: 20.sp,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Oyna / VIP butonu
          BlocBuilder<IsUserPremiumCubit, bool>(
            builder: (context, userIsPremium) {
              bool showVIP = widget.deck.isPremium && !userIsPremium;
              Color gradientStart =
                  showVIP ? const Color(0xFF28A745) : const Color(0xFF007BFF);
              Color gradientEnd =
                  showVIP ? const Color(0xFF2ECC71) : const Color(0xFF339CFF);

              return GestureDetector(
                onTap: () async {
                  if (showVIP) {
                    final cubit = context.read<BottomNavCubit>();

                    Navigator.of(context).pop();

                    await Future.delayed(const Duration(milliseconds: 300));

// artık context silinmiş olsa bile sorun yok
                    cubit.changePage(0);
                  } else {
                    await context
                        .read<DisplayCurrentCardListCubit>()
                        .loadCardNames(widget.deck.namesFilePath);
                    await _showInterstitialThenNavigate();
                  }
                },
                child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [gradientStart, gradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white, width: 2.sp),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (showVIP ? Colors.greenAccent : Colors.blueAccent)
                                  .withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          showVIP ? "VIP Satın Al" : "Oyna!",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (showVIP) const SizedBox(width: 6),
                        if (showVIP)
                          FaIcon(
                            FontAwesomeIcons.crown,
                            color: Colors.yellow,
                            size: 20.sp,
                          ),
                      ],
                    )),
              );
            },
          ),
        ],
      ),
    );
  }

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _flipAnim = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  Future<void> _autoFlip() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      await _controller.forward();
      setState(() {
        isFront = false;
        canTap = true;
      });
    }
  }

  Future<void> _flipBackAndClose() async {
    if (!canTap) return;
    setState(() => canTap = false);
    if (!isFront) {
      await _controller.reverse();
      isFront = true;
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<bool> _handleBackAction() async {
    await _flipBackAndClose();
    return false;
  }
}

class _ArrowBackgroundPainter extends CustomPainter {
  final Color backgroundColor;
  _ArrowBackgroundPainter({this.backgroundColor = AppColors.primary});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor.withOpacity(0.5) // sadece arka plan rengi
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width * 0.25, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width * 0.75, size.height / 2);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * 0.25, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
