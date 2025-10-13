import 'package:ai_women_safety/Ui/screens/safety/incident_report_page.dart';
import 'package:ai_women_safety/Ui/screens/safety/news_screen.dart';
import 'package:ai_women_safety/Ui/screens/safety/safe_places_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

// Common styling constants for better performance and consistency
class _AppStyles {
  static const gradientBackground = BoxDecoration(
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
  );

  static const whiteCardDecoration = BoxDecoration(
    color: Color(0xF2FFFFFF), // Colors.white.withOpacity(0.95)
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(
        color: Color(0x0D000000), // Colors.black.withOpacity(0.05)
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );

  static const headerCardDecoration = BoxDecoration(
    color: Color(0xF2FFFFFF), // Colors.white.withOpacity(0.95)
    borderRadius: BorderRadius.all(Radius.circular(20)),
    boxShadow: [
      BoxShadow(
        color: Color(0x1A000000), // Colors.black.withOpacity(0.1)
        blurRadius: 15,
        offset: Offset(0, 5),
      ),
    ],
  );

  static const floatingBackButtonDecoration = BoxDecoration(
    color: Color(0xE6FFFFFF), // Colors.white.withOpacity(0.9)
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );
}

class SafetyAwarenessScreen extends StatelessWidget {
  const SafetyAwarenessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: _AppStyles.gradientBackground,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Simple Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _AppStyles.headerCardDecoration,
                child: const Column(
                  children: [
                    Icon(Icons.security, size: 40, color: Color(0xFFE91E63)),
                    SizedBox(height: 12),
                    Text(
                      "Safety Center",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color(0xFF2D3748),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Your safety resources and quick actions",
                      style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Safe Places Quick Action
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _AppStyles.whiteCardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Safety Features",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMainCard(
                      "Safe Places Nearby",
                      "Find hospitals, police stations, and safe locations",
                      Icons.location_on,
                      const Color(0xFF4CAF50),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SafePlacesScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMainCard(
                      "Incident Report",
                      "Log an incident with notes for later reference",
                      Icons.report,
                      const Color(0xFFFF5722),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const IncidentReportPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMainCard(
                      "Safety News",
                      "Stay updated with latest safety news and tips",
                      Icons.newspaper,
                      const Color(0xFF2196F3),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NewsScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Main Navigation Cards
              _buildMainCard(
                "Safety Tips & Guide",
                "Learn essential safety tips and awareness",
                Icons.shield,
                const Color(0xFF9C27B0),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SafetyTipsPage()),
                ),
              ),
              const SizedBox(height: 16),

              _buildMainCard(
                "Health & Wellness",
                "Physical and mental health resources",
                Icons.favorite,
                const Color(0xFF00BCD4),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HealthTipsPage()),
                ),
              ),
              const SizedBox(height: 16),

              _buildMainCard(
                "Awareness Center",
                "Important awareness information and campaigns",
                Icons.lightbulb,
                const Color(0xFFFF9800),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AwarenessPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    const borderRadius = BorderRadius.all(Radius.circular(12));

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: borderRadius,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    const borderRadius = BorderRadius.all(Radius.circular(16));
    const iconBorderRadius = BorderRadius.all(Radius.circular(12));

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: borderRadius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000), // Colors.black.withOpacity(0.05)
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: iconBorderRadius,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  void _showQuickAction(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 16),
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
                colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Safety & Wellbeing",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Resources, tips and quick actions to keep you safe",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSafetyActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: "Safety Checklist",
                subtitle: "Plan ahead and stay ready",
                color: const Color(0xFF9C27B0),
                icon: Icons.checklist_rounded,
                onTap: () => _showSafetyChecklist(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                title: "I'm Safe",
                subtitle: "Send a quick check-in",
                color: const Color(0xFF00BCD4),
                icon: Icons.favorite_rounded,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Shared 'I'm Safe' status")),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: "Share ETA",
                subtitle: "Let contacts track you",
                color: const Color(0xFFFF9800),
                icon: Icons.directions_walk_rounded,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Share ETA coming soon")),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                title: "Helplines",
                subtitle: "Find assistance",
                color: const Color(0xFFE91E63),
                icon: Icons.support_agent,
                onTap: () => _showHelplinesSheet(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSafetyChecklist(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final items = [
          'Emergency contacts added',
          'Location sharing enabled',
          'Safe route planned',
          'Phone fully charged',
        ];
        final completed = List<bool>.filled(items.length, false);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Safety Checklist',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(items.length, (i) {
                    return CheckboxListTile(
                      value: completed[i],
                      onChanged:
                          (v) => setSheetState(() => completed[i] = v ?? false),
                      title: Text(items[i]),
                      activeColor: const Color(0xFF9C27B0),
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showHelplinesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Helplines',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                _helplineTile(context, 'Emergency (India)', '112'),
                _helplineTile(context, 'Women Helpline (India)', '1091'),
                _helplineTile(context, 'Cyber Crime', '1930'),
              ],
            ),
          ),
    );
  }

