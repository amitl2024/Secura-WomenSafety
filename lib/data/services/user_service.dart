import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:ai_women_safety/utils/logger_util.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all users
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return UserModel.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting user', e, stackTrace);
      return null;
    }
  }

  // Get reports by user ID
  Stream<QuerySnapshot> getUserReports(String userId) {
    return _firestore
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get alerts by user ID
  Stream<QuerySnapshot> getUserAlerts(String userId) {
    return _firestore
        .collection('emergency_alerts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}