import 'package:flutter_bloc/flutter_bloc.dart';

/// Reklam izleyerek açılan desteler için kalan oyun hakkı (1 tur / reklam).
class DeckPlayCreditsCubit extends Cubit<Map<String, int>> {
  DeckPlayCreditsCubit() : super(const {});

  static const int roundsPerAd = 1;

  int creditsFor(String deckName) => state[deckName] ?? 0;

  bool hasCredits(String deckName) => creditsFor(deckName) > 0;

  void grantCredits(String deckName) {
    emit({...state, deckName: roundsPerAd});
  }

  void consumeRound(String deckName) {
    final current = creditsFor(deckName);
    if (current <= 0) return;
    final next = current - 1;
    if (next <= 0) {
      final updated = Map<String, int>.from(state)..remove(deckName);
      emit(updated);
    } else {
      emit({...state, deckName: next});
    }
  }
}
