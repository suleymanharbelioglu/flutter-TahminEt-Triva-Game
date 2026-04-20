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
    // Her 2 oyunda 1 interstitial.
    final show = next % 2 == 0;
    if (kDebugMode) {
      debugPrint(
        'GameInterstitialCounter: giriş #$next → interstitial ${show ? "EVET" : "HAYIR"}',
      );
    }
    return show;
  }
}
