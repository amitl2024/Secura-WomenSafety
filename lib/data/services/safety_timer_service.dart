import 'dart:async';
import 'package:ai_women_safety/data/services/location_service.dart';
import 'package:ai_women_safety/data/services/emergency_contact_service.dart';
import 'package:ai_women_safety/data/services/sms_service.dart'; // Import top-level functions
import 'package:ai_women_safety/data/services/admin_panel_service.dart';
import 'package:ai_women_safety/data/models/emergency_contact.dart';
import 'package:geolocator/geolocator.dart';

class SafetyTimerService {
  static final SafetyTimerService _instance = SafetyTimerService._internal();
  factory SafetyTimerService() => _instance;
  SafetyTimerService._internal();

  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;
  String _userName = "";

  // Callback for timer updates
  Function(int seconds)? onTimerUpdate;
  // Callback for timer complete
  Function()? onTimerComplete;
  // Callback for timer stopped
  Function()? onTimerStopped;

  // Getters
  bool get isTimerRunning => _isTimerRunning;
  int get remainingSeconds => _remainingSeconds;
  String get formattedTime {
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Set user name
  void setUserName(String name) {
    _userName = name;
  }

  // Start the safety timer
  Future<void> startTimer(int minutes) async {
    // Validate timer duration (1-15 minutes)
    if (minutes < 1 || minutes > 15) {
      throw Exception('Timer duration must be between 1 and 15 minutes');
    }

    // Stop any existing timer
    stopTimer();

    _remainingSeconds = minutes * 60;
    _isTimerRunning = true;

    print('⏱️ Safety timer started for $minutes minutes');

    // Notify listeners about the timer start
    if (onTimerUpdate != null) {
      onTimerUpdate!(_remainingSeconds);
    }

    // Start the countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        // Notify listeners about the timer update
        if (onTimerUpdate != null) {
          onTimerUpdate!(_remainingSeconds);
        }
      } else {
        // Timer completed
        timer.cancel();
        _isTimerRunning = false;
        print('⏱️ Safety timer completed - sending emergency alert!');

        // Send emergency alert automatically
        _sendEmergencyAlert();

        // Notify listeners about the timer completion
        if (onTimerComplete != null) {
          onTimerComplete!();
        }
      }
    });
  }

  // Stop the safety timer
  void stopTimer() {
    if (_isTimerRunning && _timer != null) {
      _timer?.cancel();
      _isTimerRunning = false;
      print('⏱️ Safety timer stopped');

      // Notify listeners about the timer stop
      if (onTimerStopped != null) {
        onTimerStopped!();
      }
    }
  }

  // Send emergency alert when timer completes
  Future<void> _sendEmergencyAlert() async {
    try {
      print('🚨 Automatically sending emergency alert from safety timer...');

      // Check SMS permissions first
      bool hasSmsPermission = await checkSmsPermissions();
      if (!hasSmsPermission) {
        print('❌ SMS permission required for emergency alert.');
        return;
      }

      // Get current location
      Position? position = await LocationService.getCurrentLocation();
      if (position == null) {
        // Try to refresh location once more
        position = await LocationService.refreshLocation();
        if (position == null) {
          print('❌ Could not get location for emergency alert');
          return;
        }
      }

      // Create location string directly from the position
      String locationString =
          "📍 Current Location:\n"
          "Latitude: ${position.latitude.toStringAsFixed(6)}\n"
          "Longitude: ${position.longitude.toStringAsFixed(6)}\n"
          "Accuracy: ${position.accuracy.toStringAsFixed(1)}m\n"
          "Time: ${DateTime.fromMillisecondsSinceEpoch(position.timestamp.millisecondsSinceEpoch).toString().substring(0, 19)}";

      // Create Google Maps URL with better compatibility
      String googleMapsUrl =
          "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

      // Verify location data is valid
      if (position.latitude == 0.0 && position.longitude == 0.0) {
        print("❌ Invalid location data received. Cannot send alert.");
        return;
      }

      // Send alert to admin panel
      try {
        await AdminPanelService.sendEmergencyAlertToPolice(
          position: position,
          locationString: locationString,
          googleMapsUrl: googleMapsUrl,
          additionalInfo:
              "Emergency alert from safety timer - ${_userName.isNotEmpty ? _userName : "User"}",
        );
        print("✅ Alert sent to admin panel successfully");
      } catch (e) {
        print("❌ Failed to send alert to admin panel: $e");
      }

      // Fetch emergency contacts from Firestore
      List<EmergencyContact> contacts =
          await EmergencyContactService.getEmergencyContacts().first;

      // Send SMS to each contact using the emergency alert SMS service
      if (contacts.isNotEmpty) {
        int successCount = 0;
        int totalContacts = contacts.length;

        for (final contact in contacts) {
          if (contact.phoneNumber.isNotEmpty) {
            try {
              await sendEmergencyAlertSMS(
                contact.phoneNumber,
                _userName.isNotEmpty ? _userName : "User",
                locationString,
                googleMapsUrl,
              );
              successCount++;
            } catch (e) {
              print('Failed to send SMS to ${contact.name}: $e');
              // Continue with other contacts even if one fails
            }
          }
        }

        print(
          "✅ Emergency alert sent to $successCount out of $totalContacts contacts!",
        );
      } else {
        print("❌ No emergency contacts found for safety timer alert");
      }
    } catch (e) {
      print("❌ Error sending emergency alert from safety timer: $e");
    }
  }

  // Dispose resources
  void dispose() {
    stopTimer();
    _timer = null;
    onTimerUpdate = null;
    onTimerComplete = null;
    onTimerStopped = null;
  }
}
