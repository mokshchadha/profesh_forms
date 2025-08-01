import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:profesh_forms/constants.dart';

enum RecordingStatus { initial, recording, paused }

class VideoRecorderScreen extends StatefulWidget {
  final String? jobId;
  final String? jobDescription;
  final String? jobTitle;
  final String? companyName;
  
  const VideoRecorderScreen({
    super.key,
    this.jobId,
    this.jobDescription,
    this.jobTitle,
    this.companyName,
  });

  @override
  State<VideoRecorderScreen> createState() => _VideoRecorderScreenState();
}

class _VideoRecorderScreenState extends State<VideoRecorderScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  XFile? _video;
  int _timer = 0;
  RecordingStatus _status = RecordingStatus.initial;
  bool _isInitialized = false;
  bool _showJobDescription = true;
  Timer? _recordingTimer;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  // Constants
  static const int maxRecordingTime = 90; // 90 seconds

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCamera();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(seconds: maxRecordingTime),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));
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
        _fadeController.forward();
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _startRecording() async {
    if (_status == RecordingStatus.initial) {
      try {
        await _controller!.startVideoRecording();
        setState(() {
          _status = RecordingStatus.recording;
          _timer = 0;
          _showJobDescription = false;
        });
        _progressController.forward();
        _pulseController.repeat(reverse: true);
        _startTimer();
      } catch (e) {
        debugPrint('Error starting recording: $e');
      }
    }
  }

  Future<void> _pauseRecording() async {
    if (_status == RecordingStatus.recording) {
      try {
        await _controller!.pauseVideoRecording();
        setState(() {
          _status = RecordingStatus.paused;
        });
        _recordingTimer?.cancel();
        _pulseController.stop();
        _progressController.stop();
      } catch (e) {
        debugPrint('Error pausing recording: $e');
      }
    }
  }

  Future<void> _resumeRecording() async {
    if (_status == RecordingStatus.paused) {
      try {
        await _controller!.resumeVideoRecording();
        setState(() {
          _status = RecordingStatus.recording;
        });
        _pulseController.repeat(reverse: true);
        _progressController.forward();
        _startTimer();
      } catch (e) {
        debugPrint('Error resuming recording: $e');
      }
    }
  }

  Future<void> _saveRecording() async {
    if (_status == RecordingStatus.paused ||
        _status == RecordingStatus.recording) {
      try {
        final XFile file = await _controller!.stopVideoRecording();
        setState(() {
          _video = file;
          _status = RecordingStatus.initial;
          _timer = 0;
        });
        _recordingTimer?.cancel();
        _pulseController.stop();
        _progressController.reset();
        if (mounted && _video != null) {
          Navigator.pop(context, XFile(_video!.path));
        }
      } catch (e) {
        debugPrint('Error saving recording: $e');
      }
    }
  }

  void _startTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timer++;
        });
        if (_timer >= maxRecordingTime) {
          _saveRecording();
        }
      }
    });
  }

  void _toggleJobDescription() {
    setState(() {
      _showJobDescription = !_showJobDescription;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller?.dispose();
    _recordingTimer?.cancel();
    _fadeController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: !_isInitialized
          ? _buildLoadingScreen()
          : Stack(
              children: [
                _buildCameraPreview(),
                _buildTopOverlay(),
                if (_showJobDescription && _status != RecordingStatus.recording)
                  _buildJobDescriptionOverlay(),
                _buildBottomControls(),
                if (_status == RecordingStatus.recording ||
                    _status == RecordingStatus.paused)
                  _buildRecordingIndicators(),
              ],
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ThemeColors.slateGreen900.color,
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: ThemeColors.lime500.color,
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
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
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Positioned.fill(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (_controller?.value.isRecordingVideo ?? false) {
                        _controller!.stopVideoRecording();
                      }
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: ThemeColors.neutral1.color,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Video Introduction',
                        style: TextStyle(
                          color: ThemeColors.neutral1.color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.jobTitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.jobTitle!,
                          style: TextStyle(
                            color: ThemeColors.lime200.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_status != RecordingStatus.recording) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      onPressed: _toggleJobDescription,
                      icon: Icon(
                        _showJobDescription
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: ThemeColors.mauve300.color,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobDescriptionOverlay() {
    return Positioned(
      top: 120,
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        opacity: _showJobDescription ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: ThemeColors.lime200.color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Interview Tips',
                    style: TextStyle(
                      color: ThemeColors.lime200.color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (widget.jobDescription != null) ...[
                Text(
                  'Job Overview:',
                  style: TextStyle(
                    color: ThemeColors.mauve300.color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.jobDescription!,
                  style: TextStyle(
                    color: ThemeColors.neutral2.color,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'Recording Tips:',
                style: TextStyle(
                  color: ThemeColors.mauve300.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              ..._buildTips(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTips() {
    final tips = [
      'Introduce yourself and explain why you\'re interested',
      'Highlight relevant experience and skills',
      'Keep it under 90 seconds and speak clearly',
      'Ensure good lighting and minimal background noise',
    ];

    return tips.map((tip) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: ThemeColors.slateGreen200.color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: ThemeColors.neutral3.color,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  Widget _buildRecordingIndicators() {
    final isRecording = _status == RecordingStatus.recording;
    return Positioned(
      top: 120,
      left: 16,
      right: 16,
      child: Column(
        children: [
          // Recording indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isRecording)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                isRecording ? 'RECORDING' : 'PAUSED',
                style: TextStyle(
                  color: isRecording ? Colors.red : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress bar
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ThemeColors.lime200.color,
                          ThemeColors.lime500.color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          
          // Timer
          Text(
            '${_formatTime(_timer)} / ${_formatTime(maxRecordingTime)}',
            style: TextStyle(
              color: ThemeColors.neutral1.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_status == RecordingStatus.initial) ...[
                  Text(
                    'Ensure your entire face is visible & there are no background sounds',
                    style: TextStyle(
                      color: ThemeColors.neutral2.color,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Recording button
                    GestureDetector(
                      onTap: () {
                        if (_status == RecordingStatus.initial) {
                          _startRecording();
                        } else if (_status == RecordingStatus.recording) {
                          _pauseRecording();
                        } else if (_status == RecordingStatus.paused) {
                          _resumeRecording();
                        }
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: Colors.transparent,
                        ),
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: _status == RecordingStatus.recording
                                ? 24
                                : 60,
                            height: _status == RecordingStatus.recording
                                ? 24
                                : 60,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(
                                _status == RecordingStatus.recording ? 4 : 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_status == RecordingStatus.paused ||
                        _status == RecordingStatus.recording) ...[
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: _saveRecording,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeColors.lime500.color,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_status == RecordingStatus.recording ||
                    _status == RecordingStatus.paused) ...[
                  const SizedBox(height: 16),
                  Text(
                    _status == RecordingStatus.recording
                        ? 'Tap to pause recording'
                        : 'Tap to resume recording',
                    style: TextStyle(
                      color: ThemeColors.neutral3.color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}