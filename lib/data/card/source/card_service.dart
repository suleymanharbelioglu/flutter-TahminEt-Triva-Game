import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';

abstract class CardService {
  Future<Either> getCurrentCardNameList(String nameFilePath);
}

class CardServiceImpl extends CardService {
  @override
  Future<Either<String, List<String>>> getCurrentCardNameList(
      String nameFilePath) async {
    try {
      final data = await rootBundle.loadString(nameFilePath);

      final jsonResult = json.decode(data) as Map<String, dynamic>;

      final names = _readNameList(jsonResult);
      if (names != null && names.isNotEmpty) {
        return Right(names);
      }
      return const Left('JSON içinde isim listesi bulunamadı');
    } catch (e) {
      return Left('İsim listesi okunamadı: $e');
    }
  }

  List<String>? _readNameList(Map<String, dynamic> json) {
    final names = json['names'];
    if (names is List) {
      return List<String>.from(names);
    }

    // Bazı desteler farklı anahtar kullanır (ör. ülkeler → "countries").
    for (final value in json.values) {
      if (value is List) {
        return List<String>.from(value);
      }
    }
    return null;
  }
}
