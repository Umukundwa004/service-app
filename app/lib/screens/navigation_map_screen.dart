import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:url_launcher/url_launcher.dart';
import '../models/listing_model.dart';

class NavigationMapScreen extends StatefulWidget {
  final ListingModel destination;
  final List<ListingModel> allListings;

  const NavigationMapScreen({
    super.key,
    required this.destination,
    required this.allListings,
  });

  @override
  State<NavigationMapScreen> createState() => _NavigationMapScreenState();
}

class _NavigationMapScreenState extends State<NavigationMapScreen> {
  final MapController _mapController = MapController();
  double _currentZoom = 14;

  bool _hasValidCoordinates(ListingModel listing) {
    final lat = listing.latitude;
    final lng = listing.longitude;
    final isInRange = lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    final isNotZeroPoint = !(lat == 0 && lng == 0);
    return isInRange && isNotZeroPoint;
  }

  List<ListingModel> get _validListings {
    final filtered = widget.allListings.where(_hasValidCoordinates).toList();
    final destinationMissing =
        filtered.every((item) => item.id != widget.destination.id) &&
        _hasValidCoordinates(widget.destination);

    if (destinationMissing) {
      filtered.add(widget.destination);
    }

    return filtered;
  }

  List<Marker> _buildMarkers() {
    return _validListings.map((listing) {
      final isDestination = listing.id == widget.destination.id;

      return Marker(
        point: latlng.LatLng(listing.latitude, listing.longitude),
        width: isDestination ? 48 : 38,
        height: isDestination ? 48 : 38,
        child: Icon(
          Icons.location_on,
          size: isDestination ? 42 : 34,
          color: isDestination ? Colors.blueAccent : Colors.red,
        ),
      );
    }).toList();
  }

  void _fitBounds() {
    if (_validListings.isEmpty) return;

    final points = _validListings
        .map((listing) => latlng.LatLng(listing.latitude, listing.longitude))
        .toList();

    final first = points.first;
    final hasSpread = points.any(
      (point) =>
          point.latitude != first.latitude ||
          point.longitude != first.longitude,
    );

    if (!hasSpread) {
      _mapController.move(first, 15);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    );
  }

  Future<void> _openTurnByTurnDirections() async {
    final lat = widget.destination.latitude;
    final lng = widget.destination.longitude;

    final inAppDirectionsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );

    if (await canLaunchUrl(inAppDirectionsUrl)) {
      await launchUrl(inAppDirectionsUrl, mode: LaunchMode.inAppBrowserView);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Could not open directions')));
  }

  void _zoomIn() {
    final center = _mapController.camera.center;
    final nextZoom = (_currentZoom + 1).clamp(3.0, 19.0);
    _mapController.move(center, nextZoom);
  }

  void _zoomOut() {
    final center = _mapController.camera.center;
    final nextZoom = (_currentZoom - 1).clamp(3.0, 19.0);
    _mapController.move(center, nextZoom);
  }

  @override
  Widget build(BuildContext context) {
    final destinationLatLng = latlng.LatLng(
      widget.destination.latitude,
      widget.destination.longitude,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Directions • ${widget.destination.name}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: destinationLatLng,
              initialZoom: 14,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
                enableMultiFingerGestureRace: true,
                pinchZoomThreshold: 0.1,
                pinchMoveThreshold: 8.0,
                pinchZoomWinGestures:
                    MultiFingerGesture.pinchZoom | MultiFingerGesture.pinchMove,
              ),
              onPositionChanged: (camera, hasGesture) {
                _currentZoom = camera.zoom;
              },
              onMapReady: () {
                Future.delayed(const Duration(milliseconds: 300), _fitBounds);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: destinationLatLng,
                    radius: 35,
                    color: Colors.deepPurple.withOpacity(0.18),
                    borderColor: Colors.deepPurple,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 90,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _zoomIn,
                  child: Icon(Icons.add, color: Colors.deepPurple.shade700),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _zoomOut,
                  child: Icon(Icons.remove, color: Colors.deepPurple.shade700),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: ElevatedButton.icon(
              onPressed: _openTurnByTurnDirections,
              icon: const Icon(Icons.navigation),
              label: const Text('Open Turn-by-Turn Directions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
