import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/floating_home_button.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Location")),
      body: const GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(6.9271, 79.8612),
          zoom: 14,
        ),
      ),
      floatingActionButton: const FloatingHomeButton(),
    );
  }
}
