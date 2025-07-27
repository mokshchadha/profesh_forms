import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:profesh_forms/constants.dart';
import 'package:profesh_forms/screens/already_applied_screen.dart';
import 'package:profesh_forms/screens/video_recorder_screen.dart';
import '../services/api_service.dart';

class UploadVideoScreen extends StatefulWidget {
  final String jobId;
  final Map<String, String> userData;

  const UploadVideoScreen({
    super.key,
    required this.jobId,
    required this.userData,
  });

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _uploadController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  File? _selectedVideo;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _uploadController = AnimationController(
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
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _uploadController,
      curve: Curves.linear,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _uploadController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      setState(() {
        _selectedVideo = File(result.files.single.path!);
      });
    }
  }

  Future<void> _recordVideo() async {
    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (context) => VideoRecorderScreen(
          jobId: widget.jobId,
          userData: widget.userData,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedVideo = result;
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_selectedVideo == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    _uploadController.repeat();
    for (int i = 0; i <= 100; i += 4) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) {
        setState(() {
          _uploadProgress = i / 100;
        });
      }
    }

    try {
      final apiService = ApiService();
      final response = await apiService.uploadVideo(
        widget.jobId,
        _selectedVideo!,
        widget.userData,
      );

      _uploadController.stop();
      _uploadController.reset();

      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        if (response['success'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AlreadyAppliedScreen(
                title: 'Application Complete!',
                message: 'Your video resume has been uploaded successfully. Thank you for your comprehensive application!',
                showDownloadButton: true,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed. Please try again.'),
              backgroundColor: ThemeColors.red.color,
            ),
          );
        }
      }
    } catch (e) {
      _uploadController.stop();
      _uploadController.reset();
      
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading video: $e'),
            backgroundColor: ThemeColors.red.color,
          ),
        );
      }
    }
  }

  Future<void> _skipVideo() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AlreadyAppliedScreen(
          title: 'Application Submitted!',
          message: 'Your application has been successfully submitted. Thank you for applying!',
          showDownloadButton: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.4, 0.8, 1.0],
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
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                  child: _buildHeader(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0),
                  child: _buildProgressIndicator(),
                ),
                SizedBox(height: isMobile ? 16 : 24),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0),
                    child: Column(
                      children: [
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildUploadArea(),
                        ),
                        SizedBox(height: isMobile ? 20 : 32),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                  child: _buildActionButtons(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: ThemeColors.mauve300.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeColors.mauve300.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: ThemeColors.mauve100.color,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Video Resume',
                style: TextStyle(
                  color: ThemeColors.mauve100.color,
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Step 3 of 3 (Optional)',
                style: TextStyle(
                  color: ThemeColors.slateGreen200.color,
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.slateGreen100.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeColors.slateGreen200.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildProgressStep(1, 'Info', true, true),
          _buildProgressLine(true),
          _buildProgressStep(2, 'CV', true, true),
          _buildProgressLine(true),
          _buildProgressStep(3, 'Video', true, false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, String label, bool active, bool completed) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: completed 
                ? ThemeColors.lime700.color
                : active 
                    ? ThemeColors.lime500.color 
                    : ThemeColors.neutral4.color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: completed || active
                  ? ThemeColors.lime200.color 
                  : ThemeColors.neutral4.color,
              width: 2,
            ),
          ),
          child: Center(
            child: completed
                ? Icon(
                    Icons.check,
                    color: ThemeColors.neutral1.color,
                    size: 16,
                  )
                : Text(
                    step.toString(),
                    style: TextStyle(
                      color: active 
                          ? ThemeColors.slateGreen900.color 
                          : ThemeColors.neutral3.color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: (completed || active)
                ? ThemeColors.lime200.color 
                : ThemeColors.neutral3.color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: active 
              ? ThemeColors.lime500.color 
              : ThemeColors.neutral4.color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: isMobile ? 400 : 500,
      ),
      padding: EdgeInsets.all(isMobile ? 20 : 32),
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
          color: _selectedVideo != null
              ? ThemeColors.lime500.color
              : ThemeColors.slateGreen200.color.withValues(alpha: 0.3),
          width: 2,
          style: _selectedVideo != null 
              ? BorderStyle.solid 
              : BorderStyle.none,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.black.color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _isUploading ? _buildUploadProgress() : _buildUploadContent(),
    );
  }

  Widget _buildUploadContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_selectedVideo == null) ...[
          Container(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.mauve300.color.withValues(alpha: 0.2),
                  ThemeColors.mauve500.color.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.videocam_outlined,
              size: isMobile ? 48 : 64,
              color: ThemeColors.mauve300.color,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            'Add Video Resume',
            style: TextStyle(
              color: ThemeColors.neutral1.color,
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            'Stand out with a personal video introduction',
            style: TextStyle(
              color: ThemeColors.slateGreen200.color,
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 4 : 8),
          Text(
            'Optional but highly recommended',
            style: TextStyle(
              color: ThemeColors.neutral3.color,
              fontSize: isMobile ? 12 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 16 : 24),
          _buildVideoTips(),
          SizedBox(height: isMobile ? 16 : 24),
          // Video recording and upload options
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _recordVideo,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16, 
                      vertical: isMobile ? 10 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColors.lime500.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ThemeColors.lime500.color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.videocam,
                          color: ThemeColors.lime200.color,
                          size: isMobile ? 24 : 28,
                        ),
                        SizedBox(height: isMobile ? 4 : 6),
                        Text(
                          'Record Video',
                          style: TextStyle(
                            color: ThemeColors.lime200.color,
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: _pickVideo,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16, 
                      vertical: isMobile ? 10 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColors.mauve300.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ThemeColors.mauve300.color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.upload_file,
                          color: ThemeColors.mauve300.color,
                          size: isMobile ? 24 : 28,
                        ),
                        SizedBox(height: isMobile ? 4 : 6),
                        Text(
                          'Upload Video',
                          style: TextStyle(
                            color: ThemeColors.mauve300.color,
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            decoration: BoxDecoration(
              color: ThemeColors.lime500.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: ThemeColors.lime500.color,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.video_file,
              size: isMobile ? 48 : 64,
              color: ThemeColors.lime500.color,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            'Video Selected',
            style: TextStyle(
              color: ThemeColors.neutral1.color,
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: ThemeColors.slateGreen900.color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeColors.slateGreen200.color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: ThemeColors.lime200.color,
                  size: isMobile ? 18 : 20,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Flexible(
                  child: Text(
                    _selectedVideo!.path.split('/').last,
                    style: TextStyle(
                      color: ThemeColors.neutral2.color,
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedVideo = null;
                  });
                },
                icon: Icon(
                  Icons.refresh,
                  color: ThemeColors.mauve300.color,
                  size: 18,
                ),
                label: Text(
                  'Choose Different Video',
                  style: TextStyle(
                    color: ThemeColors.mauve300.color,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildVideoTips() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    
    final tips = [
      {'icon': Icons.timer, 'text': 'Keep it under 90 seconds'},
      {'icon': Icons.lightbulb_outline, 'text': 'Good lighting & clear audio'},
      {'icon': Icons.person_outline, 'text': 'Be yourself and smile'},
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
            'Video Tips',
            style: TextStyle(
              color: ThemeColors.mauve300.color,
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          ...tips.map((tip) => Padding(
            padding: EdgeInsets.only(bottom: isMobile ? 6 : 8),
            child: Row(
              children: [
                Icon(
                  tip['icon'] as IconData,
                  color: ThemeColors.slateGreen200.color,
                  size: isMobile ? 14 : 16,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    tip['text'] as String,
                    style: TextStyle(
                      color: ThemeColors.neutral3.color,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildUploadProgress() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        RotationTransition(
          turns: _rotationAnimation,
          child: Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: ThemeColors.lime500.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.video_camera_back,
              size: isMobile ? 48 : 64,
              color: ThemeColors.lime500.color,
            ),
          ),
        ),
        SizedBox(height: isMobile ? 20 : 30),
        Text(
          'Uploading Video...',
          style: TextStyle(
            color: ThemeColors.neutral1.color,
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isMobile ? 4 : 8),
        Text(
          'This may take a few moments',
          style: TextStyle(
            color: ThemeColors.neutral3.color,
            fontSize: isMobile ? 12 : 14,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        Container(
          width: isMobile ? 200 : 250,
          height: 8,
          decoration: BoxDecoration(
            color: ThemeColors.neutral4.color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _uploadProgress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ThemeColors.lime200.color,
                    ThemeColors.lime500.color,
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        Text(
          '${(_uploadProgress * 100).toInt()}%',
          style: TextStyle(
            color: ThemeColors.lime200.color,
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_selectedVideo != null) ...[
          Container(
            width: double.infinity,
            height: isMobile ? 50 : 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.lime200.color,
                  ThemeColors.lime500.color,
                ],
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
              onPressed: _isUploading ? null : _uploadVideo,
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
                    Icons.upload_rounded, 
                    size: isMobile ? 20 : 24,
                    color: ThemeColors.slateGreen900.color,
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Text(
                    'Upload Video',
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
          SizedBox(height: isMobile ? 12 : 16),
        ],
        SizedBox(
          width: double.infinity,
          height: isMobile ? 50 : 60,
          child: OutlinedButton(
            onPressed: _isUploading ? null : _skipVideo,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: ThemeColors.mauve300.color, 
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: ThemeColors.mauve300.color.withValues(alpha: 0.05),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_rounded, 
                  color: ThemeColors.mauve300.color, 
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Text(
                  'Submit Application',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.mauve300.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}