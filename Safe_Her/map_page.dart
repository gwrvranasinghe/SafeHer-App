import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/floating_home_button.dart';
import '../utils/map_styles.dart';
import 'package:flutter/services.dart'; // For clipboard
import 'package:url_launcher/url_launcher.dart'; // For sharing via other apps

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Sri Lanka coordinates
  static const CameraPosition _sriLankaPosition = CameraPosition(
    target: LatLng(6.9271, 79.8612), // Colombo
    zoom: 8,
  );

  GoogleMapController? _mapController;
  MapType _currentMapType = MapType.normal;

  // Custom styles
  final List<String> _customStyles = [
    'Standard',
    'Dark Mode',
    'Night Mode',
    'Retro',
  ];

  int _currentStyleIndex = 0;
  bool _useCustomStyle = false;

  // Current location for sharing
  LatLng _currentCenter = const LatLng(6.9271, 79.8612);
  double _currentZoom = 8;

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
      _useCustomStyle =
          false; // Turn off custom style when using built-in types
    });
    _applyMapStyle();
  }

  void _cycleCustomStyle() {
    setState(() {
      _currentStyleIndex = (_currentStyleIndex + 1) % _customStyles.length;
      _useCustomStyle = true;
    });
    _applyMapStyle();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Style: ${_customStyles[_currentStyleIndex]}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _applyMapStyle() async {
    if (_mapController == null) return;

    if (_useCustomStyle) {
      String style;
      switch (_currentStyleIndex) {
        case 1:
          style = MapStyles.darkMode;
          break;
        case 2:
          style = MapStyles.nightMode;
          break;
        case 3:
          style = MapStyles.retro;
          break;
        default:
          style = '[]'; // Reset to default
      }
      await _mapController!.setMapStyle(style);
    } else {
      await _mapController!.setMapStyle(null); // Reset to Google default
    }
  }

  void _showStyleMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Map Style',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Google Map Types
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Normal'),
              selected: !_useCustomStyle && _currentMapType == MapType.normal,
              onTap: () {
                setState(() {
                  _currentMapType = MapType.normal;
                  _useCustomStyle = false;
                });
                _applyMapStyle();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.satellite),
              title: const Text('Satellite'),
              selected:
                  !_useCustomStyle && _currentMapType == MapType.satellite,
              onTap: () {
                setState(() {
                  _currentMapType = MapType.satellite;
                  _useCustomStyle = false;
                });
                _applyMapStyle();
                Navigator.pop(context);
              },
            ),
            const Divider(),
            // Custom Styles
            ...List.generate(_customStyles.length, (index) {
              return ListTile(
                leading: Icon(
                  index == 0
                      ? Icons.brightness_medium
                      : index == 1
                      ? Icons.brightness_2
                      : index == 2
                      ? Icons.nightlight
                      : Icons.history,
                ),
                title: Text(_customStyles[index]),
                selected: _useCustomStyle && _currentStyleIndex == index,
                onTap: () {
                  setState(() {
                    _currentStyleIndex = index;
                    _useCustomStyle = true;
                  });
                  _applyMapStyle();
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // NEW: Share location function
  void _shareCurrentLocation() {
    final String latitude = _currentCenter.latitude.toStringAsFixed(6);
    final String longitude = _currentCenter.longitude.toStringAsFixed(6);
    final String zoom = _currentZoom.toStringAsFixed(1);

    // Create Google Maps link
    final String mapsLink =
        'https://www.google.com/maps?q=$latitude,$longitude';

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Location',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Location coordinates
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text('Latitude: $latitude'),
                  Text('Longitude: $longitude'),
                  Text('Zoom: $zoom', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Share options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Copy to clipboard
                _buildShareOption(
                  icon: Icons.copy,
                  label: 'Copy',
                  color: Colors.blue,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: mapsLink));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Location link copied to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),

                // Share via other apps
                _buildShareOption(
                  icon: Icons.share,
                  label: 'Share',
                  color: Colors.green,
                  onTap: () async {
                    final String shareText =
                        'Check out this location on Google Maps:\n$mapsLink';
                    // You can add more sharing options here
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sharing: $mapsLink'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),

                // Open in Google Maps app
                _buildShareOption(
                  icon: Icons.map,
                  label: 'Open Maps',
                  color: Colors.orange,
                  onTap: () async {
                    final String url =
                        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open Google Maps'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for share options
  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Update current center when camera moves
  void _onCameraMove(CameraPosition position) {
    _currentCenter = position.target;
    _currentZoom = position.zoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Location"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // NEW: Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareCurrentLocation,
            tooltip: 'Share Location',
          ),
          // Style menu button
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _showStyleMenu,
            tooltip: 'Map Styles',
          ),
          // Toggle map type button
          IconButton(
            icon: Icon(
              _currentMapType == MapType.normal ? Icons.satellite : Icons.map,
            ),
            onPressed: _toggleMapType,
            tooltip: 'Toggle Map Type',
          ),
          // Style indicator
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                _useCustomStyle
                    ? _customStyles[_currentStyleIndex]
                    : (_currentMapType == MapType.normal
                          ? 'Normal'
                          : 'Satellite'),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: GoogleMap(
        mapType: _useCustomStyle ? MapType.normal : _currentMapType,
        initialCameraPosition: _sriLankaPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        zoomControlsEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _applyMapStyle();
        },
        onCameraMove: _onCameraMove, // Track camera movements
        onCameraIdle: () {
          // You can add any action when camera stops moving
        },
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Zoom in button
          FloatingActionButton(
            heroTag: 'zoomIn',
            mini: true,
            onPressed: () {
              if (_mapController != null) {
                _mapController!.animateCamera(CameraUpdate.zoomIn());
              }
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),

          // Zoom out button
          FloatingActionButton(
            heroTag: 'zoomOut',
            mini: true,
            onPressed: () {
              if (_mapController != null) {
                _mapController!.animateCamera(CameraUpdate.zoomOut());
              }
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),

          // Center on Colombo button
          FloatingActionButton(
            heroTag: 'center',
            mini: true,
            onPressed: () {
              if (_mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(_sriLankaPosition),
                );
              }
            },
            child: const Icon(Icons.center_focus_strong),
          ),
          const SizedBox(height: 8),

          // Your existing home button
          const FloatingHomeButton(),
        ],
      ),
    );
  }
}
