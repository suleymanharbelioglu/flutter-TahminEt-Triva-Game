import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tam ekran interstitial: oyun alanına (deste Oyna / Tekrar oyna) her girişte bir kez değerlendirilir.
/// Desen: yok → var → yok → var … (tek numaralı girişlerde yok, çift numaralıda var).
class GameInterstitialCounterCubit extends Cubit<int> {
  GameInterstitialCounterCubit() : super(0);

  /// Oyun ekranına (telefon alnına) her girişte bir kez çağrılır.
  bool consumeGameStartAndShouldShowInterstitial() {
    final next = state + 1;
    emit(next);
    final show = next.isEven;
    if (kDebugMode) {
      debugPrint(
        'GameInterstitialCounter: giriş #$next → interstitial ${show ? "EVET" : "HAYIR"}',
      );
    }
    return show;
  }
}
