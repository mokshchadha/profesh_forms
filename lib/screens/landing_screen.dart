import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:profesh_forms/components/pdf_preview_widget.dart';
import 'package:profesh_forms/components/video_preview_widget.dart';
import 'package:profesh_forms/constants.dart';
import '../services/api_service.dart';
import '../utils/url_utils.dart';
import 'basic_form_screen.dart';
import 'error_screen.dart';

class LandingScreen extends StatefulWidget {
  final String? projectHash;

  const LandingScreen({super.key, this.projectHash});

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
  bool hasError = false;
  String? errorMessage;
  String? projectHash;
  int? statusCode;
  bool showJobDescription = false;

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
    try {
      // Extract projectHash from URL
      projectHash = _extractHashFromUrl();

      if (projectHash == null || projectHash!.isEmpty) {
        setState(() {
          hasError = true;
          errorMessage = 'Invalid job link';
          statusCode = 400;
          isLoading = false;
        });
        return;
      }

      final apiService = ApiService();
      final response = await apiService.getJobDetails(projectHash!);

      if (response['success'] == true) {
        setState(() {
          jobData = response;
          isLoading = false;
          hasError = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          hasError = true;
          errorMessage = response['error'] ?? 'Failed to load job details';
          statusCode = response['statusCode'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Network error';
        statusCode = null;
        isLoading = false;
      });
    }
  }

  void _toggleJobDescription() {
    setState(() {
      showJobDescription = !showJobDescription;
    });
  }

  String? _extractHashFromUrl() {
    try {
      final hash = UrlUtils.extractHashFromUrl();

      if (hash == null) {
        UrlUtils.debugUrl();
      }

      return hash;
    } catch (e) {
      debugPrint('Error extracting hash from URL: $e');
      return null;
    }
  }

  void _handleRetry() {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
      statusCode = null;
    });
    _loadJobData();
  }

  ErrorScreen _getErrorScreen() {
    if (projectHash == null || projectHash!.isEmpty) {
      return ErrorScreen.invalidUrl(
        url: Uri.base.toString(),
        onRetry: _handleRetry,
      );
    }

    if (statusCode == 404) {
      return ErrorScreen.jobNotFound(jobId: projectHash, onRetry: _handleRetry);
    }

    if (statusCode == null ||
        errorMessage?.toLowerCase().contains('network') == true) {
      return ErrorScreen.networkError(onRetry: _handleRetry);
    }

    if (statusCode == 500) {
      return ErrorScreen.serverError(onRetry: _handleRetry);
    }

    return ErrorScreen(
      title: 'Unable to Load Job',
      message:
          errorMessage ?? 'An unexpected error occurred. Please try again.',
      debugInfo: projectHash != null ? 'Job ID: $projectHash' : null,
      onRetry: _handleRetry,
    );
  }

  String _getCompanyImageUrl() {
    if (jobData != null && jobData!['logo'] != null) {
      return jobData!['logo'];
    }
    if (jobData != null && jobData!['company'] != null) {
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
        child: isLoading
            ? _buildLoadingScreen()
            : hasError
            ? _getErrorScreen()
            : _buildJobContent(),
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
          width: isDesktop ? screenWidth * 0.8 : double.infinity,
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTopSection(),
                                  SizedBox(height: 40),
                                  _buildJobCard(),
                                  SizedBox(height: 40),
                                  _buildApplyButton(),
                                  _buildProfeshBranding(),
                                  if (isDesktop) const SizedBox(height: 40),
                                ],
                              ),
                            ),
                            if (jobData?['videoUrl']?.isNotEmpty == true) ...[
                              SizedBox(width: 30),
                              SizedBox(
                                width: 300,
                                child: VideoPreviewWidget(
                                  videoFile: XFile(""),
                                  onReselect: () {},
                                  onConfirm: () {},
                                  showActions: false,
                                  videoUrl: jobData?['videoUrl'],
                                  hideFileInfo: true,
                                  isJobVideo: true,
                                ),
                              ),
                            ],
                          ],
                        )
                      : (jobData?['videoUrl']?.isNotEmpty == true)
                      ? Column(
                          children: [
                            _buildTopSection(),
                            SizedBox(height: 24),
                            Stack(
                              children: [
                                VideoPreviewWidget(
                                  videoFile: XFile(""),
                                  onReselect: () {},
                                  onConfirm: () {},
                                  showActions: false,
                                  videoUrl: jobData?['videoUrl'],
                                  hideFileInfo: true,
                                  isJobVideo: true,
                                ),
                                if (!showJobDescription) ...[
                                  _buildJobDetailsButton(),
                                ],

                                if (showJobDescription) ...[
                                  _buildJobDetailsOverlay(),
                                ],
                              ],
                            ),
                            SizedBox(height: 24),
                            _buildApplyButton(),
                            SizedBox(height: 16),
                            _buildProfeshBranding(),
                          ],
                        )
                      : Column(
                          children: [
                            _buildTopSection(),
                            SizedBox(height: 24),
                            _buildJobCard(),
                            SizedBox(height: 24),
                            _buildApplyButton(),
                            _buildProfeshBranding(),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobData?['title'] ?? 'Job Position',
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
                  jobData?['company'] ?? 'Company',
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
          // Container(
          //   width: isMobile ? 50 : 60,
          //   height: isMobile ? 50 : 60,
          //   padding: const EdgeInsets.all(8),
          //   decoration: BoxDecoration(
          //     color: ThemeColors.neutral1.color.withValues(alpha: 0.1),
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(
          //       color: ThemeColors.mauve300.color.withValues(alpha: 0.3),
          //       width: 1,
          //     ),
          //   ),
          //   child: Image.asset(
          //     Images.logo.path,
          //     fit: BoxFit.contain,
          //     errorBuilder: (context, error, stackTrace) {
          //       return Icon(
          //         Icons.business,
          //         color: ThemeColors.mauve300.color,
          //         size: isMobile ? 24 : 32,
          //       );
          //     },
          //   ),
          // ),
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
                  'Job Brief',
                  style: TextStyle(
                    color: ThemeColors.lime200.color,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isMobile ? 10 : 12),
                Text(
                  jobData?['description'] ?? 'Job description not available',
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildInfoChip(
                          Icons.location_on,
                          jobData?['location'] ?? 'Location not specified',
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
                        if (jobData?['role'] != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoChip(
                            Icons.work,
                            jobData!['role'],
                            ThemeColors.lime200.color,
                            ThemeColors.lime100.color,
                          ),
                        ],
                      ],
                    ),
                    if (jobData?['jdPdf'] != null &&
                        jobData?['jdPdf'] != "") ...[
                      const SizedBox(height: 12),
                      _buildPdfButton(),
                    ],
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip(
                          Icons.location_on,
                          jobData?['location'] ?? 'Location not specified',
                          ThemeColors.mauve300.color,
                          ThemeColors.mauve100.color,
                        ),
                        _buildInfoChip(
                          Icons.access_time,
                          jobData?['type'] ?? 'Full-time',
                          ThemeColors.slateGreen200.color,
                          ThemeColors.slateGreen100.color,
                        ),

                        if (jobData?['role'] != null) ...[
                          _buildInfoChip(
                            Icons.work,
                            jobData!['role'].toString(),
                            ThemeColors.lime200.color,
                            ThemeColors.lime100.color,
                          ),
                        ],
                      ],
                    ),
                    if (jobData?['jdPdf'] != null &&
                        jobData?['jdPdf'] != "") ...[
                      const SizedBox(width: 12),
                      _buildPdfButton(),
                    ],
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
        constraints: const BoxConstraints(maxWidth: 300),
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
            if (projectHash != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BasicFormScreen(jobId: projectHash!),
                ),
              );
            }
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

  Widget _buildPdfButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    final isDesktop = screenWidth > 720;
    return Center(
      child: Container(
        width: isDesktop ? 190 : double.infinity,
        constraints: const BoxConstraints(maxWidth: 300),
        height: 45,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ThemeColors.lime200.color, ThemeColors.lime500.color],
          ),
          borderRadius: BorderRadius.circular(32),
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
            if (jobData?['jdPdf'] != null) {
              _showPdfDialogue(
                jobData?['jdPdf'],
                fileName: jobData?['jdPdfName'],
              );
            }
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.description,
                size: isMobile ? 17 : 20,
                color: ThemeColors.slateGreen900.color,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                'Full Job Description',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
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

  Future<bool?> _showPdfDialogue(String fileUrl, {String? fileName}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth <= 600;

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          backgroundColor: Colors.transparent,
          child: SizedBox(
            height: screenHeight,
            width: isMobile ? screenWidth : screenWidth * .6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ThemeColors.neutral1.color,
                        ),
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.close,
                          color: ThemeColors.neutral6.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: screenHeight * 0.7,
                  width: isMobile ? double.infinity : screenWidth * 0.9,
                  child: SingleChildScrollView(
                    child: PDFPreviewWidget(
                      pdfFile: XFile(""),
                      onReselect: () {},
                      onConfirm: () {},
                      showActions: false,
                      fileUrl: fileUrl,
                      fileName: fileName ?? "",
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _buildProfeshBranding() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Powered by ",
          style: TextStyle(
            color: ThemeColors.neutral1.color,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(
          width: isMobile ? 50 : 60,
          height: isMobile ? 50 : 60,

          child: Image.asset(
            Images.logo.path,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.business,
                color: ThemeColors.mauve300.color,
                size: isMobile ? 24 : 32,
              );
            },
          ),
        ),
      ],
    );
  }

  _buildJobDetailsButton() {
    return Positioned(
      right: 0,
      left: 0,
      bottom: 80,
      child: Center(
        child: Container(
          width: 100,
          constraints: const BoxConstraints(maxWidth: 300),
          height: 45,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ThemeColors.mauve500.color, ThemeColors.mauve700.color],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: ThemeColors.mauve500.color.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => _toggleJobDescription(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: ThemeColors.neutral1.color,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 2),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.info, size: 17, color: ThemeColors.neutral1.color),
                  SizedBox(width: 2),
                  Text(
                    'Job Details',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.neutral1.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildJobDetailsOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThemeColors.lime500.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            _buildJobCard(),
            Positioned(
              top: 0,
              left: 0,
              child: GestureDetector(
                onTap: () {
                  _toggleJobDescription();
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(color: ThemeColors.neutral3.color),
                  ),
                  width: 40,
                  height: 40,
                  child: Icon(Icons.close, color: ThemeColors.neutral3.color),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
