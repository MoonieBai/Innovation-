import 'package:flutter/material.dart';
import 'pages/dashboard.dart';
import 'pages/login.dart';
import 'pages/gpsnavigation.dart';
import 'pages/settings.dart';
import 'pages/solarbattery.dart';

// import 'pages/dashboard.dart'; // create this later

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/',

      routes: {
        '/': (context) => const LoginPage(),
        '/gps': (context) => const GPSNavigationPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/solar': (context) => const SolarBatteryPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}