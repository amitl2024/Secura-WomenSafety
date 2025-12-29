import '../models/safe_place_models.dart';

class SafePlacesService {
  static Future<List<SafePlace>> getNearbySafePlaces({
    required double latitude,
    required double longitude,
  }) async {
    // Intentionally using mock data only
    // Google Places API is not being used to avoid costs
    return _getMockSafePlaces(latitude, longitude);
  }

  static Future<List<DangerousArea>> getNearbyDangerousAreas({
    required double latitude,
    required double longitude,
  }) async {
    return _getMockDangerousAreas(latitude, longitude);
  }

  // Removed API-related methods since we're only using mock data

  // Optimized mock data - returns data immediately
  static List<SafePlace> _getMockSafePlaces(double lat, double lng) {
    return [
      SafePlace(
        name: 'City General Hospital',
        address: '123 Main Street, City Center',
        type: 'Hospital',
        latitude: lat + 0.001,
        longitude: lng + 0.001,
        rating: 4.5,
        isOpen: true,
        distance: 500,
        phoneNumber: '+1-555-0123',
      ),
      SafePlace(
        name: 'Central Police Station',
        address: '456 Safety Avenue, Downtown',
        type: 'Police Station',
        latitude: lat - 0.001,
        longitude: lng + 0.002,
        rating: 4.2,
        isOpen: true,
        distance: 800,
        phoneNumber: '+1-555-911',
      ),
      SafePlace(
        name: 'Safe Haven Pharmacy',
        address: '789 Health Road, Medical District',
        type: 'Pharmacy',
        latitude: lat + 0.002,
        longitude: lng - 0.001,
        rating: 4.0,
        isOpen: true,
        distance: 1200,
        phoneNumber: '+1-555-0456',
      ),
    ];
  }

  static List<DangerousArea> _getMockDangerousAreas(double lat, double lng) {
    return [
      DangerousArea(
        name: 'Downtown Bar District',
        address: 'Nightlife Area, Downtown',
        type: 'Bar',
        latitude: lat + 0.003,
        longitude: lng + 0.003,
        dangerLevel: DangerLevel.medium,
        distance: 1500,
        description: 'Avoid alone at night, stay in groups',
      ),
      DangerousArea(
        name: 'Industrial Parking Lot',
        address: 'Warehouse District',
        type: 'Parking Area',
        latitude: lat - 0.002,
        longitude: lng - 0.003,
        dangerLevel: DangerLevel.low,
        distance: 2000,
        description: 'Be cautious, well-lit areas only',
      ),
    ];
  }
}
