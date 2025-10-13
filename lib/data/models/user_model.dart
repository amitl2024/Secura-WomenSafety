import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profilePicUrl;
  final DateTime createdAt;
  final bool locationSharing;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePicUrl,
    required this.createdAt,
    required this.locationSharing,
  });

  // Convert model to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profilePicUrl': profilePicUrl ?? '',
      'createdAt': Timestamp.fromDate(createdAt),
      'locationSharing': locationSharing,
    };
  }

  // Create model from Firebase document
  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      profilePicUrl: json['profilePicUrl'] as String?,
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      locationSharing: json['locationSharing'] as bool? ?? true,
    );
  }
}