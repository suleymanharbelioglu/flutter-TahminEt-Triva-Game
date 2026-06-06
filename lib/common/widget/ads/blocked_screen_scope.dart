import 'package:ben_kimim/presentation/game/bloc/interstitial_scheduler_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Interstitial'ın gösterilmemesi gereken sayfaları işaretler.
class BlockedScreenScope extends StatefulWidget {
  final Widget child;

  const BlockedScreenScope({super.key, required this.child});

  @override
  State<BlockedScreenScope> createState() => _BlockedScreenScopeState();
}

class _BlockedScreenScopeState extends State<BlockedScreenScope> {
  InterstitialSchedulerCubit? _scheduler;
  bool _entered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entered) return;

    _scheduler = context.read<InterstitialSchedulerCubit>();
    _scheduler!.enterBlockedScreen();
    _entered = true;
  }

  @override
  void dispose() {
    if (_entered) {
      _scheduler?.leaveBlockedScreen();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
