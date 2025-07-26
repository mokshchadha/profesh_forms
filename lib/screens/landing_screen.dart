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
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ThemeColors.slateGreen900.color,
              ThemeColors.black.color,
            ],
          ),
        ),
        child: isLoading
            ? _buildLoadingScreen()
            : _buildJobContent(),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: ThemeColors.lime.color,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Loading job details...',
            style: TextStyle(
              color: ThemeColors.neutral2.color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildJobCard(),
                  const SizedBox(height: 40),
                  _buildApplyButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ThemeColors.lime.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.work_outline,
            color: ThemeColors.lime.color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Job Opportunity',
          style: TextStyle(
            color: ThemeColors.lime.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildJobCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.slateGreen.color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ThemeColors.lime.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: ThemeColors.lime.color,
                child: Text(
                  jobData?['company']?[0] ?? 'C',
                  style: TextStyle(
                    color: ThemeColors.black.color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jobData?['title'] ?? 'Software Engineer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      jobData?['company'] ?? 'Tech Company',
                      style: TextStyle(
                        color: ThemeColors.neutral3.color,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Job Description',
            style: TextStyle(
              color: ThemeColors.lime.color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            jobData?['description'] ?? 
            'We are looking for a talented developer to join our team. This is an exciting opportunity to work on cutting-edge projects and grow your career.',
            style: TextStyle(
              color: ThemeColors.neutral2.color,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInfoChip(Icons.location_on, jobData?['location'] ?? 'Remote'),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.access_time, jobData?['type'] ?? 'Full-time'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ThemeColors.lime.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: ThemeColors.lime.color,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: ThemeColors.lime.color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 56,
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
            backgroundColor: ThemeColors.lime.color,
            foregroundColor: ThemeColors.black.color,
            elevation: 8,
            shadowColor: ThemeColors.lime.color.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.send,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Apply Now',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
