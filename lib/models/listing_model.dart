import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ListingModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final String address;
  final String phone;
  final String email;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double rating;
  final int reviewCount;
  final String openingHours;
  final List<String> amenities;

  const ListingModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.address,
    required this.phone,
    required this.email,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.openingHours = '',
    this.amenities = const [],
  });

  factory ListingModel.fromMap(Map<String, dynamic> map, String id) {
    return ListingModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      userId: map['userId'] ?? map['ownerId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      openingHours: map['openingHours'] ?? '',
      amenities: List<String>.from(map['amenities'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'address': address,
      'phone': phone,
      'email': email,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'userId': userId,
      'ownerId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'rating': rating,
      'reviewCount': reviewCount,
      'openingHours': openingHours,
      'amenities': amenities,
    };
  }

  ListingModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? address,
    String? phone,
    String? email,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? reviewCount,
    String? openingHours,
    List<String>? amenities,
  }) {
    return ListingModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      openingHours: openingHours ?? this.openingHours,
      amenities: amenities ?? this.amenities,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    category,
    address,
    phone,
    email,
    imageUrl,
    latitude,
    longitude,
    userId,
    createdAt,
    updatedAt,
    rating,
    reviewCount,
    openingHours,
    amenities,
  ];
}
