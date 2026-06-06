import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Rewarded reklam yüklenirken gösterilen hafif karartmalı tam ekran sayfa.
class RewardedAdLoadingPage extends StatelessWidget {
  const RewardedAdLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.black.withOpacity(0.45),
        child: Center(
          child: SizedBox(
            width: 40.sp,
            height: 40.sp,
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
        ),
      ),
    );
  }
}
