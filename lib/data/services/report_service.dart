import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report_model.dart';
import 'supabase_storage_service.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SupabaseStorageService _supabaseStorageService = SupabaseStorageService();

  // Initialize services
  Future<void> initialize() async {
    // Initialize Supabase storage with configuration from .env
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    
    if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
      await _supabaseStorageService.initialize(supabaseUrl, supabaseKey);
      // Supabase Storage initialized
    } else {
      // Supabase configuration missing in .env file
    }
  }

  // Submit a new report with images
  Future<ReportModel?> submitReport({
    required String title,
    required String description,
    required bool isAnonymous,
    List<File>? images,
    String? category,
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get user details from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      final userName = isAnonymous ? 'Anonymous' : (userData['name'] as String? ?? user.displayName ?? 'User');
      final userEmail = isAnonymous ? 'anonymous@example.com' : user.email ?? '';

      // Upload images to Supabase Storage if provided
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        imageUrls = await _supabaseStorageService.uploadImages(images);
      }

      // Create report model
      final report = ReportModel(
        userId: user.uid,
        userName: userName,
        userEmail: userEmail,
        title: title,
        description: description,
        category: category,
        timestamp: DateTime.now(),
        isAnonymous: isAnonymous,
        location: location,
        latitude: latitude,
        longitude: longitude,
        imageUrls: imageUrls,
      );

      // Save report to Firestore
      final docRef = await _firestore.collection('reports').add(report.toJson());
      final savedReport = report.copyWith(id: docRef.id);

      // Report submitted successfully with ID: ${docRef.id}
      return savedReport;
    } catch (e) {
      // Error submitting report: $e
      return null;
    }
  }

  // Get all reports (for admin)
  Stream<List<ReportModel>> getAllReports() {
    return _firestore
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ReportModel.fromJson(doc.data(), id: doc.id);
          }).toList();
        });
  }

  // Get reports by current user
  Stream<List<ReportModel>> getUserReports() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('reports')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ReportModel.fromJson(doc.data(), id: doc.id);
          }).toList();
        });
  }

  // Get report by ID
  Future<ReportModel?> getReportById(String reportId) async {
    try {
      final docSnapshot = await _firestore.collection('reports').doc(reportId).get();
      if (docSnapshot.exists) {
        return ReportModel.fromJson(docSnapshot.data()!, id: docSnapshot.id);
      }
      return null;
    } catch (e) {
      // Error getting report: $e
      return null;
    }
  }

  // Update report status (for admin)
  Future<bool> updateReportStatus(String reportId, String status, {String? adminNotes}) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': status,
        'adminNotes': adminNotes,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      // Report $reportId status updated to $status
      return true;
    } catch (e) {
      // Error updating report status: $e
      return false;
    }
  }

  // Delete a report
  Future<bool> deleteReport(String reportId) async {
    try {
      // First get the report to delete associated images
      final report = await getReportById(reportId);
      if (report != null) {
        // Delete images from Supabase Storage
        for (final imageUrl in report.imageUrls) {
          // Extract the file path from the URL
          final uri = Uri.parse(imageUrl);
          final filePath = uri.pathSegments.skipWhile((segment) => segment != 'storage').skip(2).join('/');
          await _supabaseStorageService.deleteImage(filePath);
        }
      }

      // Delete report from Firestore
      await _firestore.collection('reports').doc(reportId).delete();
      // Report $reportId deleted successfully
      return true;
    } catch (e) {
      // Error deleting report: $e
      return false;
    }
  }

  // Get report statistics for dashboard
  Future<Map<String, dynamic>> getReportStatistics() async {
    try {
      final now = DateTime.now();
      final lastWeek = now.subtract(const Duration(days: 7));
      
      // Total reports
      final totalReportsQuery = await _firestore.collection('reports').count().get();
      final totalReports = totalReportsQuery.count;
      
      // Reports by status
      final pendingReportsQuery = await _firestore.collection('reports')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      final resolvedReportsQuery = await _firestore.collection('reports')
          .where('status', isEqualTo: 'resolved')
          .count()
          .get();
      final inProgressReportsQuery = await _firestore.collection('reports')
          .where('status', isEqualTo: 'in_progress')
          .count()
          .get();
      
      // Recent reports (last 7 days)
      final recentReportsQuery = await _firestore.collection('reports')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(lastWeek))
          .count()
          .get();
      
      return {
        'totalReports': totalReports,
        'pendingReports': pendingReportsQuery.count,
        'resolvedReports': resolvedReportsQuery.count,
        'inProgressReports': inProgressReportsQuery.count,
        'recentReports': recentReportsQuery.count,
      };
    } catch (e) {
      // Error getting report statistics: $e
      return {
        'totalReports': 0,
        'pendingReports': 0,
        'resolvedReports': 0,
        'inProgressReports': 0,
        'recentReports': 0,
      };
    }
  }
}