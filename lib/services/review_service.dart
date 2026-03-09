import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore;
  final String _collection = 'reviews';

  ReviewService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get reviews for a listing as a stream
  Stream<List<ReviewModel>> getReviewsForListingStream(String listingId) {
    return _firestore
        .collection(_collection)
        .where('listingId', isEqualTo: listingId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get user's reviews as a stream
  Stream<List<ReviewModel>> getUserReviewsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Add a review and update listing's rating
  Future<String> addReview(ReviewModel review) async {
    // Add the review
    final docRef = await _firestore.collection(_collection).add(review.toMap());

    // Update listing rating
    await _updateListingRating(review.listingId);

    return docRef.id;
  }

  // Update a review
  Future<void> updateReview(ReviewModel review) async {
    await _firestore
        .collection(_collection)
        .doc(review.id)
        .update(review.toMap());

    // Update listing rating
    await _updateListingRating(review.listingId);
  }

  // Delete a review
  Future<void> deleteReview(String reviewId, String listingId) async {
    await _firestore.collection(_collection).doc(reviewId).delete();

    // Update listing rating
    await _updateListingRating(listingId);
  }

  // Check if user has already reviewed a listing
  Future<bool> hasUserReviewed(String userId, String listingId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('listingId', isEqualTo: listingId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Get user's review for a specific listing
  Future<ReviewModel?> getUserReviewForListing(
    String userId,
    String listingId,
  ) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('listingId', isEqualTo: listingId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return ReviewModel.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    }
    return null;
  }

  // Update listing's average rating
  Future<void> _updateListingRating(String listingId) async {
    final reviews = await _firestore
        .collection(_collection)
        .where('listingId', isEqualTo: listingId)
        .get();

    if (reviews.docs.isEmpty) {
      await _firestore.collection('listings').doc(listingId).update({
        'rating': 0.0,
        'reviewCount': 0,
      });
      return;
    }

    double totalRating = 0;
    for (var doc in reviews.docs) {
      totalRating += (doc.data()['rating'] ?? 0.0).toDouble();
    }

    final averageRating = totalRating / reviews.docs.length;

    await _firestore.collection('listings').doc(listingId).update({
      'rating': averageRating,
      'reviewCount': reviews.docs.length,
    });
  }
}
