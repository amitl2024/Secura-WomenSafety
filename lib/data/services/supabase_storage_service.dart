import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase/supabase.dart';
import 'package:ai_women_safety/utils/logger_util.dart';

class SupabaseStorageService {
  // Singleton instance
  static final SupabaseStorageService _instance =
      SupabaseStorageService._internal();
  factory SupabaseStorageService() => _instance;
  SupabaseStorageService._internal();

  // Supabase client
  SupabaseClient? _supabaseClient;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isInitialized = false;

  // Initialize Supabase client
  Future<void> initialize(String supabaseUrl, String supabaseKey) async {
    try {
      if (_isInitialized) {
        AppLogger.info('Supabase already initialized');
        _supabaseClient = Supabase.instance.client;
        return;
      }

      AppLogger.info('Initializing Supabase...');
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
        debug: false, // Disable built-in debug logs in favor of our AppLogger
      );
      _supabaseClient = Supabase.instance.client;
      _isInitialized = true;
      AppLogger.info('✅ Supabase initialized successfully');
    } catch (e, stackTrace) {
      // Check if it's the "already initialized" error which can happen in hot restarts
      if (e.toString().contains('already') ||
          Supabase.instance.client != null) {
        _supabaseClient = Supabase.instance.client;
        _isInitialized = true;
        AppLogger.info('⚠️ Supabase reused existing instance (Hot Restart?)');
      } else {
        AppLogger.error('❌ Supabase initialization failed', e, stackTrace);
        rethrow;
      }
    }
  }

  // Get Supabase client (ensure it's initialized)
  SupabaseClient get supabaseClient {
    if (_supabaseClient == null) {
      throw Exception(
        'Supabase client not initialized. Call initialize() first.',
      );
    }
    return _supabaseClient!;
  }

  // Upload a single image file to Supabase storage
  Future<String?> uploadImage(
    File imageFile, {
    String bucketName = 'incident_media',
    String? customFileName,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        AppLogger.warning('Upload attempted without Firebase Auth user');
        // Proceeding might fail if RLS requires auth, but for public buckets it might work.
        // Best practice: proceed and let Supabase reject if needed, or enforce logic here.
      }

      // Generate unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      // Ensure clean filename just in case
      final safeUid = user?.uid ?? 'anonymous';
      final fileName =
          customFileName ?? 'reports/$safeUid/$timestamp$fileExtension';

      AppLogger.debug('Uploading to Supabase: $bucketName/$fileName');

      // Attempt upload
      try {
        await supabaseClient.storage
            .from(bucketName)
            .upload(
              fileName,
              imageFile,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );
      } catch (e) {
        // If bucket not found, try to create it
        if (e.toString().contains('Bucket not found') ||
            e.toString().contains('404')) {
          AppLogger.info(
            'Bucket "$bucketName" not found. Attempting to create...',
          );
          try {
            await supabaseClient.storage.createBucket(
              bucketName,
              const BucketOptions(public: true),
            );
            AppLogger.info(
              'Bucket "$bucketName" created successfully. Retrying upload...',
            );
            // Retry upload
            await supabaseClient.storage
                .from(bucketName)
                .upload(
                  fileName,
                  imageFile,
                  fileOptions: const FileOptions(
                    cacheControl: '3600',
                    upsert: true,
                  ),
                );
          } catch (createError) {
            AppLogger.error(
              'Failed to create bucket or retry upload',
              createError,
            );
            rethrow;
          }
        } else {
          rethrow;
        }
      }

      // Get public URL
      final url = supabaseClient.storage
          .from(bucketName)
          .getPublicUrl(fileName);
      AppLogger.info('✅ Image uploaded: $url');
      return url;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Error uploading image to Supabase', e, stackTrace);
      return null;
    }
  }

  // Upload multiple image files to Supabase storage
  Future<List<String>> uploadImages(
    List<File> imageFiles, {
    String bucketName = 'incident_media',
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
  Future<bool> deleteImage(
    String filePath, {
    String bucketName = 'incident_media',
  }) async {
    try {
      await supabaseClient.storage.from(bucketName).remove([filePath]);
      AppLogger.info('Deleted image: $filePath');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting image from Supabase', e, stackTrace);
      return false;
    }
  }

  // Check if an image exists in Supabase storage
  Future<bool> doesImageExist(
    String filePath, {
    String bucketName = 'incident_media',
  }) async {
    try {
      // Attempt to list files in the directory
      final List<FileObject> result = await supabaseClient.storage
          .from(bucketName)
          .list(path: path.dirname(filePath));

      // Check if the file exists in the results
      return result.any((file) => file.name == path.basename(filePath));
    } catch (e) {
      // If any error occurs, assume the image doesn't exist
      return false;
    }
  }
}
