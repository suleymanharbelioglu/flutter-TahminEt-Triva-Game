import 'package:ben_kimim/core/analytics/analytics_service.dart';
import 'package:ben_kimim/presentation/no_internet/bloc/internet_connection_cubit.dart';
import 'package:ben_kimim/presentation/no_internet/bloc/internet_connection_state.dart';
import 'package:ben_kimim/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoInternetPage extends StatefulWidget {
  const NoInternetPage({super.key});

  @override
  State<NoInternetPage> createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    sl<AnalyticsService>().logNoInternetShown();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.45),
        body: BlocListener<InternetConnectionCubit, InternetConnectionState>(
          listener: (context, state) {
            if (state is InternetConnected) {
              Navigator.of(context).pop();
            }
          },
          child: Center(
            child: FadeTransition(
              opacity: Tween(begin: 0.7, end: 1.0).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
              child: Container(
                height: 0.33.sh,
                width: 0.83.sw,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 18.r,
                      offset: Offset(0, 5.h),
                      color: Colors.black.withOpacity(0.18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: Tween(begin: 0.93, end: 1.05).animate(
                        CurvedAnimation(
                            parent: _controller, curve: Curves.easeInOut),
                      ),
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: 65.r,
                        color: Colors.red.shade400,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      "İnternet Bağlantısı Yok",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Lütfen internet bağlantınızı kontrol edin.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        height: 1.4,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
