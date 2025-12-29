import 'dart:async';
import 'dart:io';
import 'package:telephony/telephony.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ai_women_safety/utils/logger_util.dart';

final Telephony _telephony = Telephony.instance;

Future<bool> checkSmsPermissions() async {
  try {
    // iOS doesn't require SMS permissions - Messages app handles it
    if (Platform.isIOS) {
      AppLogger.debug("iOS platform - SMS permissions not required");
      return true;
    }

    // Android: Check if device is SMS capable
    final bool? hasSms = await _telephony.isSmsCapable;
    AppLogger.debug("Device is SMS capable: $hasSms");
    if (hasSms != true) {
      AppLogger.warning("❌ Device is not SMS capable");
      return false;
    }

    // Request SMS permissions directly through telephony plugin
    AppLogger.debug("Requesting SMS permission...");
    final bool? granted = await _telephony.requestSmsPermissions;
    AppLogger.debug("SMS permission granted: $granted");

    return granted ?? false;
  } catch (e, stackTrace) {
    AppLogger.error('Error checking SMS permissions', e, stackTrace);
    return false;
  }
}

Future<void> sendAddContactSMS(String contactNumber, String userName) async {
  final ok = await checkSmsPermissions();
  if (!ok) {
    throw Exception('SMS permission not granted or device not SMS capable');
  }

  final String body =
      "Hello, $userName you have been added to my emergency contacts. "
      "In case of emergency, you will receive alerts and my location.";

  try {
    if (Platform.isIOS) {
      // iOS: Use url_launcher to open Messages app
      await _sendSmsViaUrlLauncher(contactNumber, body);
    } else {
      // Android: Use telephony package
      await _telephony.sendSms(to: contactNumber, message: body);
    }
    AppLogger.info('SMS sent successfully to $contactNumber');
  } catch (e, stackTrace) {
    AppLogger.error('Error sending SMS', e, stackTrace);
    rethrow;
  }
}

Future<void> sendEmergencyAlertSMS(
  String contactNumber,
  String userName,
  String locationString,
  String googleMapsUrl,
) async {
  AppLogger.info("🔧 Starting sendEmergencyAlertSMS function...");
  AppLogger.debug("Contact: $contactNumber");
  AppLogger.debug("Platform: ${Platform.isIOS ? 'iOS' : 'Android'}");

  try {
    // Check permissions
    final bool hasPermission = await checkSmsPermissions();
    if (!hasPermission) {
      throw Exception('SMS permission not granted or device not SMS capable');
    }

    final String body =
        "🚨 EMERGENCY ALERT 🚨\n"
        "I need help! I'm in danger!\n"
        "Name: $userName\n"
        "Location: $locationString\n"
        "Google Maps: $googleMapsUrl\n"
        "Please contact me or emergency services immediately!\n"
        "Time: ${DateTime.now().toString()}";

    // Debug logging
    AppLogger.debug('📤 Sending emergency SMS to $contactNumber');
    AppLogger.verbose('SMS Body length: ${body.length} characters');

    if (Platform.isIOS) {
      // iOS: Use url_launcher to open Messages app
      await _sendSmsViaUrlLauncher(contactNumber, body);
      AppLogger.info('✅ Emergency SMS opened in Messages app on iOS');
    } else {
      // Android: Try direct SMS first, then fallback to default app
      try {
        // Try to send SMS with multipart support for long messages
        bool isMultipart = body.length > 160;
        AppLogger.debug("Using multipart SMS: $isMultipart");

        await _telephony.sendSms(
          to: contactNumber,
          message: body,
          isMultipart: isMultipart,
        );
        AppLogger.info('✅ Emergency SMS sent successfully to $contactNumber');
      } catch (e, stackTrace) {
        AppLogger.warning('Direct SMS failed, trying default app...', e, stackTrace);
        
        // Fallback to default SMS app
        await _telephony.sendSmsByDefaultApp(
          to: contactNumber,
          message:
              "🚨 EMERGENCY ALERT 🚨\nI need help! Please check my location: $googleMapsUrl",
        );
        AppLogger.info('✅ Emergency SMS opened in default SMS app');
      }
    }
  } catch (e, stackTrace) {
    AppLogger.error('❌ Error sending emergency SMS', e, stackTrace);
    rethrow;
  }
}

/// Helper function to send SMS via URL launcher (iOS and fallback for Android)
Future<void> _sendSmsViaUrlLauncher(String phoneNumber, String message) async {
  try {
    // Clean phone number (remove non-digits except +)
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // iOS uses sms: URL scheme
    // Format: sms:+1234567890&body=message
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: cleanNumber,
      queryParameters: {
        'body': message,
      },
    );

    AppLogger.debug('Opening SMS URL: sms:$cleanNumber');
    
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      AppLogger.info('✅ SMS app opened successfully');
    } else {
      throw Exception('Cannot launch SMS URL');
    }
  } catch (e, stackTrace) {
    AppLogger.error('Error launching SMS via URL', e, stackTrace);
    rethrow;
  }
}
