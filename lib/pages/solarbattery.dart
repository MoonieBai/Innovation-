import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/battery_status.dart';

class SolarBatteryPage extends StatefulWidget {
  const SolarBatteryPage({super.key});

  @override
  State<SolarBatteryPage> createState() => _SolarBatteryPageState();
}

class _SolarBatteryPageState extends State<SolarBatteryPage> {
  double batteryLevel = 75.5;
  double solarPower = 12.5;
  bool isCharging = true;

  Timer? timer;
  final Random random = Random();

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        // Battery change
        double batteryChange = (random.nextDouble() - 0.5) * 2;
        batteryLevel = (batteryLevel + batteryChange).clamp(0, 100);

        // Solar power change
        double solarChange = (random.nextDouble() - 0.5) * 1.5;
        solarPower = (solarPower + solarChange).clamp(0, 20);

        // Charging logic
        isCharging = solarPower > 5;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF020617), Color(0xFF0F172A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Solar Backpack",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Live energy monitoring",
            style: TextStyle(color: Colors.white54),
          ),

          const SizedBox(height: 20),

          // 🎒 Backpack image
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: Image.asset(
                'assets/backpack.png',
                height: 200,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🔋 HERE IS THE LINK 👇
          BatteryStatus(
            batteryLevel: batteryLevel,
            isCharging: isCharging,
            solarPower: solarPower,
          ),
        ],
      ),
    ),
  );
}
}