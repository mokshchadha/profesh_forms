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
  late AnimationController _confettiController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _slideAnimation;

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

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
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
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    if (widget.showDownloadButton) {
      _pulseController.repeat(reverse: true);
      _confettiController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                            MediaQuery.of(context).padding.top - 
                            MediaQuery.of(context).padding.bottom - 40,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFloatingElements(),
                      const SizedBox(height: 20),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildSuccessIcon(),
                      ),
                      const SizedBox(height: 30),
                      AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: _buildContentCard(),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      if (widget.showDownloadButton) ...[
                        _buildDownloadButton(),
                        const SizedBox(height: 16),
                      ],
                      _buildHomeButton(),
                      const SizedBox(height: 20),
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

  Widget _buildFloatingElements() {
    if (!widget.showDownloadButton) return const SizedBox.shrink();
    
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _confettiController,
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: List.generate(6, (index) {
              final screenWidth = MediaQuery.of(context).size.width;
              final baseX = screenWidth / 2;
              final offset = Offset(
                (index * 50.0) - 125 + (baseX - screenWidth / 2),
                -20 + (_confettiController.value * 80),
              );
              return Positioned(
                left: baseX + offset.dx,
                top: 40 + offset.dy,
                child: Transform.rotate(
                  angle: _confettiController.value * 6.28 * (index + 1),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: [
                        ThemeColors.lime500.color,
                        ThemeColors.mauve300.color,
                        ThemeColors.slateGreen200.color,
                      ][index % 3],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            ThemeColors.lime200.color.withValues(alpha: 0.3),
            ThemeColors.lime500.color.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Container(
        margin: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ThemeColors.lime200.color,
              ThemeColors.lime500.color,
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ThemeColors.lime500.color.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          widget.showDownloadButton ? Icons.check_circle_rounded : Icons.info_rounded,
          size: 45,
          color: ThemeColors.slateGreen900.color,
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeColors.neutral1.color.withValues(alpha: 0.08),
            ThemeColors.slateGreen100.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ThemeColors.slateGreen200.color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.black.color.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: ThemeColors.neutral1.color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeColors.slateGreen900.color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeColors.slateGreen200.color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              widget.message,
              style: TextStyle(
                color: ThemeColors.neutral2.color,
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (widget.showDownloadButton) ...[
            const SizedBox(height: 20),
            _buildSuccessFeatures(),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessFeatures() {
    final features = [
      {'icon': Icons.notifications_active, 'text': 'You\'ll receive updates via email'},
      {'icon': Icons.speed, 'text': 'Fast-track review process'},
      {'icon': Icons.mobile_friendly, 'text': 'Download our app for more opportunities'},
    ];

    return Column(
      children: features.take(1).map((feature) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: ThemeColors.mauve300.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ThemeColors.mauve300.color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              feature['icon'] as IconData,
              color: ThemeColors.mauve300.color,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature['text'] as String,
                style: TextStyle(
                  color: ThemeColors.neutral2.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildDownloadButton() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ThemeColors.lime200.color,
              ThemeColors.lime500.color,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.lime500.color.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _launchProfeshApp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: ThemeColors.slateGreen900.color,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.download_rounded,
                size: 20,
                color: ThemeColors.slateGreen900.color,
              ),
              const SizedBox(width: 10),
              Text(
                'Download Profesh App',
                style: TextStyle(
                  fontSize: 16,
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

  Widget _buildHomeButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeColors.mauve300.color,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.mauve300.color.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: ThemeColors.mauve300.color.withValues(alpha: 0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_rounded,
              color: ThemeColors.mauve300.color,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Back to Home',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ThemeColors.mauve300.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}