  Widget _helplineTile(BuildContext context, String label, String number) {
    return ListTile(
      leading: const Icon(Icons.phone_in_talk, color: Color(0xFFE91E63)),
      title: Text(label),
      subtitle: Text(number),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dial $number (intent coming soon)')),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _AwarenessCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<IconData> subIcons;
  final Color color;
  final VoidCallback onTap;

  const _AwarenessCard({
    required this.title,
    required this.icon,
    required this.subIcons,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Icon(icon, size: 36, color: Colors.deepPurple),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children:
                        subIcons
                            .map(
                              (i) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  i,
                                  size: 22,
                                  color: Colors.deepPurpleAccent,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.deepPurple,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy pages for navigation (replace with your actual pages)
class SafetyTipsPage extends StatefulWidget {
  const SafetyTipsPage({super.key});

  @override
  State<SafetyTipsPage> createState() => _SafetyTipsPageState();
}

class _SafetyTipsPageState extends State<SafetyTipsPage>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  int _selectedCategory = 0;

  static const List<String> _categories = [
    'Personal',
    'Digital',
    'Travel',
    'Emergency',
  ];

  static const Duration _animationDuration = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
                    _buildSafetyHeader(),
                    Expanded(child: _buildSafetyContent()),
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

  Widget _buildSafetyHeader() {
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
                colors: [Color(0xFFE91E63), Color(0xFFAD1457)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Safety Tips & Guide",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Essential safety tips for women's security",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyCategoryTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(25),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : null,
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  color:
                      isSelected ? const Color(0xFFE91E63) : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSafetyContent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        Text(
          "Self-Defense Basics (Videos)",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _VideoPlayerCard(
                videoUrl: 'https://www.youtube.com/watch?v=5qU6QKQ4kZk',
                title: 'Women\'s Self-Defense Basics',
                duration: '12 min',
              ),
              SizedBox(width: 12),
              _VideoPlayerCard(
                videoUrl: 'https://www.youtube.com/watch?v=E2T3VbB8Qe0',
                title: 'Escape from Wrist Grabs',
                duration: '7 min',
              ),
              SizedBox(width: 12),
              _VideoPlayerCard(
                videoUrl: 'https://www.youtube.com/watch?v=QJz2x2Y1E0o',
                title: 'Situational Awareness Tips',
                duration: '9 min',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Handling Critical Situations",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildSafetyTipCard(
          icon: Icons.campaign,
          title: "Make Noise, Create Distance",
          description:
              "Shout for help, attract attention, and move to a populated, well-lit area.",
          color: const Color(0xFFD32F2F),
        ),
        const SizedBox(height: 12),
        _buildSafetyTipCard(
          icon: Icons.phone_in_talk,
          title: "Call Emergency Early",
          description:
              "Dial local emergency numbers as soon as you sense danger—don\'t wait.",
          color: const Color(0xFF1976D2),
        ),
        const SizedBox(height: 12),
        _buildSafetyTipCard(
          icon: Icons.route,
          title: "Know Exit Routes",
          description:
              "Identify exits and safe locations (stores, police posts, hospitals).",
          color: const Color(0xFF00796B),
        ),
        const SizedBox(height: 12),
        _buildSafetyTipCard(
          icon: Icons.shield,
          title: "Use Simple Targets",
          description:
              "If needed, target eyes, nose, throat, knees, or groin to break away.",
          color: const Color(0xFF6A1B9A),
        ),
        const SizedBox(height: 24),
        Text(
          "Quick Safety Tips",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildSafetyTipCard(
          icon: Icons.share_location,
          title: "Share Your Live Location",
          description: "Let a trusted contact track your route during travel.",
          color: const Color(0xFF2E7D32),
        ),
        const SizedBox(height: 12),
        _buildSafetyTipCard(
          icon: Icons.key,
          title: "Keys and Essentials Ready",
          description:
              "Keep keys in hand before reaching the door; avoid searching at the doorstep.",
          color: const Color(0xFFFB8C00),
        ),
        const SizedBox(height: 12),
        _buildSafetyTipCard(
          icon: Icons.smartphone,
          title: "Phone Battery Above 30%",
          description:
              "Charge before leaving; carry a compact power bank if possible.",
          color: const Color(0xFF1565C0),
        ),
      ],
    );
  }

  Widget _buildSafetyTipCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBackButton(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        decoration: _AppStyles.floatingBackButtonDecoration,
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

class HealthTipsPage extends StatefulWidget {
  const HealthTipsPage({super.key});

  @override
  State<HealthTipsPage> createState() => _HealthTipsPageState();
}

class _HealthTipsPageState extends State<HealthTipsPage>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  int _selectedCategory = 0;
  int _waterGlasses = 0; // 0..8

  static const List<String> _categories = [
    'Physical',
    'Mental',
    'Nutrition',
    'Sleep',
  ];
  static const Duration _animationDuration = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
                    _buildCategoryTabs(),
                    Expanded(child: _buildContent()),
                  ],
                ),
              ),
              _buildHealthFloatingBackButton(context),
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
                colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Health & Wellness",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Tips and resources for your physical and mental wellbeing",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(25),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : null,
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  color:
                      isSelected ? const Color(0xFF00BCD4) : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedCategory) {
      case 0:
        return _buildPhysicalHealth();
      case 1:
        return _buildMentalHealth();
      case 2:
        return _buildNutrition();
      case 3:
        return _buildSleep();
      default:
        return _buildPhysicalHealth();
    }
  }

  Widget _buildPhysicalHealth() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionTitle("Exercise Videos"),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _VideoPlayerCard(
                videoUrl: 'https://www.youtube.com/watch?v=v7AYKMP6rOE',
                title: 'Morning Yoga Flow',
                duration: '15 min',
              ),
              SizedBox(width: 12),
              _VideoPlayerCard(
                videoUrl: 'https://www.youtube.com/watch?v=tzN2ypX6vtY',
                title: 'Core Workout',
                duration: '15 min',
              ),
              SizedBox(width: 12),
              _VideoPlayerCard(
                videoUrl: 'https://www.youtube.com/watch?v=4Y2EjHC8n1Q',
                title: 'Stretching Routine',
                duration: '15 min',
              ),
              SizedBox(width: 12),
              _VideoPlayerCard(
                videoUrl: 'https://www.youtube.com/watch?v=ml6cT4AZdqI',
                title: 'Cardio Blast',
                duration: '15 min',
              ),
              SizedBox(width: 12),
              _VideoPlayerCard(
                videoUrl: 'https://www.youtube.com/watch?v=UItWltVZZmE',
                title: 'Strength Training',
                duration: '15 min',
              ),
              SizedBox(width: 12),
              _VideoPlayerCard(
                videoUrl: 'https://www.youtube.com/watch?v=Z-4IxQJ_VR4',
                title: 'Pilates Session',
                duration: '15 min',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle("Workout Categories"),
        const SizedBox(height: 16),
        _buildWorkoutCategoryCard(
          title: "Yoga & Flexibility",
          description: "Improve flexibility and reduce stress",
          icon: Icons.self_improvement,
          color: const Color(0xFF9C27B0),
          videos: ["Morning Yoga Flow", "Evening Stretch", "Meditation Yoga"],
        ),
        const SizedBox(height: 12),
        _buildWorkoutCategoryCard(
          title: "Cardio & Endurance",
          description: "Boost heart health and stamina",
          icon: Icons.directions_run,
          color: const Color(0xFFE91E63),
          videos: ["Cardio Blast", "HIIT Workout", "Dance Fitness"],
        ),
        const SizedBox(height: 12),
        _buildWorkoutCategoryCard(
          title: "Strength & Toning",
          description: "Build muscle and tone your body",
          icon: Icons.fitness_center,
          color: const Color(0xFF4CAF50),
          videos: ["Strength Training", "Core Workout", "Pilates Session"],
        ),
        const SizedBox(height: 24),
        _buildSectionTitle("Quick Tips"),
        const SizedBox(height: 16),
        _buildTipCard(
          icon: Icons.directions_walk,
          title: "Daily Steps Goal",
          description:
              "Aim for 10,000 steps daily for better cardiovascular health",
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          icon: Icons.water_drop,
          title: "Stay Hydrated",
          description: "Drink 8-10 glasses of water throughout the day",
          color: const Color(0xFF2196F3),
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          icon: Icons.timer,
          title: "Take Breaks",
          description: "Every 30 minutes, take a 5-minute break to stretch",
          color: const Color(0xFFFF9800),
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          icon: Icons.schedule,
          title: "Consistent Schedule",
          description: "Work out at the same time daily for better results",
          color: const Color(0xFF9C27B0),
        ),
      ],
    );
  }

