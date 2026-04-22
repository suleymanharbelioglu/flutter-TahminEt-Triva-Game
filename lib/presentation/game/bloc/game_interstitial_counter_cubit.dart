import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tam ekran interstitial: oyun alanına (deste Oyna / Tekrar oyna) her girişte bir kez değerlendirilir.
/// Desen: her girişte var.
class GameInterstitialCounterCubit extends Cubit<int> {
  GameInterstitialCounterCubit() : super(0);

  /// Oyun ekranına (telefon alnına) her girişte bir kez çağrılır.
  bool consumeGameStartAndShouldShowInterstitial() {
    final next = state + 1;
    emit(next);
    // Her oyunda interstitial.
    final show = true;
    if (kDebugMode) {
      debugPrint(
        'GameInterstitialCounter: giriş #$next → interstitial EVET',
      );
    }
    return show;
  }
}
