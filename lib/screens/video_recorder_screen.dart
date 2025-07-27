import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profesh_forms/constants.dart';
import 'package:profesh_forms/screens/already_applied_screen.dart';
import '../services/api_service.dart';

class VideoRecorderScreen extends StatefulWidget {
  static const String route = '/video-recorder';
  final String jobId;
  final Map<String, String> userData;
  
  const VideoRecorderScreen({
    super.key,
    required this.jobId,
    required this.userData,
  });

  @override
  State<VideoRecorderScreen> createState() => _VideoRecorderScreenState();
}

class _VideoRecorderScreenState extends State<VideoRecorderScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  XFile? _video;
  int _timer = 0;
  bool isRecording = false;
  bool _isInitialized = false;
  Timer? _recordingTimer;
  
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  
  static const int maxRecordingTime = 90; // 90 seconds max

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeCamera();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
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
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize camera: $e'),
            backgroundColor: ThemeColors.red.color,
          ),
        );
      }
    }
  }

  Future<void> _startVideoRecording() async {
    if (!_controller!.value.isInitialized || isRecording) return;

    try {
      await _controller!.startVideoRecording();
      
      setState(() {
        isRecording = true;
        _timer = 0;
      });

      _pulseController.repeat(reverse: true);
      
      // Haptic feedback
      HapticFeedback.lightImpact();

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _timer++;
          });

          if (_timer >= maxRecordingTime) {
            _stopVideoRecording();
          }
        }
      });
    } catch (e) {
      debugPrint('Recording start error: $e');
      _showError('Failed to start recording: $e');
    }
  }

  Future<void> _stopVideoRecording() async {
    if (!isRecording) return;

    try {
      _recordingTimer?.cancel();
      _pulseController.stop();
      _pulseController.reset();
      
      final XFile file = await _controller!.stopVideoRecording();
      
      setState(() {
        isRecording = false;
        _video = file;
        _timer = 0;
      });

      HapticFeedback.mediumImpact();
      _showVideoPreview();
    } catch (e) {
      debugPrint('Recording stop error: $e');
      _showError('Failed to stop recording: $e');
    }
  }

  void _showVideoPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildVideoPreviewSheet(),
    );
  }

  Widget _buildVideoPreviewSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ThemeColors.slateGreen900.color,
            ThemeColors.black.color,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ThemeColors.neutral3.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Video Preview',
              style: TextStyle(
                color: ThemeColors.neutral1.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: ThemeColors.neutral6.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ThemeColors.slateGreen200.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 64,
                        color: ThemeColors.lime500.color,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Video recorded successfully!',
                        style: TextStyle(
                          color: ThemeColors.neutral2.color,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Duration: ${_formatDuration(_timer)}',
                        style: TextStyle(
                          color: ThemeColors.neutral3.color,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _retakeVideo();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ThemeColors.mauve300.color),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Retake',
                      style: TextStyle(
                        color: ThemeColors.mauve300.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _uploadVideo();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeColors.lime500.color,
                      foregroundColor: ThemeColors.slateGreen900.color,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Use Video',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _retakeVideo() {
    setState(() {
      _video = null;
      _timer = 0;
    });
  }

  Future<void> _uploadVideo() async {
    if (_video == null) return;

    try {
      final apiService = ApiService();
      final response = await apiService.uploadVideo(
        widget.jobId,
        File(_video!.path),
        widget.userData,
      );

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
        _showError('Upload failed. Please try again.');
      }
    } catch (e) {
      _showError('Error uploading video: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: ThemeColors.red.color,
        ),
      );
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller?.dispose();
    _recordingTimer?.cancel();
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: !_isInitialized
              ? _buildLoadingView()
              : Stack(
                  children: [
                    _buildCameraPreview(),
                    _buildOverlay(),
                    _buildTopControls(),
                    _buildBottomControls(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: ThemeColors.lime500.color,
          ),
          const SizedBox(height: 24),
          Text(
            'Initializing Camera...',
            style: TextStyle(
              color: ThemeColors.neutral1.color,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _buildOverlay() {
    if (!isRecording) return const SizedBox.shrink();
    
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: ThemeColors.red.color,
            width: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close,
                color: ThemeColors.neutral1.color,
              ),
            ),
          ),
          if (isRecording)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: ThemeColors.red.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_timer),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ThemeColors.slateGreen200.color.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              isRecording
                  ? 'Recording... Tap to stop'
                  : 'Ensure your entire face is visible & there are no background sounds',
              style: TextStyle(
                color: ThemeColors.neutral1.color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: isRecording ? _stopVideoRecording : _startVideoRecording,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isRecording ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ThemeColors.lime500.color.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isRecording ? ThemeColors.red.color : ThemeColors.red.color,
                          borderRadius: BorderRadius.circular(
                            isRecording ? 8 : 30,
                          ),
                        ),
                        child: isRecording
                            ? const Icon(
                                Icons.stop,
                                color: Colors.white,
                                size: 30,
                              )
                            : const Icon(
                                Icons.videocam,
                                color: Colors.white,
                                size: 30,
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}