import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;
  final DateTime createdAt;
  final bool notificationsEnabled;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    required this.createdAt,
    this.notificationsEnabled = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'notificationsEnabled': notificationsEnabled,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    bool? notificationsEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    createdAt,
    notificationsEnabled,
  ];
}
