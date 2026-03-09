import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/my_listings/my_listings_bloc.dart';
import '../bloc/my_listings/my_listings_event.dart';
import '../bloc/my_listings/my_listings_state.dart';
import '../models/listing_model.dart';
import 'add_edit_listing_screen.dart';
import 'listing_detail_screen.dart';

class MyListingsScreen extends StatefulWidget {
  final String userId;

  const MyListingsScreen({super.key, required this.userId});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MyListingsBloc>().add(LoadMyListings(widget.userId));
  }

  void _navigateToDetail(ListingModel listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ListingDetailScreen(listing: listing),
      ),
    );
  }

  void _navigateToAddListing() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditListingScreen(userId: widget.userId),
      ),
    );
  }

  void _navigateToEditListing(ListingModel listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddEditListingScreen(userId: widget.userId, listing: listing),
      ),
    );
  }

  void _deleteListing(String listingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<MyListingsBloc>().add(DeleteMyListing(listingId));
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Listings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<MyListingsBloc, MyListingsState>(
        builder: (context, state) {
          if (state.status == MyListingsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == MyListingsStatus.error) {
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
                      context.read<MyListingsBloc>().add(
                        LoadMyListings(widget.userId),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.listings.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<MyListingsBloc>().add(LoadMyListings(widget.userId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.listings.length,
              itemBuilder: (context, index) {
                final listing = state.listings[index];
                return _buildMyListingCard(listing);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddListing,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Listing'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No listings yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first listing to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddListing,
            icon: const Icon(Icons.add),
            label: const Text('Add Listing'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyListingCard(ListingModel listing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          InkWell(
            onTap: () => _navigateToDetail(listing),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                  ),
                  child: Container(
                    width: 100,
                    height: 100,
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
                        Text(
                          listing.address,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _navigateToEditListing(listing),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                    ),
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey[300]),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _deleteListing(listing.id),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ],
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
