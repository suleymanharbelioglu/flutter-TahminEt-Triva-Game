import 'package:ben_kimim/common/helper/size/size_helper.dart';
import 'package:ben_kimim/common/widget/deck/deck_cover.dart';
import 'package:ben_kimim/core/configs/theme/app_color.dart';
import 'package:ben_kimim/core/configs/theme/app_textstyle.dart';
import 'package:ben_kimim/domain/deck/entity/deck.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/ciz_decks_cubit.dart';
import 'package:ben_kimim/presentation/all_decks/bloc/ciz_decks_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CizDecks extends StatelessWidget {
  const CizDecks({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              "CİZ",
              style: AppTextstyle.allDecksBaslik,
            ),
          ),
          const _DeckContentLoader(),
        ],
      ),
    );
  }
}

class _DeckContentLoader extends StatelessWidget {
  const _DeckContentLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.allDecksBackground,
      height: SizeHelper.categoryDeckHeight(context),
      child: BlocBuilder<CizDecksCubit, CizDecksState>(
        builder: (context, state) {
          if (state is CizDecksLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CizDecksLoadFailure) {
            return Center(
              child: Text(
                state.errorMessage,
                style: TextStyle(fontSize: 16.sp, color: Colors.red),
              ),
            );
          }

          if (state is CizDecksLoaded) {
            return _DeckListView(decks: state.decks);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DeckListView extends StatelessWidget {
  final List<DeckEntity> decks;
  const _DeckListView({required this.decks});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: SizeHelper.categoryListHorizontalPad,
      ),
      itemCount: decks.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(right: SizeHelper.categoryListGap),
          child: SizedBox(
            width: SizeHelper.categoryDeckWidth(context),
            child: DeckCover(deck: decks[index]),
          ),
        );
      },
    );
  }
}
