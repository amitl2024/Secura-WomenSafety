import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:ai_women_safety/Ui/screens/admin/admin_panel_screen.dart';
import 'package:ai_women_safety/Ui/screens/admin/admin_login_screen.dart';
import 'package:ai_women_safety/data/services/admin_auth_service.dart';
import 'package:ai_women_safety/utils/logger_util.dart';
import 'package:ai_women_safety/data/services/report_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables if .env file exists
  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    AppLogger.warning('⚠️ .env file not found, using default configuration', e);
  }

  // Initialize Firebase
  // Note: For desktop, make sure firebase_core_desktop is configured if needed,
  // or use the web/custom options as in main.dart
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
        authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'],
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'],
        measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'],
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Initialize Firebase Crashlytics
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    try {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    } catch (e) {
      if (kDebugMode) {
        print("Crashlytics error ignored: $e");
      }
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    try {
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
    } catch (e) {
      if (kDebugMode) print("Crashlytics recordError ignored: $e");
    }
    return true;
  };

  // Initialize services
  AppLogger.info('🚀 Initializing services for Admin Panel...');
  try {
    // Admin panel might not need location, but ReportService might
    // ReportService init
    await ReportService().initialize();
    AppLogger.info('✅ Report service initialized');
  } catch (e, stackTrace) {
    AppLogger.error('⚠️ Service initialization failed', e, stackTrace);
  }

  // Check login status
  final isAdminLoggedIn = await AdminAuthService.isAdminLoggedIn();
  String initialRoute = isAdminLoggedIn ? '/admin' : '/login';

  runApp(PoliceAdminApp(initialRoute: initialRoute));
}

class PoliceAdminApp extends StatelessWidget {
  final String initialRoute;
  const PoliceAdminApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Police Admin Panel',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      routes: {
        '/login': (context) => const AdminLoginScreen(),
        '/admin': (context) => const AdminPanelScreen(),
      },
    );
  }
}
