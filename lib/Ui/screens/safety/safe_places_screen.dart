import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/services/safe_places_service.dart';
import '../../../data/services/location_service.dart';
import '../../../data/models/safe_place_models.dart';

class SafePlacesScreen extends StatefulWidget {
  const SafePlacesScreen({super.key});

  @override
  State<SafePlacesScreen> createState() => _SafePlacesScreenState();
}

class _SafePlacesScreenState extends State<SafePlacesScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final TabController _tabController;

  // Initialize with empty lists but show skeleton loading state immediately
  List<SafePlace> _safePlaces = [];
  List<DangerousArea> _dangerousAreas = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Position? _currentPosition;
  
  // Preload a few skeleton items to show immediate UI feedback
  List<SafePlace> _skeletonSafePlaces = List.generate(3, (index) => SafePlace(
    name: 'Loading...',
    address: 'Fetching nearby places...',
    type: '...',
    latitude: 0.0,
    longitude: 0.0,
    rating: 0.0,
    isOpen: false,
    distance: 0,
  ));
  
  List<DangerousArea> _skeletonDangerousAreas = List.generate(2, (index) => DangerousArea(
    name: 'Loading...',
    address: 'Fetching areas...',
    type: '...',
    latitude: 0.0,
    longitude: 0.0,
    dangerLevel: DangerLevel.medium,
    distance: 0,
    description: '...',
  ));

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tabController = TabController(length: 2, vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
    _loadNearbyPlaces();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNearbyPlaces() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print('🌍 Starting to load nearby places...');

      // Get current location - this is quick with our optimized LocationService
      _currentPosition = await LocationService.getCurrentPosition();
      print('📍 Current position: $_currentPosition');

      if (_currentPosition == null) {
        print('❌ No location available, using default coordinates');
        // Use default coordinates if location is not available
        _currentPosition = Position(
          latitude: 28.6139, // Delhi coordinates as default
          longitude: 77.2090,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      }

      // Optimize: Run both API calls concurrently using Future.wait()
      print('🔍 Loading places data concurrently...');
      final List<dynamic> results = await Future.wait([
        SafePlacesService.getNearbySafePlaces(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
        ),
        SafePlacesService.getNearbyDangerousAreas(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
        ),
      ]);

      final safePlaces = results[0] as List<SafePlace>;
      final dangerousAreas = results[1] as List<DangerousArea>;

      print(
        '✅ Loaded ${safePlaces.length} safe places and ${dangerousAreas.length} dangerous areas',
      );

      setState(() {
        _safePlaces = safePlaces;
        _dangerousAreas = dangerousAreas;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error in _loadNearbyPlaces: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading nearby places: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8BBD0), // Soft Pink
              Color(0xFFCE93D8), // Lavender
              Color(0xFFFFF3E0), // Peach
              Color(0xFFB3E5FC), // Light Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.33, 0.66, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildTabBar(),
                    Expanded(child: _buildContent()),
                  ],
                ),
              ),
              _buildFloatingBackButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Safe Places Nearby",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Find safe locations and avoid dangerous areas",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadNearbyPlaces,
            icon: const Icon(Icons.refresh, color: Color(0xFF4CAF50)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(icon: Icon(Icons.security, size: 20), text: 'Safe Places'),
          Tab(icon: Icon(Icons.warning, size: 20), text: 'Dangerous Areas'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF4CAF50)),
            SizedBox(height: 16),
            Text(
              'Finding nearby places...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNearbyPlaces,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [_buildSafePlacesList(), _buildDangerousAreasList()],
    );
  }

  Widget _buildSafePlacesList() {
    if (_safePlaces.isEmpty) {
      return const Center(
        child: Text(
          'No safe places found nearby',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _isLoading ? _skeletonSafePlaces.length : _safePlaces.length,
      itemBuilder: (context, index) {
        // Show skeleton items while loading
        final place = _isLoading ? _skeletonSafePlaces[index] : _safePlaces[index];
        return _isLoading 
            ? _buildSkeletonPlaceCard() 
            : _buildSafePlaceCard(place);
      },
    );
  }

  Widget _buildDangerousAreasList() {
    if (_dangerousAreas.isEmpty) {
      return const Center(
        child: Text(
          'No dangerous areas found nearby',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _isLoading ? _skeletonDangerousAreas.length : _dangerousAreas.length,
      itemBuilder: (context, index) {
        // Show skeleton items while loading
        final area = _isLoading ? _skeletonDangerousAreas[index] : _dangerousAreas[index];
        return _isLoading 
            ? _buildSkeletonDangerousAreaCard() 
            : _buildDangerousAreaCard(area);
      },
    );
  }

  Widget _buildSafePlaceCard(SafePlace place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getPlaceIcon(place.type),
                  color: const Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      place.type,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  place.distanceText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            place.address,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (place.rating > 0) ...[
                Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  place.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      place.isOpen
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  place.isOpen ? 'Open' : 'Closed',
                  style: TextStyle(
                    fontSize: 10,
                    color: place.isOpen ? const Color(0xFF4CAF50) : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (place.phoneNumber != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callPlace(place.phoneNumber!),
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              if (place.phoneNumber != null) const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToPlace(place),
                  icon: const Icon(Icons.directions, size: 16),
                  label: const Text('Navigate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Skeleton card for safe places while loading
  Widget _buildSkeletonPlaceCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.security, color: Color(0xFF4CAF50), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  height: 16,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                height: 20,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Skeleton card for dangerous areas while loading
  Widget _buildSkeletonDangerousAreaCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  height: 16,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 20,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDangerousAreaCard(DangerousArea area) {
    final dangerColor = Color(int.parse(area.dangerLevel.color));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dangerColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: dangerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getDangerousAreaIcon(area.type),
                  color: dangerColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      area.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      area.type,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: dangerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  area.distanceText,
                  style: TextStyle(
                    fontSize: 12,
                    color: dangerColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            area.address,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: dangerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              area.dangerLevel.displayName,
              style: TextStyle(
                fontSize: 12,
                color: dangerColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            area.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlaceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'hospital':
        return Icons.local_hospital;
      case 'police station':
        return Icons.local_police;
      case 'fire station':
        return Icons.local_fire_department;
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'bank':
        return Icons.account_balance;
      case 'atm':
        return Icons.atm;
      case 'gas station':
        return Icons.local_gas_station;
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping mall':
        return Icons.shopping_cart;
      case 'library':
        return Icons.local_library;
      case 'school':
        return Icons.school;
      case 'university':
        return Icons.school;
      default:
        return Icons.location_on;
    }
  }

  IconData _getDangerousAreaIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bar':
        return Icons.local_bar;
      case 'night club':
        return Icons.nightlife;
      case 'casino':
        return Icons.casino;
      case 'parking area':
        return Icons.local_parking;
      case 'subway station':
        return Icons.subway;
      case 'bus station':
        return Icons.directions_bus;
      default:
        return Icons.warning;
    }
  }

  void _callPlace(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not make phone call')),
      );
    }
  }

  void _navigateToPlace(SafePlace place) async {
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}',
    );
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open maps')));
    }
  }

  Widget _buildFloatingBackButton(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            onTap: () => Navigator.of(context).pop(),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
