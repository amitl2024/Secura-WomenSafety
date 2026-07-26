import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ai_women_safety/data/services/admin_panel_service.dart';
import 'package:ai_women_safety/data/services/admin_auth_service.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:ai_women_safety/data/services/report_service.dart';
import 'package:ai_women_safety/data/models/report_model.dart';
import 'package:intl/intl.dart';
import 'package:ai_women_safety/data/models/user_model.dart';
import 'package:ai_women_safety/data/services/user_service.dart';
import 'package:ai_women_safety/Ui/screens/admin/user_details_screen.dart';
import 'package:ai_women_safety/utils/logger_util.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _loginTime;
  bool _showHistory =
      false; // State to toggle between current alerts and history
  bool _showReportHistory = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadLoginTime();
  }

  Future<void> _loadLoginTime() async {
    final loginTime = await AdminAuthService.getAdminLoginTime();
    if (mounted) {
      setState(() {
        _loginTime = loginTime;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Police Admin Panel'),
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.warning), text: 'Alerts'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.analytics), text: 'Reports'),
          ],
        ),
      ),
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
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDashboard(),
              _buildEmergencyAlertsList(),
              _buildUsersList(),
              _buildReports(),
            ],
          ),
        ),
      ),
    );
  }

  // TODO: Implement _logout, _buildDashboard, _buildUsersList, _buildReports methods

  Future<void> _logout() async {
    await AdminAuthService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildDashboard() {
    // Enhanced dashboard with statistics and information
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),

          const SizedBox(height: 24),
          StreamBuilder<List<UserModel>>(
            stream: UserService().getAllUsers(),
            builder: (context, userSnapshot) {
              final userCount =
                  userSnapshot.hasData
                      ? userSnapshot.data!.length.toString()
                      : '0';

              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: AdminPanelService.getEmergencyAlerts(),
                builder: (context, alertSnapshot) {
                  int activeAlerts = 0;
                  int respondedAlerts = 0;
                  int resolvedAlerts = 0;

                  if (alertSnapshot.hasData) {
                    for (var alert in alertSnapshot.data!) {
                      if (alert['status'] == 'active') {
                        activeAlerts++;
                      } else if (alert['status'] == 'responded') {
                        respondedAlerts++;
                      } else if (alert['status'] == 'resolved') {
                        resolvedAlerts++;
                      }
                    }
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'Active Alerts',
                              count: activeAlerts.toString(),
                              icon: Icons.warning,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Responded Alerts',
                              count: respondedAlerts.toString(),
                              icon: Icons.local_police,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              title: 'Resolved Alerts',
                              count: resolvedAlerts.toString(),
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              title: 'Total Users',
                              count: userCount,
                              icon: Icons.people,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A5568),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUsersList() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<UserModel>>(
        stream: UserService().getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final users = snapshot.data ?? [];

            if (users.isEmpty) {
              return const Center(child: Text('No users found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildUserCard(user);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      UserDetailsScreen(userId: user.id, userName: user.name),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFE53E3E).withOpacity(0.1),
                child:
                    user.profilePicUrl != null && user.profilePicUrl!.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            user.profilePicUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 30,
                                color: Color(0xFFE53E3E),
                              );
                            },
                          ),
                        )
                        : const Icon(
                          Icons.person,
                          size: 30,
                          color: Color(0xFFE53E3E),
                        ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.phone,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFF718096)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReports() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Toggle button to switch between current reports and history
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showReportHistory = !_showReportHistory;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A5568),
                foregroundColor: Colors.white,
              ),
              child: Text(
                _showReportHistory
                    ? 'Show Current Reports'
                    : 'Show Resolved Reports',
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ReportModel>>(
              stream: ReportService().getAllReports(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final reports = snapshot.data ?? [];
                  // Filter reports based on view mode
                  final filteredReports =
                      _showReportHistory
                          ? reports
                              .where((report) => report.status == 'resolved')
                              .toList()
                          : reports
                              .where((report) => report.status != 'resolved')
                              .toList();

                  if (filteredReports.isEmpty) {
                    return Center(
                      child: Text(
                        _showReportHistory
                            ? 'No resolved reports in history'
                            : 'No pending or in-progress reports',
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      return _buildReportCard(report);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final statusColors = {
      'pending': Colors.orange,
      'in_progress': Colors.blue,
      'resolved': Colors.green,
      'rejected': Colors.red,
    };

    final statusColor = statusColors[report.status] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  report.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Chip(
                  label: Text(report.status.toUpperCase()),
                  backgroundColor: statusColor,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  report.isAnonymous ? 'Anonymous' : report.userName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  dateFormat.format(report.timestamp),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              report.description,
              style: const TextStyle(fontSize: 15, color: Color(0xFF4A5568)),
            ),
            if (report.category != null && report.category!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(report.category!),
                backgroundColor: Colors.purple.shade100,
                labelStyle: TextStyle(color: Colors.purple.shade800),
              ),
            ],
            if (report.location != null && report.location!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      report.location!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A5568),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            // Phone number with call option
            if (!report.isAnonymous) ...[
              const SizedBox(height: 8),
              FutureBuilder<String?>(
                future: _getUserPhoneNumber(report.userId),
                builder: (context, snapshot) {
                  final phoneNumber = snapshot.data;
                  return Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        color: Color(0xFF4CAF50),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        phoneNumber ?? 'Loading...',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed:
                            phoneNumber != null
                                ? () => _callUser(phoneNumber)
                                : null,
                        icon: const Icon(Icons.call, size: 14),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              phoneNumber != null
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],

            // Display images from Supabase storage URLs
            if (report.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: report.imageUrls.length,
                  itemBuilder: (context, imgIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          report.imageUrls[imgIndex],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            AppLogger.error(
                              'Error loading image',
                              error,
                              stackTrace,
                            );
                            AppLogger.debug(
                              'Image URL: ${report.imageUrls[imgIndex]}',
                            );
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            // Admin notes section
            if (report.adminNotes != null && report.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Admin Notes:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                report.adminNotes!,
                style: const TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
              ),
            ],
            // Action buttons
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (report.status != 'resolved' && !_showReportHistory)
                  ElevatedButton(
                    onPressed: () {
                      _updateReportStatus(report.id!, 'resolved');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Mark as Resolved'),
                  ),
                // Show Delete button for resolved reports
                if (report.status == 'resolved') const SizedBox(width: 8),
                if (report.status == 'resolved')
                  ElevatedButton(
                    onPressed: () {
                      _deleteReport(report.id!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delete'),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _showReportDetails(report);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5568),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateReportStatus(String reportId, String status) {
    ReportService().updateReportStatus(reportId, status).then((success) {
      // Check if widget is still mounted before using context
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Report status updated to $status')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update report status')),
          );
        }
      }
    });
  }

  void _showReportDetails(ReportModel report) {
    // This would show a detailed view of the report
    // For now, we'll just show a dialog with the complete information
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Show all report details
                  // Including a larger view of images if available
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmergencyAlertsList() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Toggle button to switch between current alerts and history
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showHistory = !_showHistory;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A5568),
                foregroundColor: Colors.white,
              ),
              child: Text(
                _showHistory ? 'Show Current Alerts' : 'Show History',
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: AdminPanelService.getEmergencyAlerts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final alerts = snapshot.data ?? [];
                  // Filter alerts based on view mode
                  final filteredAlerts =
                      _showHistory
                          ? alerts
                              .where((alert) => alert['status'] == 'deleted')
                              .toList()
                          : alerts
                              .where((alert) => alert['status'] != 'deleted')
                              .toList();

                  if (filteredAlerts.isEmpty) {
                    return Center(
                      child: Text(
                        _showHistory
                            ? 'No deleted alerts in history'
                            : 'No active or responded alerts',
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredAlerts.length,
                    itemBuilder: (context, index) {
                      final alert = filteredAlerts[index];
                      return _buildAlertCard(alert);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final userName = alert['userName'] ?? 'Unknown User';
    // Access location data from the correct fields in the alert document
    final hasLocation =
        alert.containsKey('latitude') &&
        alert.containsKey('longitude') &&
        alert['latitude'] != null &&
        alert['longitude'] != null;
    final lat = hasLocation ? alert['latitude'] : 0.0;
    final lng = hasLocation ? alert['longitude'] : 0.0;
    // Use the stored location string if available, otherwise format coordinates
    final locationString =
        hasLocation
            ? (alert['locationString'] != null &&
                    alert['locationString'].toString().isNotEmpty
                ? alert['locationString'].toString()
                : 'Lat: $lat, Lng: $lng')
            : 'Location not available';
    // Use the stored Google Maps URL if available, otherwise construct it
    final googleMapsUrl =
        hasLocation
            ? (alert['googleMapsUrl'] != null &&
                    alert['googleMapsUrl'].toString().isNotEmpty
                ? alert['googleMapsUrl'].toString()
                : 'https://www.google.com/maps?q=$lat,$lng')
            : '';
    final status = alert['status'] ?? 'unknown';
    final timestamp = alert['timestamp']?.toDate() ?? DateTime.now();
    final additionalInfo = alert['additionalInfo'] ?? '';
    final userPhone = alert['userPhone'] ?? '';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'active':
        statusColor = Colors.red;
        statusIcon = Icons.warning;
        statusText = 'ACTIVE';
        break;
      case 'responded':
        statusColor = Colors.orange;
        statusIcon = Icons.local_police;
        statusText = 'RESPONDED';
        break;
      case 'resolved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'RESOLVED';
        break;
      case 'deleted':
        statusColor = Colors.grey;
        statusIcon = Icons.delete;
        statusText = 'DELETED';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'UNKNOWN';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFE53E3E),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationString,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                ),
              ],
            ),
            // Phone number with call option
            Column(
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Color(0xFF4CAF50), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userPhone.isNotEmpty
                            ? userPhone
                            : 'No phone number available',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed:
                          userPhone.isNotEmpty
                              ? () => _callUser(userPhone)
                              : null,
                      icon: const Icon(Icons.call, size: 14),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            userPhone.isNotEmpty
                                ? const Color(0xFF4CAF50)
                                : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${_formatTimestamp(timestamp)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (additionalInfo.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Info: $additionalInfo',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        googleMapsUrl.isNotEmpty
                            ? () => _openGoogleMaps(googleMapsUrl)
                            : null,
                    icon: const Icon(Icons.map, size: 16),
                    label: const Text('View on Maps'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          googleMapsUrl.isNotEmpty
                              ? const Color(0xFF4CAF50)
                              : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateAlertStatus(alert['id'], status),
                    icon: const Icon(Icons.update, size: 16),
                    label: Text(_getStatusButtonText(status)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                // Delete button visible for "responded" and "resolved" alerts
                if (status == 'responded' || status == 'resolved')
                  const SizedBox(width: 8),
                if (status == 'responded' || status == 'resolved')
                  ElevatedButton.icon(
                    onPressed: () => _deleteAlert(alert['id']),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  String _getStatusButtonText(String currentStatus) {
    switch (currentStatus) {
      case 'active':
        return 'Mark as Responded';
      case 'responded':
        return 'Mark as Resolved';
      case 'resolved':
        return 'Status: Resolved';
      default:
        return 'Update Status';
    }
  }

  Future<void> _updateAlertStatus(String alertId, String currentStatus) async {
    String newStatus;
    String message;

    switch (currentStatus) {
      case 'active':
        newStatus = 'responded';
        message = 'Alert marked as responded';
        break;
      case 'responded':
        newStatus = 'resolved';
        message = 'Alert marked as resolved';
        break;
      default:
        newStatus = 'active';
        message = 'Alert status updated';
    }

    await AdminPanelService.updateAlertStatus(alertId, newStatus);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      // Refresh the UI
      setState(() {});
    }
  }

  Future<void> _openGoogleMaps(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  // Method to get user's phone number from Firestore
  Future<String?> _getUserPhoneNumber(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.data()!['phone'] as String?;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching user phone number', e, stackTrace);
    }
    return null;
  }

  // Updated call user method
  Future<void> _callUser(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No phone number available')),
        );
      }
      return;
    }

    final url = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not make phone call')),
        );
      }
    }
  }

  Future<void> _deleteAlert(String alertId) async {
    await AdminPanelService.updateAlertStatus(alertId, 'deleted');
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Alert deleted')));
      // Refresh the UI
      setState(() {});
    }
  }

  Future<void> _deleteReport(String reportId) async {
    try {
      final success = await ReportService().deleteReport(reportId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report deleted successfully')),
          );
          // Refresh the UI
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete report')),
          );
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting report', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete report')),
        );
      }
    }
  }
}