  Widget _buildMentalHealth() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Removed Guided Videos block as requested
        const SizedBox(height: 0),
        _buildSectionTitle("Mindfulness & Meditation"),
        const SizedBox(height: 16),
        _buildMeditationCard(
          title: "5-Minute Breathing Exercise",
          description: "Quick stress relief technique",
          duration: "5 min",
          color: const Color(0xFF9C27B0),
          videoUrl: 'https://www.youtube.com/watch?v=SEfs5TJZ6Nk',
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 12),
        _buildMeditationCard(
          title: "Body Scan Meditation",
          description: "Relax and release tension",
          duration: "10 min",
          color: const Color(0xFF673AB7),
          videoUrl: 'https://www.youtube.com/watch?v=QS2yDmWk0vs',
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 12),
        _buildMeditationCard(
          title: "Gratitude Practice",
          description: "Focus on positive aspects of your day",
          duration: "7 min",
          color: const Color(0xFF3F51B5),
          videoUrl: 'https://www.youtube.com/watch?v=WPPPFqsECz0',
        ),
        const SizedBox(height: 12),
        // Removed Mindfulness & Meditation videos row as requested
        const SizedBox(height: 24),
        const SizedBox(height: 24),
        _buildSectionTitle("Journaling Prompts"),
        const SizedBox(height: 16),
        _buildJournalPromptWithAnswer(
          prompt: "What am I grateful for today?",
          answer:
              "I’m grateful for my breath, a safe space to rest, and one person who cares about me. Noticing these reminds me I’m supported and capable.",
        ),
        _buildJournalPromptWithAnswer(
          prompt: "What small step can I take to feel better right now?",
          answer:
              "I can drink a glass of water, take 5 slow breaths, and message someone I trust. Small actions shift my state gently.",
        ),
        _buildJournalPromptWithAnswer(
          prompt: "What made me smile recently?",
          answer:
              "A kind message and a quiet moment of sunlight. Remembering small joys helps me re-center in the present.",
        ),
        _buildJournalPromptWithAnswer(
          prompt: "Who or what gives me strength?",
          answer:
              "My past self who kept going, my values, and the people who believe in me. Their presence boosts my resilience.",
        ),
        _buildJournalPromptWithAnswer(
          prompt: "What can I let go of to feel lighter?",
          answer:
              "I release the need to be perfect and today’s unhelpful self-criticism. Letting go opens space for peace and progress.",
        ),
      ],
    );
  }

  Widget _buildNutrition() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionTitle("Healthy Eating Tips"),
        const SizedBox(height: 16),
        _buildNutritionCard(
          title: "Balanced Meals",
          description: "Include protein, carbs, and healthy fats in every meal",
          icon: Icons.restaurant,
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 12),
        _buildNutritionCard(
          title: "Portion Control",
          description: "Use your hand as a guide for portion sizes",
          icon: Icons.scale,
          color: const Color(0xFF2196F3),
        ),
        const SizedBox(height: 12),
        _buildNutritionCard(
          title: "Meal Prep",
          description: "Prepare healthy meals in advance for busy days",
          icon: Icons.kitchen,
          color: const Color(0xFFFF9800),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle("Hydration Tracker"),
        const SizedBox(height: 16),
        _buildHydrationTracker(),
        const SizedBox(height: 24),
        _buildSectionTitle("Simple Daily Diet Plan"),
        const SizedBox(height: 16),
        _buildDietPlan(),
      ],
    );
  }

  Widget _buildSleep() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionTitle("Sleep Hygiene Tips"),
        const SizedBox(height: 16),
        _buildSleepTip(
          title: "Consistent Sleep Schedule",
          description: "Go to bed and wake up at the same time every day",
          icon: Icons.schedule,
        ),
        _buildSleepTip(
          title: "Screen-Free Bedroom",
          description: "Avoid screens 1 hour before bedtime",
          icon: Icons.phone_android,
        ),
        _buildSleepTip(
          title: "Comfortable Environment",
          description: "Keep your room cool, dark, and quiet",
          icon: Icons.bed,
        ),
        const SizedBox(height: 24),
        _buildSectionTitle("Relaxation Techniques"),
        const SizedBox(height: 16),
        _buildRelaxationCard(
          title: "Progressive Muscle Relaxation",
          description: "Tense and release each muscle group",
          duration: "15 min",
          videoUrl: 'https://www.youtube.com/watch?v=ihO02wUzgkc',
        ),
        const SizedBox(height: 12),
        _buildRelaxationCard(
          title: "4-7-8 Breathing",
          description: "Inhale for 4, hold for 7, exhale for 8",
          duration: "5 min",
          videoUrl: 'https://www.youtube.com/watch?v=YRPh_GaiL8s',
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCategoryCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required List<String> videos,
  }) {
    return Container(
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Removed video sub-items as requested
          const SizedBox(height: 12),
          _buildBenefitsSection(title, color),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(String title, Color color) {
    final benefits = _getBenefitsForCategory(title);
    if (benefits.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key benefits',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ...benefits.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                b,
                style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getBenefitsForCategory(String title) {
    switch (title) {
      case "Yoga & Flexibility":
        return [
          'Improves flexibility and joint mobility',
          'Reduces stress and promotes relaxation',
          'Enhances posture and balance',
        ];
      case "Cardio & Endurance":
        return [
          'Boosts heart and lung health',
          'Burns calories and aids weight management',
          'Improves stamina and daily energy levels',
        ];
      case "Strength & Toning":
        return [
          'Builds lean muscle and bone density',
          'Increases metabolism and functional strength',
          'Improves posture and injury resilience',
        ];
      default:
        return [];
    }
  }

  Widget _buildMeditationCard({
    required String title,
    required String description,
    required String duration,
    required Color color,
    required String videoUrl,
  }) {
    return Container(
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: GestureDetector(
              onTap: () => _openExternalUrl(videoUrl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_ytIdFromUrl(videoUrl) != null)
                      Image.network(
                        'https://img.youtube.com/vi/${_ytIdFromUrl(videoUrl)!}/hqdefault.jpg',
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(color: Colors.black26),
                      )
                    else
                      Container(color: Colors.black26),
                    Container(color: Colors.black26.withOpacity(0.25)),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _ytIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'];
      }
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      }
    } catch (_) {}
    return null;
  }

  void _openExternalUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open video')));
      }
    }
  }

  Widget _buildJournalPrompt(String prompt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          const Icon(Icons.edit_note, color: Color(0xFF9C27B0), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              prompt,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalPromptWithAnswer({
    required String prompt,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: const Icon(
            Icons.edit_note,
            color: Color(0xFF9C27B0),
            size: 24,
          ),
          title: Text(
            prompt,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3748),
              fontWeight: FontWeight.w700,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationTracker() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          const Text(
            "Today's Water Intake",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(8, (index) {
              final filled = index < _waterGlasses;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _waterGlasses = index + 1;
                  });
                },
                onLongPress: () {
                  setState(() {
                    _waterGlasses = 0;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: filled ? const Color(0xFF2196F3) : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            "${_waterGlasses}/8 glasses",
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2196F3),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Builder(
            builder: (_) {
              final bool hydrated = _waterGlasses >= 6; // simple threshold
              return Text(
                hydrated ? 'You are well hydrated' : 'You need more water',
                style: TextStyle(
                  fontSize: 13,
                  color:
                      hydrated
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFD32F2F),
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (_waterGlasses < 8) _waterGlasses++;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add glass'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _waterGlasses = 0;
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDietPlan() {
    final items = <Map<String, String>>[
      {'meal': 'Breakfast', 'desc': 'Oats/poha + fruit + 1 glass water'},
      {'meal': 'Mid-Morning', 'desc': 'Buttermilk/green tea + nuts'},
      {'meal': 'Lunch', 'desc': 'Chapati/brown rice + dal + veggies + salad'},
      {'meal': 'Evening', 'desc': 'Fruit/yoghurt + 1 glass water'},
      {'meal': 'Dinner', 'desc': 'Light khichdi/soup + veggies'},
    ];

    return Container(
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
        children:
            items
                .map(
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6, right: 10),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                i['meal']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                i['desc']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildSleepTip({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9C27B0), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelaxationCard({
    required String title,
    required String description,
    required String duration,
    required String videoUrl,
  }) {
    return Container(
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: GestureDetector(
              onTap: () => _openExternalUrl(videoUrl),
              child: ClipOval(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_ytIdFromUrl(videoUrl) != null)
                      Image.network(
                        'https://img.youtube.com/vi/${_ytIdFromUrl(videoUrl)!}/hqdefault.jpg',
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(color: Colors.black26),
                      )
                    else
                      Container(color: Colors.black26),
                    Container(color: Colors.black26.withOpacity(0.25)),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9C27B0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthFloatingBackButton(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        decoration: _AppStyles.floatingBackButtonDecoration,
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

class _VideoPlayerCard extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String duration;
  const _VideoPlayerCard({
    required this.videoUrl,
    required this.title,
    required this.duration,
  });

  @override
  State<_VideoPlayerCard> createState() => _VideoPlayerCardState();
}

class _VideoPlayerCardState extends State<_VideoPlayerCard> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Only initialize video controller for non-YouTube URLs
    if (!widget.videoUrl.contains('youtube.com') &&
        !widget.videoUrl.contains('youtu.be')) {
      _controller = VideoPlayerController.network(widget.videoUrl);
      _initializeVideo();
    } else {
      _initialized = true; // For YouTube URLs, we'll show thumbnail
    }
  }

  Future<void> _initializeVideo() async {
    if (_controller == null) return;
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _initialized = true;
          // Don't auto play - only play when user clicks
        });
      }
    } catch (e) {
      // Handle video initialization error
      if (mounted) {
        setState(() {
          _initialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Only dispose controller if it was initialized
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(16));

    final bool isYouTube =
        widget.videoUrl.contains('youtube.com') ||
        widget.videoUrl.contains('youtu.be');

    Widget content = Container(
      width: 180,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: borderRadius,
            child:
                _initialized ? _buildVideoPlayer() : _buildLoadingIndicator(),
          ),
          const SizedBox(height: 8),
          Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            widget.duration,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (isYouTube) {
      // For YouTube items, clicking anywhere on the card opens YouTube
      content = GestureDetector(
        onTap: _openYouTubeVideo,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }

  Widget _buildVideoPlayer() {
    // Always render at a consistent 16:9 for visual consistency
    // YouTube links show a thumbnail and open externally
    if (widget.videoUrl.contains('youtube.com') ||
        widget.videoUrl.contains('youtu.be')) {
      return _buildYouTubeThumbnail();
    }

    if (_controller == null) return _buildLoadingIndicator();

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: VideoPlayer(_controller!),
          ),
          // Show play button overlay when not playing
          if (!_controller!.value.isPlaying)
            GestureDetector(
              onTap: _playVideo,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          // Show pause button when playing
          if (_controller!.value.isPlaying)
            GestureDetector(
              onTap: _pauseVideo,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pause, color: Colors.white, size: 30),
              ),
            ),
          // Full screen button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _openFullScreen,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouTubeThumbnail() {
    final String? id = _youtubeIdFromUrl(widget.videoUrl);
    final String? thumbUrl =
        id != null ? 'https://img.youtube.com/vi/$id/hqdefault.jpg' : null;

    return GestureDetector(
      onTap: _openYouTubeVideo,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  thumbUrl != null
                      ? Image.network(
                        thumbUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(color: Colors.black12),
                      )
                      : Container(color: Colors.black12),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _youtubeIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'];
      }
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      }
    } catch (_) {}
    return null;
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: 100,
      color: Colors.black12,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  void _playVideo() {
    if (_controller != null) {
      setState(() {
        _controller!.play();
      });
    }
  }

  void _pauseVideo() {
    if (_controller != null) {
      setState(() {
        _controller!.pause();
      });
    }
  }

  void _openFullScreen() {
    if (_controller != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => _FullScreenVideoPlayer(
                controller: _controller!,
                title: widget.title,
              ),
        ),
      );
    }
  }

  void _openYouTubeVideo() async {
    final Uri url = Uri.parse(widget.videoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open YouTube video')),
      );
    }
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String text;
  const _TipCard({
    required this.icon,
    required this.iconBg,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.black54, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AwarenessPage extends StatelessWidget {
  const AwarenessPage({super.key});

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
              ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.campaign,
                          size: 40,
                          color: Color(0xFFFF9800),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Awareness Center",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Color(0xFF2D3748),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Important awareness information and campaigns",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF718096),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Awareness Topics
                  _buildAwarenessCard(
                    "Women's Rights",
                    "Know your rights and legal protections",
                    Icons.gavel,
                    const Color(0xFF9C27B0),
                    () => _showAwarenessDialog(
                      context,
                      "Women's Rights",
                      "Every woman has the right to safety, equality, and freedom from violence. Know your legal rights and available protections.",
                      "https://www.womendeserve.org/women-rights",
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildAwarenessCard(
                    "Cyber Safety",
                    "Protect yourself online and in digital spaces",
                    Icons.security,
                    const Color(0xFF673AB7),
                    () => _showAwarenessDialog(
                      context,
                      "Cyber Safety",
                      "Be cautious of online predators, protect personal information, and report cyberbullying or harassment.",
                      "https://cybercrime.gov.in/Webform/Crime_OnlineSafetyTips.aspx",
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildAwarenessCard(
                    "Workplace Safety",
                    "Know your rights in professional environments",
                    Icons.work,
                    const Color(0xFF3F51B5),
                    () => _showAwarenessDialog(
                      context,
                      "Workplace Safety",
                      "You have the right to a harassment-free workplace. Know how to report incidents and seek support.",
                      "https://www.vantagecircle.com/en/blog/womens-safety-workplace/",
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildAwarenessCard(
                    "Health Awareness",
                    "Important health information for women",
                    Icons.favorite,
                    const Color(0xFFE91E63),
                    () => _showAwarenessDialog(
                      context,
                      "Health Awareness",
                      "Regular health checkups, mental health support, and knowing the signs of health issues are crucial.",
                      "https://www.niehs.nih.gov/research/programs/wha",
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildAwarenessCard(
                    "Financial Safety",
                    "Protect yourself from financial abuse",
                    Icons.account_balance_wallet,
                    const Color(0xFF4CAF50),
                    () => _showAwarenessDialog(
                      context,
                      "Financial Safety",
                      "Maintain financial independence, protect banking information, and be aware of financial manipulation tactics.",
                      "https://www.fbi.gov/services/threat-based-reports/financial-fraud",
                    ),
                  ),
                ],
              ),
              _buildAwarenessFloatingBackButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAwarenessFloatingBackButton(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        decoration: _AppStyles.floatingBackButtonDecoration,
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

  Widget _buildAwarenessCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  void _showAwarenessDialog(
    BuildContext context,
    String title,
    String content,
    String url, // add URL parameter
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () async {
                  final Uri uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open link')),
                    );
                  }
                },
                child: const Text('Learn More'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it!'),
              ),
            ],
          ),
    );
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final String title;

  const _FullScreenVideoPlayer({required this.controller, required this.title});

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  bool _showControls = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.controller.value.isPlaying;
    widget.controller.addListener(_videoListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_videoListener);
    super.dispose();
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = widget.controller.value.isPlaying;
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        widget.controller.pause();
      } else {
        widget.controller.play();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video player
          Center(
            child: AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio,
              child: VideoPlayer(widget.controller),
            ),
          ),
          // Controls overlay
          if (_showControls)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Column(
                children: [
                  // Top bar with title and close button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ),
                  // Center play/pause button
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bottom progress bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: VideoProgressIndicator(
                      widget.controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.white,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.black26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Tap to toggle controls
          GestureDetector(
            onTap: _toggleControls,
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}
