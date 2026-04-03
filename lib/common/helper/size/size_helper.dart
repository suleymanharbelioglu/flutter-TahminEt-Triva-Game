import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SizeHelper {
  /// Yatay deste listelerindeki kart genişliği.
  /// Tablet: [categoryListHorizontalPad] + [categoryListGap] ile ekranda ~2 kart;
  /// padding bir tık dar (14) — kartlar biraz daha büyük.
  static double categoryDeckWidth(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final tablet = mq.shortestSide >= 600;
    if (!tablet) return 175.h;
    final pad = categoryListHorizontalPad;
    final gap = categoryListGap;
    return (mq.width - 2 * pad - gap) / 2;
  }

  /// Yatay `ListView` ile aynı olmalı (tablet 2 kart hesabı).
  static double get categoryListHorizontalPad => 14.w;

  static double get categoryListGap => 8.w;

  /// Yatay deste listelerindeki satır yüksekliği; tablette genişlikle aynı oran (~175:290).
  static double categoryDeckHeight(BuildContext context) {
    final tablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    if (!tablet) return 290.h;
    final w = categoryDeckWidth(context);
    return w * (290 / 175);
  }
}
