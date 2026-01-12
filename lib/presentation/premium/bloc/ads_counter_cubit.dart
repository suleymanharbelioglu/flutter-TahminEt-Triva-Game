import 'package:flutter_bloc/flutter_bloc.dart';

class AdsCounterCubit extends Cubit<bool> {
  AdsCounterCubit() : super(true); // false = gösterme

  void next() {
    emit(!state);
  }

  
}