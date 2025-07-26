import 'package:flutter/material.dart';
import 'package:profesh_forms/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class AlreadyAppliedScreen extends StatefulWidget {
  final String title;
  final String message;
  final bool showDownloadButton;

  const AlreadyAppliedScreen({
    super.key,
    required this.title,
    required this.message,
    required this.showDownloadButton,
  });

  @override
  State<AlreadyAppliedScreen> createState() => _AlreadyAppliedScreenState();
}

class _AlreadyAppliedScreenState extends State<AlreadyAppliedScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _launchProfeshApp() async {
    const url = 'https://profesh-app.netlify.app/';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildSuccessIcon(),
                  ),
                  const SizedBox(height: 40),
                  _buildTitle(),
                  const SizedBox(height: 20),
                  _buildMessage(),
                  const SizedBox(height: 60),
                  if (widget.showDownloadButton) _buildDownloadButton(),
                  const SizedBox(height: 20),
                  _buildHomeButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: ThemeColors.lime.color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: ThemeColors.lime.color,
          width: 3,
        ),
      ),
      child: Icon(
        widget.showDownloadButton ? Icons.check_circle : Icons.info,
        size: 60,
        color: ThemeColors.lime.color,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage() {
    return Text(
      widget.message,
      style: TextStyle(
        color: ThemeColors.neutral2.color,
        fontSize: 18,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDownloadButton() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _launchProfeshApp,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.lime.color,
            foregroundColor: ThemeColors.black.color,
            elevation: 8,
            shadowColor: ThemeColors.lime.color.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download, size: 24),
              SizedBox(width: 12),
              Text(
                'Download Profesh App',
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

  Widget _buildHomeButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: ThemeColors.lime.color, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, color: ThemeColors.lime.color, size: 24),
            const SizedBox(width: 12),
            Text(
              'Back to Home',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeColors.lime.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}