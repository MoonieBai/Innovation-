import 'package:flutter/material.dart';

class BatteryStatus extends StatelessWidget {
  final double batteryLevel;
  final bool isCharging;
  final double solarPower;

  const BatteryStatus({
    super.key,
    required this.batteryLevel,
    required this.isCharging,
    required this.solarPower,
  });

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      if (batteryLevel > 60) return Colors.greenAccent;
      if (batteryLevel > 30) return Colors.orangeAccent;
      return Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF1F2937)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: getColor().withOpacity(0.4),
            blurRadius: 25,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          // 🔋 Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Battery",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              Icon(
                isCharging
                    ? Icons.bolt
                    : Icons.battery_std,
                color: getColor(),
              )
            ],
          ),

          const SizedBox(height: 20),

          // 🔥 BIG % (main focus)
          Text(
            "${batteryLevel.toStringAsFixed(0)}%",
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          // 🔋 Progress bar (rounded + smooth)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: batteryLevel / 100,
              minHeight: 8,
              color: getColor(),
              backgroundColor: Colors.white10,
            ),
          ),

          const SizedBox(height: 20),

          // ☀️ Solar section (secondary info)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Solar Input",
                style: TextStyle(color: Colors.white54),
              ),
              Text(
                "${solarPower.toStringAsFixed(1)} W",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}