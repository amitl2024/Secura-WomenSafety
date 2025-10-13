import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase/supabase.dart';

class SupabaseStorageService {
  // Singleton instance
  static final SupabaseStorageService _instance = 
      SupabaseStorageService._internal();
  factory SupabaseStorageService() => _instance;
  SupabaseStorageService._internal();

  // Supabase client
  SupabaseClient? _supabaseClient;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize Supabase client
  Future<void> initialize(String supabaseUrl, String supabaseKey) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    _supabaseClient = Supabase.instance.client;
  }

  // Get Supabase client (ensure it's initialized)
  SupabaseClient get supabaseClient {
    if (_supabaseClient == null) {
      throw Exception('Supabase client not initialized');
    }
    return _supabaseClient!;
  }

  // Upload a single image file to Supabase storage
  Future<String?> uploadImage(File imageFile, {
    String bucketName = 'incident_images',
    String? customFileName,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      final fileName = customFileName ?? 'reports/${user.uid}/$timestamp$fileExtension';

      // Upload file to Supabase storage
      await supabaseClient.storage.from(bucketName).upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final url = supabaseClient.storage.from(bucketName).getPublicUrl(fileName);
      return url;
    } catch (e) {
      // Error uploading image to Supabase storage: $e
      return null;
    }
  }

  // Upload multiple image files to Supabase storage
  Future<List<String>> uploadImages(List<File> imageFiles, {
    String bucketName = 'incident_images',
  }) async {
    final List<String> urls = [];
    for (final imageFile in imageFiles) {
      final url = await uploadImage(imageFile, bucketName: bucketName);
      if (url != null) {
        urls.add(url);
      }
    }
    return urls;
  }

  // Delete an image from Supabase storage
  Future<bool> deleteImage(String filePath, {
    String bucketName = 'incident_images',
  }) async {
    try {
      await supabaseClient.storage.from(bucketName).remove([filePath]);
      return true;
    } catch (e) {
      // Error deleting image from Supabase storage: $e
      return false;
    }
  }

  // Check if an image exists in Supabase storage
  Future<bool> doesImageExist(String filePath, {
    String bucketName = 'incident_images',
  }) async {
    try {
        // Attempt to list files in the directory
        final List<FileObject> result = await supabaseClient.storage.from(bucketName).list(
              path: path.dirname(filePath),
            );
        
        // Check if the file exists in the results
        return result.any((file) => file.name == path.basename(filePath));
      } catch (e) {
        // If any error occurs, assume the image doesn't exist
        return false;
      }
  }

  // Get bucket details
  Future<Map<String, dynamic>?> getBucketDetails(String bucketName) async {
    try {
      final bucket = await supabaseClient.storage.getBucket(bucketName);
      return {
        'name': bucket.name,
        'public': bucket.public,
        'createdAt': bucket.createdAt,
        'updatedAt': bucket.updatedAt,
      };
    } catch (e) {
      // Error getting bucket details: $e
      return null;
    }
  }
}