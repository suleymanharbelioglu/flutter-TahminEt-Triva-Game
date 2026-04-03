import 'package:ben_kimim/common/helper/size/size_helper.dart';
import 'package:ben_kimim/common/widget/deck/deck_cover.dart';
import 'package:ben_kimim/domain/deck/entity/deck.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/popular_decks_cubit.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/popular_decks_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopularDecks extends StatelessWidget {
  const PopularDecks({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: BlocBuilder<PopularDecksCubit, PopularDecksState>(
        builder: (context, state) {
          if (state is PopularDecksLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }

          if (state is PopularDecksLoaded) {
            return _buildDeckList(context, state.decks);
          }

          if (state is PopularDecksLoadFailure) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Text(
                  "Desteler yüklenirken hata oluştu: ${state.errorMessage}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDeckList(BuildContext context, List<DeckEntity> deckList) {
    if (deckList.isEmpty) {
      return Center(
        child: Text(
          'Popüler deste bulunmamaktadır.',
          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
        ),
      );
    }

    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeHelper.categoryListHorizontalPad,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          // Tablet: daha alçak oran = hücre daha uzun = kartlar daha büyük görünür.
          childAspectRatio: isTablet ? 0.52 : 0.6,
        ),
        itemCount: deckList.length,
        itemBuilder: (context, index) {
          return DeckCover(deck: deckList[index]);
        },
      ),
    );
  }
}
