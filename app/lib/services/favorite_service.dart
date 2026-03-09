import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/favorite_model.dart';
import '../models/listing_model.dart';

class FavoriteService {
  final FirebaseFirestore _firestore;
  final String _collection = 'favorites';

  FavoriteService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get user's favorites as a stream
  Stream<List<FavoriteModel>> getUserFavoritesStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FavoriteModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get user's favorite listing IDs as a stream
  Stream<Set<String>> getUserFavoriteIdsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data()['listingId'] as String)
              .toSet(),
        );
  }

  // Get favorite listings with full listing data
  Future<List<ListingModel>> getFavoriteListings(String userId) async {
    final favoritesSnapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();

    final listingIds = favoritesSnapshot.docs
        .map((doc) => doc.data()['listingId'] as String)
        .toList();

    if (listingIds.isEmpty) return [];

    // Firestore 'in' query supports max 10 items at a time
    final List<ListingModel> listings = [];
    for (var i = 0; i < listingIds.length; i += 10) {
      final batch = listingIds.skip(i).take(10).toList();
      final listingsSnapshot = await _firestore
          .collection('listings')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      listings.addAll(
        listingsSnapshot.docs.map(
          (doc) => ListingModel.fromMap(doc.data(), doc.id),
        ),
      );
    }

    return listings;
  }

  // Add a listing to favorites
  Future<String> addFavorite(String userId, String listingId) async {
    // Check if already favorited
    final existing = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('listingId', isEqualTo: listingId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id; // Already favorited
    }

    final favorite = FavoriteModel(
      id: '',
      userId: userId,
      listingId: listingId,
      createdAt: DateTime.now(),
    );

    final docRef = await _firestore
        .collection(_collection)
        .add(favorite.toMap());
    return docRef.id;
  }

  // Remove a listing from favorites
  Future<void> removeFavorite(String userId, String listingId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('listingId', isEqualTo: listingId)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String userId, String listingId) async {
    final isFavorite = await isFavorited(userId, listingId);

    if (isFavorite) {
      await removeFavorite(userId, listingId);
      return false;
    } else {
      await addFavorite(userId, listingId);
      return true;
    }
  }

  // Check if a listing is favorited by user
  Future<bool> isFavorited(String userId, String listingId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('listingId', isEqualTo: listingId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Get favorite count for a listing
  Future<int> getFavoriteCount(String listingId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('listingId', isEqualTo: listingId)
        .get();

    return snapshot.docs.length;
  }
}
