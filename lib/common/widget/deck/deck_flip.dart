import 'dart:async';
import 'dart:math';
import 'package:ben_kimim/common/navigator/app_navigator.dart';
import 'package:ben_kimim/core/ads/interstitial_ad_cache.dart';
import 'package:ben_kimim/core/configs/ads/admob_ids.dart';
import 'package:ben_kimim/core/configs/theme/app_color.dart';
import 'package:ben_kimim/presentation/bottom_nav/bloc/bottom_nav_cubit.dart';
import 'package:ben_kimim/presentation/game/bloc/display_current_card_list_cubit.dart';
import 'package:ben_kimim/presentation/game/bloc/timer_cubit.dart';
import 'package:ben_kimim/presentation/phone_to_forhead/page/phone_to_forhead.dart';
import 'package:ben_kimim/presentation/premium/bloc/is_user_premium_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ben_kimim/domain/deck/entity/deck.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _initAnimation();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _autoFlip();
    // Preload: kullanıcıyı bekletmeyelim. Hazırsa anında gösteririz.
    AppInterstitials.gameStart.preload(AdMobIds.gameStartInterstitial);
  }

  Future<void> _startGameWithInterstitialPolicy() async {
    if (context.read<IsUserPremiumCubit>().state) {
      _navigateToGamePage();
      return;
    }

    // Interstitial artık oyun başlangıcında gösterilmiyor.
    // Oyun bittikten sonra Result sayfasında değerlendirilecek.
    _navigateToGamePage();
  }

  void _navigateToGamePage() {
    AppNavigator.push(context, PhoneToForeheadPage());
  }

  @override
  void dispose() {
    _controller.dispose();
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

  bool _isTabletLayout(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= 600;

  /// Süre (+/-) satırı: tablette daha büyük; üstteki sabit 160×35 px hatası kaldırıldı.
  Widget _buildTimerStepper() {
    final tablet = _isTabletLayout(context);
    final btn = tablet ? 48.h : 50.h;
    final barW = tablet ? 210.h : 200.h;
    final barH = btn;
    final r = barH / 2;

    return BlocBuilder<TimerCubit, int>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            top: tablet ? 4.h : 20.h,
            bottom: tablet ? 8.h : 20.h,
          ),
          child: Center(
            child: Container(
              width: barW,
              height: barH,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: btn,
                    height: btn,
                    decoration: BoxDecoration(
                      color: const Color(0xFF339CFF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(r),
                        bottomLeft: Radius.circular(r),
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                      onPressed: () =>
                          context.read<TimerCubit>().decrease(),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "${state}s",
                        style: TextStyle(
                          fontSize: tablet ? 24.sp : 22.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF339CFF),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: btn,
                    height: btn,
                    decoration: BoxDecoration(
                      color: const Color(0xFF339CFF),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(r),
                        bottomRight: Radius.circular(r),
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                      onPressed: () =>
                          context.read<TimerCubit>().increase(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildBackCard() {
    final descSize = _isTabletLayout(context) ? 22.sp : 20.sp;
    final titleSize = _isTabletLayout(context) ? 34.sp : 32.sp;
    final isTablet = _isTabletLayout(context);

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: _buildCard(
        widget.deck.arkaGorselAdress,
        Column(
          // Tablet: üste hizala; aksi halde başlık ile metin arasında dev boşluk oluşuyor.
          mainAxisAlignment:
              isTablet ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: isTablet ? 12.h : 20.h),
              child: Stack(
                children: [
                  Text(
                    widget.deck.deckName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleSize,
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
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isTablet ? 14.h : 16.h),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          mainAxisAlignment: isTablet
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Text(
                                  widget.deck.deckDescription,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: descSize,
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
                                    fontSize: descSize,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isTablet ? 14.h : 20.h),
                            BlocBuilder<IsUserPremiumCubit, bool>(
                              builder: (context, userIsPremium) {
                                if (widget.deck.isPremium && !userIsPremium) {
                                  return const SizedBox.shrink();
                                }
                                return _buildTimerStepper();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: isTablet ? 8.h : 12.h),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String imagePath, Widget? child) {
    final mq = MediaQuery.sizeOf(context);
    final isTablet = mq.shortestSide >= 600;
    // Telefon: %90 genişlik; tablet/iPad: biraz daha küçük kart (çevirme sonrası daha dengeli).
    final widthFactor = isTablet ? 0.76 : 0.9;
    final cardWidth = mq.width * widthFactor;
    final cardHeight = cardWidth * (1.5 / 0.9);

    return Container(
      width: cardWidth,
      height: cardHeight,
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
                    await _startGameWithInterstitialPolicy();
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
