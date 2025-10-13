import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportModel {
  final String? id;
  final String userId;
  final String userName;
  final String userEmail;
  final String title;
  final String description;
  final String? category;
  final DateTime timestamp;
  final bool isAnonymous;
  final String? location;
  final double? latitude;
  final double? longitude;
  final List<String> imageUrls; // This will store Supabase image URLs
  final String status;
  final String? adminNotes;
  final DateTime? updatedAt;

  ReportModel({
    this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.title,
    required this.description,
    this.category,
    required this.timestamp,
    required this.isAnonymous,
    this.location,
    this.latitude,
    this.longitude,
    this.imageUrls = const [],
    this.status = 'pending',
    this.adminNotes,
    this.updatedAt,
  });

  // Convert model to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'title': title,
      'description': description,
      'category': category,
      'timestamp': Timestamp.fromDate(timestamp),
      'isAnonymous': isAnonymous,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'status': status,
      'adminNotes': adminNotes,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create model from Firebase document
  factory ReportModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return ReportModel(
      id: id ?? json['id'] as String?,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String?,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      isAnonymous: json['isAnonymous'] as bool,
      location: json['location'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      status: json['status'] as String? ?? 'pending',
      adminNotes: json['adminNotes'] as String?,
      updatedAt:
          json['updatedAt'] != null
              ? (json['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  // Create a copy of the model with updated fields
  ReportModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? title,
    String? description,
    String? category,
    DateTime? timestamp,
    bool? isAnonymous,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    String? status,
    String? adminNotes,
    DateTime? updatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
