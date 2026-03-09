import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class ListingService {
  final FirebaseFirestore _firestore;
  final String _collection = 'listings';

  ListingService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get all listings as a stream
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
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ListingModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
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
  Future<String> addListing(ListingModel listing) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(listing.toMap());
    return docRef.id;
  }

  // Update a listing
  Future<void> updateListing(ListingModel listing) async {
    await _firestore
        .collection(_collection)
        .doc(listing.id)
        .update(listing.copyWith(updatedAt: DateTime.now()).toMap());
  }

  // Delete a listing
  Future<void> deleteListing(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Search listings by name (local filtering - for real-time search)
  List<ListingModel> searchListings(List<ListingModel> listings, String query) {
    if (query.isEmpty) return listings;
    final lowerQuery = query.toLowerCase();
    return listings.where((listing) {
      return listing.name.toLowerCase().contains(lowerQuery) ||
          listing.description.toLowerCase().contains(lowerQuery) ||
          listing.address.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Filter listings by category (local filtering)
  List<ListingModel> filterByCategory(
    List<ListingModel> listings,
    String? category,
  ) {
    if (category == null || category.isEmpty || category == 'all') {
      return listings;
    }
    return listings.where((listing) => listing.category == category).toList();
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
