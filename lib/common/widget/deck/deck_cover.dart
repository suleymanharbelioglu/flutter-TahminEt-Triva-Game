import 'package:ben_kimim/common/widget/ads/ad_watch_icon.dart';
import 'package:ben_kimim/common/helper/sound/sound.dart';
import 'package:ben_kimim/common/widget/deck/deck_flip.dart';
import 'package:ben_kimim/presentation/bottom_nav/bloc/bottom_nav_cubit.dart';
import 'package:ben_kimim/presentation/game/bloc/deck_play_credits_cubit.dart';
import 'package:ben_kimim/presentation/premium/bloc/is_user_premium_cubit.dart';
import 'package:flutter/material.dart';
import 'package:ben_kimim/domain/deck/entity/deck.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeckCover extends StatelessWidget {
  final DeckEntity deck;
  const DeckCover({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await precacheImage(AssetImage(deck.onGorselAdress), context);
        await precacheImage(AssetImage(deck.arkaGorselAdress), context);
        if (!context.mounted) return;

        await SoundHelper.playClick();
        if (!context.mounted) return;

        final bottomNavCubit = context.read<BottomNavCubit>();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => BlocProvider.value(
              value: bottomNavCubit,
              child: DeckFlip(deck: deck),
            ),
            opaque: false,
            barrierColor: const Color(0x4D000000),
          ),
        );
      },
      child: Container(
        // color: Colors.pink,
        child: Stack(
          children: [
            Hero(
              tag: "image_${deck.deckName}",
              child: _HeroImageWrapper(
                imagePath: deck.onGorselAdress,
              ),
            ),
            Positioned(
              top: 8.h,
              left: 0,
              right: 0,
              child: Hero(
                tag: "title_${deck.deckName}",
                child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child: Stack(
                      children: [
                        Text(
                          deck.deckName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2.sp
                              ..color = Colors.black,
                          ),
                        ),
                        Text(
                          deck.deckName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.sp,
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
                return BlocBuilder<DeckPlayCreditsCubit, Map<String, int>>(
                  builder: (context, credits) {
                    if (userIsPremium) return const SizedBox.shrink();

                    if (deck.isPremium) {
                      return Positioned(
                        right: 8.h,
                        bottom: 8.h,
                        child: Hero(
                          tag: "lock_${deck.deckName}",
                          child: Container(
                            width: 36.h,
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 20.h,
                            ),
                          ),
                        ),
                      );
                    }

                    if (deck.isAdDeck && (credits[deck.deckName] ?? 0) <= 0) {
                      return Positioned(
                        right: 8.h,
                        bottom: 8.h,
                        child: Hero(
                          tag: "ad_${deck.deckName}",
                          child: AdWatchIconBadge(size: 36.h, iconSize: 22.h),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroImageWrapper extends StatelessWidget {
  final String imagePath;
  const _HeroImageWrapper({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: SizedBox.expand(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
