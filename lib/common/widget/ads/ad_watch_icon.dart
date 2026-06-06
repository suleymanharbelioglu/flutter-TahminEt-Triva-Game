import 'package:flutter/material.dart';

/// Reklam izle desteleri için turuncu TV+play rozeti.
class AdWatchIconBadge extends StatelessWidget {
  final double size;
  final double iconSize;

  const AdWatchIconBadge({
    super.key,
    required this.size,
    required this.iconSize,
  });

  static const Color iconColor = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.live_tv,
        color: iconColor,
        size: iconSize,
      ),
    );
  }
}

/// Buton içinde kullanılan beyaz TV+play ikonu.
class AdWatchIconButton extends StatelessWidget {
  final double size;
  final Color color;

  const AdWatchIconButton({
    super.key,
    required this.size,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.live_tv, color: color, size: size);
  }
}
