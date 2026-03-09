import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import '../bloc/listing/listing_bloc.dart';
import '../bloc/listing/listing_event.dart';
import '../bloc/listing/listing_state.dart';
import '../models/listing_model.dart';
import 'listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapController _mapController = MapController();
  ListingModel? _selectedListing;
  int _lastFittedMarkerCount = -1;
  double _currentZoom = 12;

  // Default to Kigali, Rwanda
  static final latlng.LatLng _defaultLocation = latlng.LatLng(-1.9403, 29.8739);

  @override
  void initState() {
    super.initState();
    context.read<ListingBloc>().add(const LoadListings());
  }

  bool _hasValidCoordinates(ListingModel listing) {
    final lat = listing.latitude;
    final lng = listing.longitude;

    final isInRange = lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    final isNotZeroPoint = !(lat == 0 && lng == 0);

    return isInRange && isNotZeroPoint;
  }

  latlng.LatLng _fallbackPointFor(ListingModel listing) {
    final hash = listing.id.hashCode.abs();
    final radiusLat = 0.03;
    final radiusLng = 0.03;

    final latOffset = ((hash % 1000) / 1000.0 - 0.5) * 2 * radiusLat;
    final lngOffset = (((hash ~/ 1000) % 1000) / 1000.0 - 0.5) * 2 * radiusLng;

    return latlng.LatLng(
      _defaultLocation.latitude + latOffset,
      _defaultLocation.longitude + lngOffset,
    );
  }

  latlng.LatLng _markerPointFor(ListingModel listing) {
    if (_hasValidCoordinates(listing)) {
      return latlng.LatLng(listing.latitude, listing.longitude);
    }
    return _fallbackPointFor(listing);
  }

  List<Marker> _buildMarkers(List<ListingModel> listings) {
    return listings.map((listing) {
      final isSelected = _selectedListing?.id == listing.id;

      return Marker(
        point: _markerPointFor(listing),
        width: isSelected ? 46 : 38,
        height: isSelected ? 46 : 38,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedListing = listing;
            });
          },
          child: Icon(
            Icons.location_on,
            size: isSelected ? 42 : 34,
            color: isSelected ? Colors.blueAccent : Colors.red,
          ),
        ),
      );
    }).toList();
  }

  void _navigateToDetail(ListingModel listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ListingDetailScreen(listing: listing),
      ),
    );
  }

  void _fitBounds(List<ListingModel> listings) {
    if (listings.isEmpty) return;

    final points = listings.map(_markerPointFor).toList();

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

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(50),
      ),
    );
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
    return Scaffold(
      body: BlocBuilder<ListingBloc, ListingState>(
        builder: (context, state) {
          if (state.status == ListingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ListingStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ListingBloc>().add(const LoadListings());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final mapListings = state.listings;
          final markers = _buildMarkers(mapListings);

          if (mapListings.isNotEmpty &&
              _lastFittedMarkerCount != mapListings.length) {
            _lastFittedMarkerCount = mapListings.length;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _fitBounds(mapListings);
              }
            });
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _defaultLocation,
                  initialZoom: 12,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                    enableMultiFingerGestureRace: true,
                    pinchZoomThreshold: 0.1,
                    pinchMoveThreshold: 8.0,
                    pinchZoomWinGestures:
                        MultiFingerGesture.pinchZoom |
                        MultiFingerGesture.pinchMove,
                  ),
                  onPositionChanged: (camera, hasGesture) {
                    _currentZoom = camera.zoom;
                  },
                  onTap: (_, __) {
                    setState(() {
                      _selectedListing = null;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
              // Search bar overlay
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                child: _buildSearchBar(),
              ),
              // My location button
              Positioned(
                right: 16,
                bottom: _selectedListing != null ? 220 : 100,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    _mapController.move(_defaultLocation, 14);
                  },
                  child: Icon(
                    Icons.my_location,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: _selectedListing != null ? 290 : 170,
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
                      child: Icon(
                        Icons.remove,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              // Listing count badge
              Positioned(
                left: 16,
                bottom: _selectedListing != null ? 220 : 100,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${mapListings.length} places',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Selected listing card
              if (_selectedListing != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: _buildListingCard(_selectedListing!),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (query) {
          if (query.trim().isEmpty) {
            setState(() {
              _selectedListing = null;
            });
            return;
          }

          final lower = query.trim().toLowerCase();
          final currentListings = context.read<ListingBloc>().state.listings;
          final matched = currentListings.where((listing) {
            return listing.name.toLowerCase().contains(lower);
          }).toList();

          if (matched.isNotEmpty) {
            final first = matched.first;
            _mapController.move(_markerPointFor(first), 15);

            setState(() {
              _selectedListing = first;
            });
          }
        },
        decoration: InputDecoration(
          hintText: 'Search on map...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildListingCard(ListingModel listing) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToDetail(listing),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Container(
                width: 120,
                height: 120,
                color: Colors.grey[200],
                child: listing.imageUrl.isNotEmpty
                    ? Image.network(
                        listing.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        listing.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      listing.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.address,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (listing.rating > 0) ...[
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            listing.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'View',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _selectedListing = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.image, size: 32, color: Colors.grey[500]),
      ),
    );
  }
}
