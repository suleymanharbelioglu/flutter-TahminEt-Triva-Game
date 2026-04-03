import 'package:ben_kimim/core/configs/theme/app_color.dart';
import 'package:ben_kimim/presentation/all_decks/widgets/bilim_ve_genelk_decks.dart';
import 'package:ben_kimim/presentation/all_decks/widgets/canlandir_decks.dart';
import 'package:ben_kimim/presentation/all_decks/widgets/ciz_decks.dart';
import 'package:ben_kimim/presentation/all_decks/widgets/cizgi_film_anime_decks.dart';
import 'package:ben_kimim/presentation/all_decks/widgets/dizi_film_deck.dart';
import 'package:ben_kimim/presentation/all_decks/widgets/gunluk_yasam_decks.dart';
import 'package:ben_kimim/presentation/all_decks/widgets/muzik_decks.dart';
import 'package:ben_kimim/presentation/all_decks/widgets/popular_decks.dart';
import 'package:ben_kimim/presentation/all_decks/widgets/spor_decks.dart';
import 'package:ben_kimim/presentation/all_decks/widgets/unluler_decks.dart';
import 'package:ben_kimim/presentation/all_decks/widgets/yemekler_decks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AllDecksPage extends StatelessWidget {
  const AllDecksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

    // Tüm değişmez widget'ları bir listede toplayarak kod tekrarını azaltıyoruz.
    // Listeyi const yapamıyoruz çünkü içindeki özel widget'ların const constructor'ı olmayabilir
    // (örneğin stateful ise veya dışarıdan veri alıyorsa).
    // Ancak tek tek widget'ları const yapabiliriz.
    final List<Widget> deckWidgets = const [
      // OPTİMİZASYON 1: Tüm statik widget'lara const eklenmiştir.
      // Bu, build() çağrılsa bile bu widget'ların yeniden oluşturulmasını önler.
      PopularDecks(),
      MuzikDecks(),
      DiziFilmDecks(),
      CanlandirDecks(),
      SporDecks(),
      GunlukYasamDecks(),
      BilimVeGenelKDecks(),
      UnlulerDecks(),
      YemeklerDecks(),
      CizgiFilmAnimeDecks(),
      CizDecks(),
    ];

    return Scaffold(
      backgroundColor: AppColors.allDecksBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: isTablet ? 70.h : kToolbarHeight,
        title: Text(
          "Tahmin Et!",
          style: TextStyle(fontSize: isTablet ? 32.sp : 30.sp),
        ),
        actions: const [],
      ),
      // OPTİMİZASYON 4: SingleChildScrollView yerine ListView kullanılır.
      // ListView, elemanları ekranda göründükçe oluşturma (lazy building) konusunda
      // SingleChildScrollView + Column kombinasyonundan daha verimli çalışır.
      body: ListView(
        padding: EdgeInsets
            .zero, // Eğer varsayılan padding istenmiyorsa eklenebilir.
        children: deckWidgets,
      ),
    );
  }
}
