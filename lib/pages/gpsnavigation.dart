import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GPSNavigationPage extends StatefulWidget {
  const GPSNavigationPage({super.key});

  @override
  State<GPSNavigationPage> createState() => _GPSNavigationPageState();
}

class _GPSNavigationPageState extends State<GPSNavigationPage> {
  final MapController _mapController = MapController();

  StreamSubscription<Position>? _positionStream;

  LatLng _currentPosition = const LatLng(52.4862, -1.8904); // Default to Birmingham, UK
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

Future<void> _initLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    setState(() {
      _loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Location services are OFF")),
    );
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied) {
    setState(() => _loading = false);
    return;
  }

  if (permission == LocationPermission.deniedForever) {
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Location permissions permanently denied")),
    );
    return;
  }

  _positionStream = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    ),
  ).listen((position) {
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _loading = false;
    });

    if (mounted) {
      _mapController.move(_currentPosition, 17);
    }
  });
}

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌍 FULL MAP BACKGROUND
            FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 13,
              onMapReady: () {
                setState(() {});
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 35,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 🔵 TOP FLOATING BAR (Figma style)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search),
                    SizedBox(width: 10),
                    Text("Search location..."),
                  ],
                ),
              ),
            ),
          ),

          // 📍 GPS BUTTON
          Positioned(
            right: 16,
            bottom: 160,
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () {
                _mapController.move(_currentPosition, 17);
              },
              child: const Icon(Icons.my_location),
            ),
          ),

          // 📦 BOTTOM INFO CARD (Figma style panel)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: Colors.black26,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Current Location",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${_currentPosition.latitude.toStringAsFixed(5)}, "
                    "${_currentPosition.longitude.toStringAsFixed(5)}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text("Start Navigation"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}