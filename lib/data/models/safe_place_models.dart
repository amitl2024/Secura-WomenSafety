import 'package:geolocator/geolocator.dart';

class SafePlace {
  final String name;
  final String address;
  final String type;
  final double latitude;
  final double longitude;
  final double rating;
  final bool isOpen;
  final double distance;
  final String? phoneNumber;
  final String? website;

  SafePlace({
    required this.name,
    required this.address,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.isOpen,
    required this.distance,
    this.phoneNumber,
    this.website,
  });

  String get distanceText {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m away';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km away';
    }
  }
}

class DangerousArea {
  final String name;
  final String address;
  final String type;
  final double latitude;
  final double longitude;
  final DangerLevel dangerLevel;
  final double distance;
  final String description;

  DangerousArea({
    required this.name,
    required this.address,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.dangerLevel,
    required this.distance,
    required this.description,
  });

  String get distanceText {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m away';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km away';
    }
  }
}

enum DangerLevel { low, medium, high }

extension DangerLevelExtension on DangerLevel {
  String get displayName {
    switch (this) {
      case DangerLevel.low:
        return 'Low Risk';
      case DangerLevel.medium:
        return 'Medium Risk';
      case DangerLevel.high:
        return 'High Risk';
    }
  }

  String get color {
    switch (this) {
      case DangerLevel.low:
        return '0xFF4CAF50'; // Green
      case DangerLevel.medium:
        return '0xFFFF9800'; // Orange
      case DangerLevel.high:
        return '0xFFF44336'; // Red
    }
  }
}

