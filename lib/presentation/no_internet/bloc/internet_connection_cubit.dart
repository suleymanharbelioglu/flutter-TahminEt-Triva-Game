import 'dart:async';
import 'package:ben_kimim/presentation/no_internet/bloc/internet_connection_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InternetConnectionCubit extends Cubit<InternetConnectionState> {
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  InternetConnectionCubit() : super(InternetConnected()) {
    // Başlangıçta internet durumu kontrol et
    _checkInitialConnection();

    // İnternet değişikliklerini dinle
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      _emitFromConnectivity(result);
    });
  }

  void _emitFromConnectivity(List<ConnectivityResult> results) {
    final connected = results.isNotEmpty &&
        results.any((r) => r != ConnectivityResult.none);
    if (kDebugMode) {
      debugPrint('Connectivity changed: $results -> connected=$connected');
    }
    emit(connected ? InternetConnected() : InternetDisConnected());
  }

  Future<void> _checkInitialConnection() async {
    final result = await Connectivity().checkConnectivity();
    _emitFromConnectivity(result);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
