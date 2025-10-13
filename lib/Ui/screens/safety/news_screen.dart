import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/services/news_service.dart';
import '../../../data/models/news_models.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final TabController _tabController;

  List<NewsArticle> _safetyNews = [];
  List<NewsArticle> _topHeadlines = [];
  bool _isLoading = true;
  String _errorMessage = '';

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
    _loadNews();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print('📰 Loading news...');

      // Load safety news and top headlines
      final safetyNews = await NewsService.getSafetyNews();
      final topHeadlines = await NewsService.getTopHeadlines();

      setState(() {
        _safetyNews = safetyNews;
        _topHeadlines = topHeadlines;
        _isLoading = false;
      });

      print(
        '✅ Loaded ${safetyNews.length} safety news and ${topHeadlines.length} headlines',
      );
    } catch (e) {
      print('❌ Error loading news: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading news: ${e.toString()}';
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
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.newspaper, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Safety News",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF2D3748),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Stay updated with latest safety news and tips",
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
            onPressed: _loadNews,
            icon: const Icon(Icons.refresh, color: Color(0xFF2196F3)),
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
          color: const Color(0xFF2196F3),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(icon: Icon(Icons.security, size: 20), text: 'Safety News'),
          Tab(icon: Icon(Icons.trending_up, size: 20), text: 'Top Headlines'),
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
            CircularProgressIndicator(color: Color(0xFF2196F3)),
            SizedBox(height: 16),
            Text(
              'Loading latest news...',
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
              onPressed: _loadNews,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
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
      children: [_buildSafetyNewsList(), _buildTopHeadlinesList()],
    );
  }

  Widget _buildSafetyNewsList() {
    if (_safetyNews.isEmpty) {
      return const Center(
        child: Text(
          'No safety news available',
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
      itemCount: _safetyNews.length,
      itemBuilder: (context, index) {
        final article = _safetyNews[index];
        return _buildNewsCard(article);
      },
    );
  }

  Widget _buildTopHeadlinesList() {
    if (_topHeadlines.isEmpty) {
      return const Center(
        child: Text(
          'No headlines available',
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
      itemCount: _topHeadlines.length,
      itemBuilder: (context, index) {
        final article = _topHeadlines[index];
        return _buildNewsCard(article);
      },
    );
  }

  Widget _buildNewsCard(NewsArticle article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openArticle(article),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            article.shortDescription,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (article.urlToImage != null) ...[
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          article.urlToImage!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 32,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        article.source,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      article.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openArticle(NewsArticle article) async {
    final Uri url = Uri.parse(article.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open article')));
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


