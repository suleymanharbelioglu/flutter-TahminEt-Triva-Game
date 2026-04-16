import 'dart:convert';
import 'package:ben_kimim/data/deck/model/deck.dart';
import 'package:ben_kimim/domain/deck/entity/deck.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // compute() için gerekli

abstract class DeckService {
  Future<Either<String, List<DeckEntity>>> getPopularDecks();
  Future<Either<String, List<DeckEntity>>> getMuzikDecks();
  Future<Either<String, List<DeckEntity>>> getSporDecks();
  Future<Either<String, List<DeckEntity>>> getCanlandirDecks();
  Future<Either<String, List<DeckEntity>>> getDiziFilmDecks();
  Future<Either<String, List<DeckEntity>>> getGunlukYasamDecks();
  Future<Either<String, List<DeckEntity>>> getBilimVeGenelKDecks();
  Future<Either<String, List<DeckEntity>>> getCizDecks();
  Future<Either<String, List<DeckEntity>>> getUnlulerDecks();
  Future<Either<String, List<DeckEntity>>> getYemeklerDecks();
  Future<Either<String, List<DeckEntity>>> getCizgiFilmAnimeDecks();
}

class DeckServiceImpl extends DeckService {
  List<DeckEntity>? _cachedDecks;

  // ✅ Arka planda parse işlemi
  static List<DeckEntity> _parseDecks(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => DeckModel.fromJson(e).toEntity()).toList();
  }

  Future<List<DeckEntity>> _loadDecks() async {
    if (_cachedDecks != null) {
      return _cachedDecks!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/decks.json');

      // ✅ JSON parsing işlemini başka isolate’ta yapıyoruz
      _cachedDecks = await compute(_parseDecks, jsonString);

      return _cachedDecks!;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<String, List<DeckEntity>>> getPopularDecks() async {
    try {
      final result = await _loadDecks();
      final entries = <MapEntry<int, DeckEntity>>[];
      for (var i = 0; i < result.length; i++) {
        final d = result[i];
        if (d.categoryNameList.contains('Popular')) {
          entries.add(MapEntry(i, d)); // i = orijinal sırası (stable sort için)
        }
      }

      int priority(DeckEntity d) {
        // "En üstteki Hayvanlar" listesinde Başkentler'i öne al.
        switch (d.deckName) {
          case 'Hayvanlar':
            return 0;
          case 'Başkentler':
            return 1;
          default:
            return 100;
        }
      }

      entries.sort((a, b) {
        final pa = priority(a.value);
        final pb = priority(b.value);
        if (pa != pb) return pa.compareTo(pb);
        return a.key.compareTo(b.key); // geri kalanlar JSON sırasını korur
      });

      return Right(entries.map((e) => e.value).toList());
    } catch (e) {
      return const Left("Popular deck list problem");
    }
  }

  @override
  Future<Either<String, List<DeckEntity>>> getMuzikDecks() async {
    try {
      final result = await _loadDecks();
      final list =
          result.where((d) => d.categoryNameList.contains('Müzik')).toList();
      return Right(list);
    } catch (e) {
      return const Left("Müzik deck list problem");
    }
  }

  @override
  Future<Either<String, List<DeckEntity>>> getCanlandirDecks() async {
    try {
      final result = await _loadDecks();
      final list = result
          .where((d) => d.categoryNameList.contains('Canlandır'))
          .toList();
      return Right(list);
    } catch (e) {
      return const Left("Canlandır deck list problem");
    }
  }

  @override
  Future<Either<String, List<DeckEntity>>> getDiziFilmDecks() async {
    try {
      final result = await _loadDecks();
      final list = result
          .where((d) => d.categoryNameList.contains('Dizi/Film'))
          .toList();
      return Right(list);
    } catch (e) {
      return const Left("Dizi/Film deck list problem");
    }
  }

  @override
  Future<Either<String, List<DeckEntity>>> getSporDecks() async {
    try {
      final result = await _loadDecks();
      final list =
          result.where((d) => d.categoryNameList.contains('Spor')).toList();
      return Right(list);
    } catch (e) {
      return const Left("Spor deck list problem");
    }
  }

  @override
  Future<Either<String, List<DeckEntity>>> getBilimVeGenelKDecks() async {
    try {
      final result = await _loadDecks();
      final list = result
          .where((d) => d.categoryNameList.contains('Bilim & Genel Kültür'))
          .toList();
      return Right(list);
    } catch (e) {
      return const Left("Bilim & Genel Kültür deck list problem");
    }
  }

  @override
  Future<Either<String, List<DeckEntity>>> getGunlukYasamDecks() async {
    try {
      final result = await _loadDecks();
      final list = result
          .where((d) => d.categoryNameList.contains('Günlük Yaşam'))
          .toList();
      return Right(list);
    } catch (e) {
      return const Left("Günlük Yaşam deck list problem");
    }
  }

  @override
  Future<Either<String, List<DeckEntity>>> getCizDecks() async {
    try {
      final result = await _loadDecks();
      final list =
          result.where((d) => d.categoryNameList.contains('Ciz')).toList();
      return Right(list);
    } catch (e) {
      return const Left("Ciz deck list problem");
    }
  }

  @override
  Future<Either<String, List<DeckEntity>>> getCizgiFilmAnimeDecks() async {
    try {
      final result = await _loadDecks();
      final list = result
          .where((d) => d.categoryNameList.contains('CizgiFilmAnime'))
          .toList();
      return Right(list);
    } catch (e) {
      return const Left("CizgiFilmAnime deck list problem");
    }
  }

  @override
  Future<Either<String, List<DeckEntity>>> getUnlulerDecks() async {
    try {
      final result = await _loadDecks();
      final list =
          result.where((d) => d.categoryNameList.contains('Unluler')).toList();
      return Right(list);
    } catch (e) {
      return const Left("Unluler deck list problem");
    }
  }

  @override
  Future<Either<String, List<DeckEntity>>> getYemeklerDecks() async {
    try {
      final result = await _loadDecks();
      final list =
          result.where((d) => d.categoryNameList.contains('Yemekler')).toList();
      return Right(list);
    } catch (e) {
      return const Left("Yemekler deck list problem");
    }
  }
}
