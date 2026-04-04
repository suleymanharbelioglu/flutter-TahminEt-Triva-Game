import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tam ekran interstitial sırası: 1. giriş yok, 2. var, 3. yok, 4. var…
/// Her [consumeGameStartAndShouldShowInterstitial] = bir kez Oyna veya Tekrar oyna.
class GameInterstitialCounterCubit extends Cubit<int> {
  GameInterstitialCounterCubit() : super(0);

  /// Oyun ekranına (telefon alnına) her girişte bir kez çağrılır.
  /// Dönüş: bu sefer interstitial gösterilsin mi (çift sayılı girişlerde evet).
  bool consumeGameStartAndShouldShowInterstitial() {
    final next = state + 1;
    emit(next);
    final show = next.isEven;
    if (kDebugMode) {
      debugPrint(
        'GameInterstitialCounter: giriş #$next → interstitial ${show ? "EVET" : "hayır"}',
      );
    }
    return show;
  }
}
