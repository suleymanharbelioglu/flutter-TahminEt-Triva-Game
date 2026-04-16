import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'premium_status_cubit.dart';
import 'premium_status_state.dart';
import 'unlock_premium.dart';

class IsUserPremiumCubit extends Cubit<bool> {
  late final StreamSubscription _premiumSub;
  late final StreamSubscription _unlockSub;

  IsUserPremiumCubit(
    PremiumStatusCubit premiumStatusCubit,
    UnlockPremiumCubit unlockPremiumCubit,
  ) : super(false) {

    // 1) Başlangıç değeri belirle
    _setPremiumState(premiumStatusCubit.state, unlockPremiumCubit.state);

    // 2) PremiumStatusCubit'i dinle
    _premiumSub = premiumStatusCubit.stream.listen((state) {
      _setPremiumState(state, unlockPremiumCubit.state);
    });

    // 3) UnlockPremiumCubit'i dinle
    _unlockSub = unlockPremiumCubit.stream.listen((isUnlocked) {
      _setPremiumState(premiumStatusCubit.state, isUnlocked);
    });
  }

  void _setPremiumState(PremiumStatusState premiumState, bool unlocked) {
    if (kDebugMode && unlocked) {
      emit(true);
      return;
    }

    if (premiumState is PremiumActive) {
      emit(true);
    } else {
      emit(false);
    }
  }

  @override
  Future<void> close() {
    _premiumSub.cancel();
    _unlockSub.cancel();
    return super.close();
  }
}
