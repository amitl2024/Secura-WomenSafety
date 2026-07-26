import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_women_safety/data/services/location_service.dart';
import 'package:ai_women_safety/data/services/emergency_contact_service.dart';
import 'package:ai_women_safety/data/services/admin_panel_service.dart';
import 'package:ai_women_safety/data/services/sms_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ai_women_safety/utils/logger_util.dart';
import 'package:home_widget/home_widget.dart';

@pragma('vm:entry-point')
Future<void> sosBackgroundCallback(Uri? uri) async {
  if (uri?.host == 'sos_trigger') {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    
    AppLogger.info("🚨 SOS triggered from Home Screen Widget (Background)!");

    // Check SMS permissions
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      AppLogger.error("SMS permission not granted in background.");
      return;
    }

    // Get current location
    Position? position = await LocationService.getCurrentLocation();
    if (position == null) {
      position = await LocationService.refreshLocation();
      if (position == null) {
        AppLogger.error("Could not get location in background.");
        return;
      }
    }

    String locationString =
        "📍 Emergency Alert Location Details\n"
        "Latitude: ${position.latitude.toStringAsFixed(6)}\n"
        "Longitude: ${position.longitude.toStringAsFixed(6)}\n"
        "Accuracy: ${position.accuracy.toStringAsFixed(1)}m";

    String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

    // Send alert to admin panel
    try {
      await AdminPanelService.sendEmergencyAlertToPolice(
        position: position,
        locationString: locationString,
        googleMapsUrl: googleMapsUrl,
        additionalInfo: "Widget Emergency Alert",
      );
      AppLogger.info("✅ Background SOS alert sent to admin panel");
    } catch (e) {
      AppLogger.error("❌ Failed to send background alert to admin panel", e);
    }

    // Fetch actual user name
    String userName = "User";
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        userName = doc.data()?['name'] ?? "User";
      }
    } catch (e) {
      AppLogger.error("Failed to fetch user name in background", e);
    }

    // Fetch contacts and send SMS
    try {
      final contacts = await EmergencyContactService.getEmergencyContactsOnce();
      if (contacts.isNotEmpty) {
        for (final contact in contacts) {
          await sendEmergencyAlertSMS(
            contact.phoneNumber,
            userName,
            locationString,
            googleMapsUrl,
          );
        }
        AppLogger.info("✅ Background SMS sent to \${contacts.length} contacts.");
      } else {
        AppLogger.info("⚠️ No emergency contacts found.");
      }
    } catch (e) {
      AppLogger.error("❌ Failed to send SMS from background", e);
    }
  }
}
