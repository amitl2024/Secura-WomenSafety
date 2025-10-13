import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_women_safety/data/services/user_service.dart';
import 'package:intl/intl.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const UserDetailsScreen({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: Text('${widget.userName}\'s Activity'),
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.warning), text: 'Alerts'),
            Tab(icon: Icon(Icons.report), text: 'Reports'),
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
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildUserAlerts(),
            _buildUserReports(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAlerts() {
    return StreamBuilder<QuerySnapshot>(
      stream: UserService().getUserAlerts(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No alerts found for this user'));
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final alert = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildAlertCard(alert);
            },
          );
        }
      },
    );
  }

  Widget _buildUserReports() {
    return StreamBuilder<QuerySnapshot>(
      stream: UserService().getUserReports(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No reports found for this user'));
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildReportCard(data, doc.id);
            },
          );
        }
      },
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final hasLocation = alert.containsKey('latitude') && 
                        alert.containsKey('longitude') && 
                        alert['latitude'] != null && 
                        alert['longitude'] != null;
    
    final locationString = hasLocation 
        ? (alert['locationString'] != null && alert['locationString'].toString().isNotEmpty
            ? alert['locationString'].toString()
            : 'Lat: ${alert['latitude']}, Lng: ${alert['longitude']}')
        : 'Location not available';
    
    final status = alert['status'] ?? 'unknown';
    final timestamp = alert['timestamp']?.toDate() ?? DateTime.now();
    final additionalInfo = alert['additionalInfo'] ?? '';

    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'active':
        statusColor = Colors.red;
        statusText = 'Active';
        break;
      case 'responded':
        statusColor = Colors.orange;
        statusText = 'Responded';
        break;
      case 'resolved':
        statusColor = Colors.green;
        statusText = 'Resolved';
        break;
      case 'deleted':
        statusColor = Colors.grey;
        statusText = 'Deleted';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
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
                Text(
                  _formatTimestamp(timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF718096),
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
            if (additionalInfo.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Additional Information:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                additionalInfo,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, String reportId) {
    final title = report['title'] ?? 'Untitled Report';
    final status = report['status'] ?? 'pending';
    final timestamp = report['timestamp']?.toDate() ?? DateTime.now();
    final description = report['description'] ?? '';
    final category = report['category'] ?? 'Uncategorized';
    final location = report['location'] ?? 'Location not provided';
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusIcon = Icons.sync;
        break;
      case 'resolved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
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
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Category: $category',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Reported on: ${_formatTimestamp(timestamp)}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 12),
            if (description.isNotEmpty) ...[
              const Text(
                'Description:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],
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
                    location,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A5568),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
    
    if (difference.inDays > 0) {
      return DateFormat('MMM d, yyyy • h:mm a').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}