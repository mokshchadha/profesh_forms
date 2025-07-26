import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:profesh_forms/constants.dart';
import 'package:profesh_forms/screens/already_applied_screen.dart';
import '../services/api_service.dart';

class UploadCVScreen extends StatefulWidget {
  final String jobId;
  final Map<String, String> userData;

  const UploadCVScreen({
    super.key,
    required this.jobId,
    required this.userData,
  });

  @override
  State<UploadCVScreen> createState() => _UploadCVScreenState();
}

class _UploadCVScreenState extends State<UploadCVScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _uploadController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  File? _selectedFile;  // Changed from _selectedVideo to _selectedFile for consistency
  File? _selectedVideo; // Added this variable that was missing
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

  Future<void> _uploadVideo() async {
    if (_selectedVideo == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    _uploadController.repeat();

    // Simulate upload progress
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) { // Added mounted check for safety
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

      if (mounted) { // Added mounted check
        setState(() {
          _isUploading = false;
        });

        if (response['success'] == true) {
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
        } else {
          // Handle upload failure
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Handle errors
      _uploadController.stop();
      _uploadController.reset();
      
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading video: $e'),
            backgroundColor: Colors.red,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  Expanded(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildUploadArea(),
                    ),
                  ),
                  _buildActionButtons(),
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
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: ThemeColors.lime.color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Upload Video Resume',
          style: TextStyle(
            color: ThemeColors.lime.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadArea() {
    return Center(
      child: GestureDetector(
        onTap: _isUploading ? null : _pickVideo,
        child: Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: ThemeColors.slateGreen.color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _selectedVideo != null
                  ? ThemeColors.lime.color
                  : ThemeColors.neutral4.color,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: _isUploading ? _buildUploadProgress() : _buildUploadContent(),
        ),
      ),
    );
  }

  Widget _buildUploadContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_selectedVideo == null) ...[
          Icon(
            Icons.videocam,
            size: 80,
            color: ThemeColors.lime.color,
          ),
          const SizedBox(height: 20),
          const Text(
            'Upload Video Resume',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Optional: Record or upload a video introduction',
            style: TextStyle(
              color: ThemeColors.neutral3.color,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ] else ...[
          Icon(
            Icons.video_file,
            size: 80,
            color: ThemeColors.lime.color,
          ),
          const SizedBox(height: 20),
          const Text(
            'Video Selected',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedVideo!.path.split('/').last,
            style: TextStyle(
              color: ThemeColors.neutral3.color,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildUploadProgress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RotationTransition(
          turns: _rotationAnimation,
          child: Icon(
            Icons.video_camera_back,
            size: 80,
            color: ThemeColors.lime.color,
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'Uploading Video...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: 200,
          height: 8,
          decoration: BoxDecoration(
            color: ThemeColors.neutral4.color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _uploadProgress,
            child: Container(
              decoration: BoxDecoration(
                color: ThemeColors.lime.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${(_uploadProgress * 100).toInt()}%',
          style: TextStyle(
            color: ThemeColors.lime.color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          if (_selectedVideo != null) ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadVideo,
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
                    Icon(Icons.upload, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Upload Video',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: _isUploading ? null : _skipVideo,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: ThemeColors.lime.color, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.skip_next, color: ThemeColors.lime.color, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Skip Video & Submit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.lime.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}