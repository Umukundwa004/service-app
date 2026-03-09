import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class ListingService {
  final FirebaseFirestore _firestore;
  final String _collection = 'listings';

  ListingService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get all listings as a stream
  // Real-time stream of all listings for directory and map views.
  Stream<List<ListingModel>> getListingsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ListingModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get listings by category as a stream
  Stream<List<ListingModel>> getListingsByCategoryStream(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ListingModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get user's listings as a stream
  Stream<List<ListingModel>> getUserListingsStream(String userId) {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      final listings = snapshot.docs
          .map((doc) => ListingModel.fromMap(doc.data(), doc.id))
          .where((listing) => listing.userId == userId)
          .toList();

      listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return listings;
    });
  }

  // Get a single listing by ID
  Future<ListingModel?> getListingById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return ListingModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Add a new listing
  // Create listing document in Firestore using generated/assigned ID.
  Future<String> addListing(ListingModel listing) async {
    if (listing.userId.trim().isEmpty) {
      throw Exception('Listing owner is missing. Please sign in again.');
    }

    await _firestore
        .collection(_collection)
        .doc(listing.id)
        .set(listing.toMap());
    return listing.id;
  }

  // Update a listing
  // Update listing fields and refresh updatedAt timestamp.
  Future<void> updateListing(ListingModel listing) async {
    await _firestore
        .collection(_collection)
        .doc(listing.id)
        .update(listing.copyWith(updatedAt: DateTime.now()).toMap());
  }

  // Delete a listing
  // Remove listing document by ID.
  Future<void> deleteListing(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Search listings by name (local filtering - for real-time search)
  // Client-side text search across listing name, category, and description.
  List<ListingModel> searchListings(List<ListingModel> listings, String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return listings;
    final lowerQuery = normalizedQuery.toLowerCase();
    return listings.where((listing) {
      return listing.name.toLowerCase().contains(lowerQuery) ||
          listing.description.toLowerCase().contains(lowerQuery) ||
          listing.address.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Filter listings by category (local filtering)
  // Client-side category filter used by ListingBloc.
  List<ListingModel> filterByCategory(
    List<ListingModel> listings,
    String? category,
  ) {
    final normalizedCategory = category?.trim().toLowerCase();

    if (normalizedCategory == null ||
        normalizedCategory.isEmpty ||
        normalizedCategory == 'all') {
      return listings;
    }

    return listings
        .where(
          (listing) => listing.category.toLowerCase() == normalizedCategory,
        )
        .toList();
  }

  // Get all listings (one-time fetch)
  Future<List<ListingModel>> getAllListings() async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ListingModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}






