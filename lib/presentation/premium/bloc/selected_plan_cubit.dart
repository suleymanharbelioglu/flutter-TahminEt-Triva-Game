import 'package:ben_kimim/common/helper/sound/sound.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectedPlanCubit extends Cubit<String?> {
  SelectedPlanCubit()
      : super(
          kIsWeb
              ? null
              : (defaultTargetPlatform == TargetPlatform.iOS
                  ? 'weekly_premium'
                  : 'weekly_premium:weekly-plan'),
        ); // Başlangıçta haftalık plan seçili

  /// UI üzerinden seçilen planı set eder
  Future<void> selectPlan(String productId) async {
    await SoundHelper.playClick();
    emit(productId);
  }
}
