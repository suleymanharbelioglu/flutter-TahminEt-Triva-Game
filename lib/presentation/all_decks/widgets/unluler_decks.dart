import 'package:ben_kimim/common/helper/size/size_helper.dart';
import 'package:ben_kimim/common/widget/deck/deck_cover.dart';
import 'package:ben_kimim/core/configs/theme/app_color.dart';
import 'package:ben_kimim/core/configs/theme/app_textstyle.dart';
import 'package:ben_kimim/domain/deck/entity/deck.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/unluler_decks_cubit.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/unluler_decks_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Ünlüler kategorisindeki desteleri yatay olarak listeleyen optimize edilmiş widget.
class UnlulerDecks extends StatelessWidget {
  const UnlulerDecks({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategori Başlığı
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text("ÜNLÜLER", style: AppTextstyle.allDecksBaslik),
          ),

          // Deck Yükleyici
          const _DeckContent(),
        ],
      ),
    );
  }
}

// BlocBuilder'ı içeren özel widget.
class _DeckContent extends StatelessWidget {
  const _DeckContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.allDecksBackground,
      height: SizeHelper.categoryDeckHeight(context), // MediaQuery tabanlı, dokunma!
      child: BlocBuilder<UnlulerDecksCubit, UnlulerDecksState>(
        builder: (context, state) {
          if (state is UnlulerDecksLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UnlulerDecksLoadFailure) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Text(
                  'Hata: Desteler yüklenemedi. ${state.errorMessage}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }

          if (state is UnlulerDecksLoaded) {
            return _buildDeckList(state.decks);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Destelerin yatay olarak listelendiği metot.
  Widget _buildDeckList(List<DeckEntity> deckList) {
    if (deckList.isEmpty) {
      return Center(
        child: Text(
          'Bu kategoride henüz bir deste bulunmamaktadır.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14.sp,
          ),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: SizeHelper.categoryListHorizontalPad,
      ),
      itemCount: deckList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(right: SizeHelper.categoryListGap),
          child: SizedBox(
            width: SizeHelper.categoryDeckWidth(context), // Dokunma!
            child: DeckCover(deck: deckList[index]),
          ),
        );
      },
    );
  }
}
