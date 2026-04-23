import 'package:flutter/material.dart';
import 'map_widget.dart';

class GPSCard extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double altitude;
  final double heading;

  const GPSCard({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.heading,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1F2937),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "GPS Navigation",
                  style: TextStyle(color: Colors.white),
                ),
                Icon(Icons.navigation, color: Colors.grey),
              ],
            ),

            const SizedBox(height: 12),

            // Map
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: MapWidget(
                latitude: latitude,
                longitude: longitude,
              ),
            ),

            const SizedBox(height: 12),

            // Location
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Birmingham, UK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Heading: ${heading.toStringAsFixed(0)}°",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Altitude: ${altitude.toStringAsFixed(0)}m",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Start Navigation"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}