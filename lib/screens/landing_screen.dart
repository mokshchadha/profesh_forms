import 'package:flutter/material.dart';
import 'package:profesh_forms/constants.dart';
import '../services/api_service.dart';
import 'basic_form_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic>? jobData;
  bool isLoading = true;
  String? jobId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _loadJobData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadJobData() async {
    // Extract jobId from URL parameters (simulate for now)
    jobId = "job123"; // In real app, get from URL params

    final apiService = ApiService();
    final response = await apiService.getJobDetails(jobId!);

    setState(() {
      jobData = response;
      isLoading = false;
    });

    _animationController.forward();
  }

  String _getCompanyImageUrl() {
    if (jobData != null && jobData!['company'] != null) {
      // Use UI Avatars as fallback with company name
      final companyName = jobData!['company'] as String;
      return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(companyName)}&background=B3F00D&color=2A4B4E&size=200&rounded=true&bold=true';
    }
    return 'https://ui-avatars.com/api/?name=Company&background=B3F00D&color=2A4B4E&size=200&rounded=true&bold=true';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.3, 0.7, 1.0],
            colors: [
              ThemeColors.slateGreen900.color,
              ThemeColors.slateGreen700.color,
              ThemeColors.mauve900.color,
              ThemeColors.black.color,
            ],
          ),
        ),
        child: isLoading ? _buildLoadingScreen() : _buildJobContent(),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ThemeColors.mauve100.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: ThemeColors.mauve300.color, width: 2),
            ),
            child: CircularProgressIndicator(
              color: ThemeColors.mauve300.color,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Loading job details...',
            style: TextStyle(
              color: ThemeColors.mauve100.color,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;
    final isMobile = screenWidth <= 600;

    return SafeArea(
      child: Center(
        child: Container(
          width: isDesktop ? 800 : double.infinity,
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopSection(),
                      SizedBox(height: isMobile ? 24 : 40),
                      _buildJobCard(),
                      SizedBox(height: isMobile ? 24 : 40),
                      _buildApplyButton(),
                      if (isDesktop) const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: ThemeColors.slateGreen100.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ThemeColors.slateGreen200.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Company Image Circle on the left
          Container(
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ThemeColors.lime500.color, width: 3),
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.lime500.color.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                _getCompanyImageUrl(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to a default avatar if network image fails
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          ThemeColors.lime200.color,
                          ThemeColors.lime500.color,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        jobData?['company']?[0] ?? 'C',
                        style: TextStyle(
                          color: ThemeColors.slateGreen900.color,
                          fontSize: isMobile ? 24 : 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(width: isMobile ? 16 : 20),

          // Middle content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobData?['title'] ?? 'Software Engineer',
                  style: TextStyle(
                    color: ThemeColors.mauve100.color,
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  jobData?['company'] ?? 'Tech Company',
                  style: TextStyle(
                    color: ThemeColors.slateGreen200.color,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Logo on the right
          Container(
            width: isMobile ? 50 : 60,
            height: isMobile ? 50 : 60,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeColors.neutral1.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeColors.mauve300.color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Image.asset(
              Images.logo.path,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback icon if logo asset is not found
                return Icon(
                  Icons.business,
                  color: ThemeColors.mauve300.color,
                  size: isMobile ? 24 : 32,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeColors.neutral1.color.withValues(alpha: 0.08),
            ThemeColors.slateGreen100.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ThemeColors.slateGreen200.color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.black.color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isMobile ? 20 : 24),
          Container(
            padding: EdgeInsets.all(isMobile ? 14 : 16),
            decoration: BoxDecoration(
              color: ThemeColors.slateGreen900.color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ThemeColors.slateGreen200.color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Description',
                  style: TextStyle(
                    color: ThemeColors.lime200.color,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isMobile ? 10 : 12),
                Text(
                  jobData?['description'] ??
                      'We are looking for a talented developer to join our team. This is an exciting opportunity to work on cutting-edge projects and grow your career.',
                  style: TextStyle(
                    color: ThemeColors.neutral2.color,
                    fontSize: isMobile ? 14 : 16,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoChip(
                      Icons.location_on,
                      jobData?['location'] ?? 'Remote',
                      ThemeColors.mauve300.color,
                      ThemeColors.mauve100.color,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoChip(
                      Icons.access_time,
                      jobData?['type'] ?? 'Full-time',
                      ThemeColors.slateGreen200.color,
                      ThemeColors.slateGreen100.color,
                    ),
                  ],
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      Icons.location_on,
                      jobData?['location'] ?? 'Remote',
                      ThemeColors.mauve300.color,
                      ThemeColors.mauve100.color,
                    ),
                    _buildInfoChip(
                      Icons.access_time,
                      jobData?['type'] ?? 'Full-time',
                      ThemeColors.slateGreen200.color,
                      ThemeColors.slateGreen100.color,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String text,
    Color borderColor,
    Color bgColor,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: borderColor, size: isMobile ? 14 : 16),
          SizedBox(width: isMobile ? 4 : 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: borderColor,
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    final isDesktop = screenWidth > 720;

    return Center(
      child: Container(
        width: isDesktop ? 280 : double.infinity,
        height: isMobile ? 56 : 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ThemeColors.lime200.color, ThemeColors.lime500.color],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.lime500.color.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BasicFormScreen(jobId: jobId!),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: ThemeColors.slateGreen900.color,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.send_rounded,
                size: isMobile ? 20 : 24,
                color: ThemeColors.slateGreen900.color,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Text(
                'Apply Now',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.slateGreen900.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
