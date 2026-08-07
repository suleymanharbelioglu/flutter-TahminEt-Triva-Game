// bottom_nav_cubit.dart
import 'package:ben_kimim/common/helper/sound/sound.dart';
import 'package:ben_kimim/core/analytics/analytics_service.dart';
import 'package:ben_kimim/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavCubit extends Cubit<int> {
  BottomNavCubit() : super(1); // başlangıç: 1. sayfa

  static const _screenNames = {
    0: 'premium',
    1: 'decks',
    2: 'how_to_play',
  };

  Future<void> changePage(int index) async {
    await SoundHelper.playClick();

    if (index == 0) {
      sl<AnalyticsService>().logPremiumViewed(source: 'tab');
    }

    final screen = _screenNames[index];
    if (screen != null) {
      sl<AnalyticsService>().logScreenView(screenName: screen);
    }

    emit(index);
  }
}
