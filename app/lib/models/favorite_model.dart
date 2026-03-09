import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class FavoriteModel extends Equatable {
  final String id;
  final String userId;
  final String listingId;
  final DateTime createdAt;

  const FavoriteModel({
    required this.id,
    required this.userId,
    required this.listingId,
    required this.createdAt,
  });

  factory FavoriteModel.fromMap(Map<String, dynamic> map, String id) {
    return FavoriteModel(
      id: id,
      userId: map['userId'] ?? '',
      listingId: map['listingId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'listingId': listingId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [id, userId, listingId, createdAt];
}
