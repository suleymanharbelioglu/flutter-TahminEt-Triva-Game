import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:io' show Platform;

class SensorDebugPage extends StatefulWidget {
  const SensorDebugPage({super.key});

  @override
  State<SensorDebugPage> createState() => _SensorDebugPageState();
}

class _SensorDebugPageState extends State<SensorDebugPage> {
  double x = 0, y = 0, z = 0;

  @override
  void initState() {
    super.initState();
    // Sadece landscape right’a zorla
    SystemChrome.setPreferredOrientations([
      Platform.isIOS ? DeviceOrientation.landscapeRight : DeviceOrientation.landscapeLeft,
    ]);

    accelerometerEvents.listen((event) {
      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;
      });
    });
  }

  @override
  void dispose() {
    // Ekran yönünü serbest bırak
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'X: ${x.toStringAsFixed(2)}\nY: ${y.toStringAsFixed(2)}\nZ: ${z.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 30,
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
