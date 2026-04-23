import 'package:flutter/material.dart';
import 'gpsnavigation.dart';
import 'settings.dart';
import 'solarbattery.dart';
// import 'solar_page.dart';
// import 'settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

final List<Widget> pages = [
  const SolarBatteryPage(),
  const GPSNavigationPage(),
  const SettingsPage(), // ✅ add this
];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827), // gray-900

      body: Column(
        children: [
          // 🔴 Header (gradient like your design)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF7F1D1D),
                  Color(0xFF991B1B),
                  Color(0xFF450A0A),
                ],
              ),
            ),
            child: Row(
              children: [
                Image.asset('assets/logo.png', height: 40),
                const SizedBox(width: 10),
                const Text(
                  "Smart Backpack",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 🧭 Navigation buttons (like your grid)
          Container(
            color: const Color(0xFF1F2937), // gray-800
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                navButton(0, Icons.battery_full, "Solar"),
                navButton(1, Icons.navigation, "GPS"),
                navButton(2, Icons.settings, "Settings"),
              ],
            ),
          ),

          // 📱 Page content (replacement for <Outlet />)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: pages[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget navButton(int index, IconData icon, String label) {
    final bool isActive = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemTapped(index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFDC2626) // red-600
                : const Color(0xFF374151), // gray-700
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}