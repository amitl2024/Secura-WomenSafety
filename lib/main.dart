import 'package:ai_women_safety/Ui/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'Ui/screens/auth/login_screen.dart';
import 'Ui/screens/auth/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_women_safety/data/services/location_service.dart';
import 'package:ai_women_safety/data/services/report_service.dart';
import 'package:ai_women_safety/utils/logger_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables if .env file exists
  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    AppLogger.warning('⚠️ .env file not found, using default configuration', e);
  }

  // Initialize Firebase
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
      // Check if Crashlytics is available before recording
      // This avoids the 'isCrashlyticsCollectionEnabled' assertion error
      // when running in environments where Crashlytics might not be fully ready
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    } catch (e) {
      // Silently ignore Crashlytics errors in dev/debug
      if (kDebugMode) {
        print("Crashlytics error ignored: $e");
      }
    }
  };

  // Pass non-fatal errors from the framework to Crashlytics
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

  // Initialize Crashlytics
  try {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );
  } catch (e) {
    if (kDebugMode) {
      print("Crashlytics collection set ignored: $e");
    }
  }

  AppLogger.info('✅ Firebase Crashlytics initialized');

  // Initialize location service (request permissions)
  AppLogger.info('🚀 Initializing location service...');
  try {
    await LocationService.requestLocationPermission();
    AppLogger.info('✅ Location service initialized');
  } catch (e, stackTrace) {
    AppLogger.error('⚠️ Location service initialization failed', e, stackTrace);
  }

  // Initialize report service with Supabase integration
  AppLogger.info('🚀 Initializing report service...');
  try {
    await ReportService().initialize();
    AppLogger.info('✅ Report service initialized');
  } catch (e, stackTrace) {
    AppLogger.error('⚠️ Report service initialization failed', e, stackTrace);
  }

  // Check if user is logged in
  final user = FirebaseAuth.instance.currentUser;

  String initialRoute;
  if (user != null) {
    initialRoute = '/home';
  } else {
    initialRoute = '/login';
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secura - Women Safety App',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
