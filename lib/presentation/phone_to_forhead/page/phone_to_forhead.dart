// phone_to_forehead_page.dart
import 'dart:async';
import 'dart:io' show Platform;
import 'package:ben_kimim/common/helper/sound/sound.dart';
import 'package:ben_kimim/core/configs/theme/app_color.dart';
import 'package:ben_kimim/presentation/game/page/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ben_kimim/presentation/game/bloc/display_current_card_list_cubit.dart';
import 'package:ben_kimim/presentation/game/bloc/display_current_card_list_state.dart';

class PhoneToForeheadPage extends StatefulWidget {
  const PhoneToForeheadPage({super.key});

  @override
  State<PhoneToForeheadPage> createState() => _PhoneToForeheadPageState();
}

class _PhoneToForeheadPageState extends State<PhoneToForeheadPage> {
  int countdown = 4;
  Timer? _timer;
  StreamSubscription? _accelerometerSubscription;
  StreamSubscription<DisplayCurrentCardListState>? _cubitSubscription;
  bool countdownStarted = false;

  // Pozisyon sınırları
  final double minX = 7, maxX = 10;
  final double minY = -5, maxY = 5;
  final double minZ = -4, maxZ = 5;

  @override
  void initState() {
    super.initState();
    countdown = 4;
    countdownStarted = false; // Her sayfa açılışında sıfırlanıyor
    // Yatay mod tek yöne kilitli
    // Android: mevcut davranış kalsın (landscapeLeft).
    // iOS: telefonun üst kısmı solda kalsın.
    SystemChrome.setPreferredOrientations([
      Platform.isIOS ? DeviceOrientation.landscapeRight : DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    // Telefon pozisyonunu dinle
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      if (!countdownStarted) {
        bool inPosition = event.x >= minX &&
            event.x <= maxX &&
            event.y >= minY &&
            event.y <= maxY &&
            event.z >= minZ &&
            event.z <= maxZ;

        if (inPosition) {
          countdownStarted = true;
          startCountdown();
          startCountDownSound(); // 🔊 Ses burada başlatılıyor
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _accelerometerSubscription?.cancel();
    _cubitSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 🔒 Tüm "pop" işlemlerini (geri çıkma) engeller
      onPopInvoked: (didPop) {
        // Buraya hiçbir şey yazma veya log bile atma
        // Fiziksel geri tuşu dahil hiçbir şey sayfayı kapatamayacak
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: countdownStarted
              ? Text(
                  '$countdown',
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'TELEFONU ALNINIZA YERLEŞTİRİN',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }

  /// 🔊 Geri sayım sesi 1 saniye gecikmeli çalar
  Future<void> startCountDownSound() async {
    await Future.delayed(const Duration(seconds: 1)); // 1 saniye geciktirme
    await SoundHelper.playCountdown(); // Ses dosyasını yükle + çal
  }

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => countdown--);

      if (countdown == 0) {
        _timer?.cancel();

        final cubit = context.read<DisplayCurrentCardListCubit>();

        // Durum kontrol fonksiyonu
        void handleState(DisplayCurrentCardListState state) {
          if (state is DisplayCurrentCardListLoaded) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GamePage()),
            );
          } else if (state is DisplayCurrentCardListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error: ${state.message}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        // Eğer state zaten loaded veya error ise anında işlem yap
        if (cubit.state is DisplayCurrentCardListLoaded ||
            cubit.state is DisplayCurrentCardListError) {
          handleState(cubit.state);
        } else {
          // Henüz loaded değilse, stream'i dinle sadece bir kez
          _cubitSubscription = cubit.stream.listen((state) {
            handleState(state);
            _cubitSubscription?.cancel(); // Tek seferlik dinle
          });
        }
      }
    });
  }
}
