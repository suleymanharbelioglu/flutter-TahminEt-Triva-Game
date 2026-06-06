import 'package:ben_kimim/domain/deck/entity/deck.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentDeckCubit extends Cubit<DeckEntity?> {
  CurrentDeckCubit() : super(null);

  void setDeck(DeckEntity deck) => emit(deck);

  void clear() => emit(null);
}
