import 'package:ben_kimim/presentation/premium/bloc/unlock_premium.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SecretDialog {
  static Future<void> showSecretDialog(BuildContext context) async {
    // Sadece mağaza release build'inde kapalı; debug + profile'da açılır.
    if (kReleaseMode) return;
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter Secret Code"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Secret code"),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text == "GOOGLE2025GOOGLE2025") {
                context.read<UnlockPremiumCubit>().unlock();
              }
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}
