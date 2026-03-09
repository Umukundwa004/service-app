import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatelessWidget {
  final DocumentSnapshot listing;

  const DetailPage({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final data = listing.data()! as Map<String, dynamic>;

    final GeoPoint? geoPoint = data['location'] is GeoPoint
        ? data['location'] as GeoPoint
        : null;

    final latlng.LatLng destination = geoPoint != null
        ? latlng.LatLng(geoPoint.latitude, geoPoint.longitude)
        : latlng.LatLng(
            (data['latitude'] ?? 0.0).toDouble(),
            (data['longitude'] ?? 0.0).toDouble(),
          );

    final String title = (data['title'] ?? data['name'] ?? 'Location')
        .toString();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: destination,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                  enableMultiFingerGestureRace: true,
                  pinchZoomThreshold: 0.1,
                  pinchMoveThreshold: 8.0,
                  pinchZoomWinGestures:
                      MultiFingerGesture.pinchZoom |
                      MultiFingerGesture.pinchMove,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: destination,
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.location_on,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              try {
                await _launchNavigation(destination);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('Navigate to Location'),
          ),
        ],
      ),
    );
  }
}

Future<void> _launchNavigation(latlng.LatLng latLng) async {
  final String inAppDirectionsUrl =
      'https://www.google.com/maps/dir/?api=1&destination=${latLng.latitude},${latLng.longitude}&travelmode=driving';
  final String googleMapsUrl =
      'google.navigation:q=${latLng.latitude},${latLng.longitude}&mode=d';
  final String appleMapsUrl =
      'https://maps.apple.com/?q=${latLng.latitude},${latLng.longitude}';

  if (await canLaunchUrl(Uri.parse(inAppDirectionsUrl))) {
    await launchUrl(
      Uri.parse(inAppDirectionsUrl),
      mode: LaunchMode.inAppBrowserView,
    );
  } else if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
    await launchUrl(
      Uri.parse(googleMapsUrl),
      mode: LaunchMode.externalApplication,
    );
  } else if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
    await launchUrl(
      Uri.parse(appleMapsUrl),
      mode: LaunchMode.externalApplication,
    );
  } else if (await canLaunchUrl(Uri.parse(inAppDirectionsUrl))) {
    await launchUrl(
      Uri.parse(inAppDirectionsUrl),
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw 'Could not launch maps';
  }
}
