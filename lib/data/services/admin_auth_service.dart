import 'package:ai_women_safety/utils/logger_util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminAuthService {
  // Get admin credentials from environment variables
  // Fallback to default values only in development (not recommended for production)
  static String get _adminEmail {
    final email = dotenv.env['ADMIN_EMAIL'];
    if (email != null && email.isNotEmpty) {
      return email;
    }
    // Fallback for development - should be removed in production
    AppLogger.warning(
      'ADMIN_EMAIL not found in .env, using default (development only)',
    );
    return 'admin@gmail.com';
  }

  static String get _adminPassword {
    final password = dotenv.env['ADMIN_PASSWORD'];
    if (password != null && password.isNotEmpty) {
      return password;
    }
    // Fallback for development - should be removed in production
    AppLogger.warning(
      'ADMIN_PASSWORD not found in .env, using default (development only)',
    );
    return 'admin123';
  }

  // Static variables to maintain session (in-memory)
  static bool _isLoggedIn = false;
  static DateTime? _loginTime;

  // Check if credentials are valid
  static bool validateCredentials(String email, String password) {
    return email == _adminEmail && password == _adminPassword;
  }

  // Admin login
  static Future<bool> login(String email, String password) async {
    if (validateCredentials(email, password)) {
      // Store admin login state in memory
      _isLoggedIn = true;
      _loginTime = DateTime.now();
      AppLogger.info("✅ Admin login successful - session saved");
      return true;
    }
    return false;
  }

  // Check if admin is logged in
  static Future<bool> isAdminLoggedIn() async {
    AppLogger.debug("Admin login status: $_isLoggedIn");
    return _isLoggedIn;
  }

  // Admin logout
  static Future<void> logout() async {
    try {
      _isLoggedIn = false;
      _loginTime = null;
      AppLogger.info("✅ Admin logout successful - session cleared");
    } catch (e, stackTrace) {
      AppLogger.error("Error during admin logout", e, stackTrace);
    }
  }

  // Get admin login time
  static Future<DateTime?> getAdminLoginTime() async {
    return _loginTime;
  }
}
