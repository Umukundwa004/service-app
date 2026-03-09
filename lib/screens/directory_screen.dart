import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/listing/listing_bloc.dart';
import '../bloc/listing/listing_event.dart';
import '../bloc/listing/listing_state.dart';
import '../models/category_model.dart';
import '../models/listing_model.dart';
import '../widgets/listing_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/search_bar_widget.dart';
import 'listing_detail_screen.dart';
import 'profile_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  String get searchName => _searchController.text.trim();

  @override
  void initState() {
    super.initState();
    context.read<ListingBloc>().add(const LoadListings());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Dispatch search event on text updates.
  void _onSearchChanged(String query) {
    setState(() {});
    context.read<ListingBloc>().add(SearchListings(query));
  }

  // Toggle and dispatch selected category filter.
  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category == _selectedCategory ? null : category;
    });
    context.read<ListingBloc>().add(
      FilterListingsByCategory(_selectedCategory),
    );
  }

  // Open detail page from the directory list.
  void _navigateToDetail(ListingModel listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ListingDetailScreen(listing: listing),
      ),
    );
  }

  Future<void> _openProfile() async {
    final authState = context.read<AuthBloc>().state;
    if (authState.status != AuthStatus.authenticated ||
        authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to view your profile.')),
      );
      return;
    }

    final user = authState.user!;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          userEmail: user.email,
          displayName: user.displayName,
          photoUrl: user.photoUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryFilters(),
            _buildUserFilesSearchResults(),
            Expanded(child: _buildListingsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover Kigali',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find services & places in Kigali',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              IconButton(
                onPressed: _openProfile,
                icon: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.deepPurple.shade100,
                  child: Icon(Icons.person, color: Colors.deepPurple.shade700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SearchBarWidget(
        controller: _searchController,
        // Search bar is wired to ListingBloc filtering.
        onChanged: _onSearchChanged,
        hintText: 'Search services, places...',
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = CategoryModel.defaultCategories;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Wrap(
        spacing: 0,
        runSpacing: 6,
        children: [
          CategoryChip(
            label: 'All',
            icon: Icons.apps,
            isSelected: _selectedCategory == null,
            onTap: () => _onCategorySelected(null),
          ),
          ...categories.map(
            (category) => CategoryChip(
              label: category.name,
              icon: _getCategoryIcon(category.icon),
              isSelected: _selectedCategory == category.id,
              // Category chips trigger bloc filter updates.
              onTap: () => _onCategorySelected(category.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserFilesSearchResults() {
    if (searchName.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SizedBox(
        height: 180,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('user_files')
              .where('fileName', isGreaterThanOrEqualTo: searchName)
              .where('fileName', isLessThanOrEqualTo: '$searchName\uf8ff')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const SizedBox.shrink();
            }

            return ListView(
              shrinkWrap: true,
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return ListTile(
                  title: Text(data['fileName']),
                  subtitle: Text(data['fileType'] ?? 'Unknown'),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'local_police':
        return Icons.local_police;
      case 'local_library':
        return Icons.local_library;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'park':
        return Icons.park;
      case 'attractions':
        return Icons.attractions;
      case 'business':
        return Icons.business;
      default:
        return Icons.category;
    }
  }

  Widget _buildListingsList() {
    return BlocBuilder<ListingBloc, ListingState>(
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

        final listings = state.filteredListings;

        if (listings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No listings found',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search or category',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ListingBloc>().add(const LoadListings());
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              return ListingCard(
                listing: listing,
                onTap: () => _navigateToDetail(listing),
              );
            },
          ),
        );
      },
    );
  }
}





