import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tam ekran interstitial: her oyun başlangıcında gösterilmeye çalışılır.
/// Her [consumeGameStartAndShouldShowInterstitial] = bir kez Oyna veya Tekrar oyna.
class GameInterstitialCounterCubit extends Cubit<int> {
  GameInterstitialCounterCubit() : super(0);

  /// Oyun ekranına (telefon alnına) her girişte bir kez çağrılır.
  /// Dönüş: bu sefer interstitial gösterilsin mi (her zaman evet).
  bool consumeGameStartAndShouldShowInterstitial() {
    final next = state + 1;
    emit(next);
    const show = true;
    if (kDebugMode) {
      debugPrint(
        'GameInterstitialCounter: giriş #$next → interstitial EVET',
      );
    }
    return show;
  }
}
