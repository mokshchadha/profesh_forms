import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:profesh_forms/constants.dart';

class VideoPreviewWidget extends StatefulWidget {
  final File videoFile;
  final VoidCallback onReselect;
  final VoidCallback? onConfirm;
  final bool showActions;
  final bool autoPlay;

  const VideoPreviewWidget({
    super.key,
    required this.videoFile,
    required this.onReselect,
    this.onConfirm,
    this.showActions = true,
    this.autoPlay = false,
  });

  @override
  State<VideoPreviewWidget> createState() => _VideoPreviewWidgetState();
}

class _VideoPreviewWidgetState extends State<VideoPreviewWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitializing = true;
  bool _hasError = false;
  String? _errorMessage;
  Duration? _videoDuration;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      setState(() {
        _isInitializing = true;
        _hasError = false;
        _errorMessage = null;
      });

      _videoPlayerController = VideoPlayerController.file(widget.videoFile);
      await _videoPlayerController!.initialize();

      _videoDuration = _videoPlayerController!.value.duration;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: widget.autoPlay,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: false,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: ThemeColors.lime500.color,
          handleColor: ThemeColors.lime200.color,
          backgroundColor: ThemeColors.neutral4.color.withOpacity(0.3),
          bufferedColor: ThemeColors.slateGreen200.color.withOpacity(0.5),
        ),
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(
              color: ThemeColors.lime500.color,
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: ThemeColors.red.color,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading video',
                    style: TextStyle(
                      color: ThemeColors.neutral1.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: ThemeColors.neutral3.color,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  String _getFileSize() {
    try {
      final bytes = widget.videoFile.lengthSync();
      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1048576) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else if (bytes < 1073741824) {
        return '${(bytes / 1048576).toStringAsFixed(1)} MB';
      } else {
        return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
      }
    } catch (e) {
      return 'Unknown size';
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'Unknown';
    
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeColors.neutral1.color.withOpacity(0.08),
            ThemeColors.slateGreen100.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ThemeColors.lime500.color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.black.color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with file info
          _buildFileInfo(),
          SizedBox(height: isMobile ? 16 : 20),
          
          // Video Preview
          Container(
            height: isMobile ? 300 : 400,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeColors.slateGreen200.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildVideoContent(),
            ),
          ),
          
          if (widget.showActions) ...[
            SizedBox(height: isMobile ? 16 : 20),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildFileInfo() {
    final fileName = widget.videoFile.path.split('/').last;
    final fileSize = _getFileSize();
    final duration = _formatDuration(_videoDuration);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.slateGreen900.color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeColors.slateGreen200.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeColors.lime500.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.videocam,
              color: ThemeColors.lime500.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    color: ThemeColors.neutral1.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Size: $fileSize',
                      style: TextStyle(
                        color: ThemeColors.neutral3.color,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Duration: $duration',
                      style: TextStyle(
                        color: ThemeColors.neutral3.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ThemeColors.lime500.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: ThemeColors.lime500.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'VIDEO',
              style: TextStyle(
                color: ThemeColors.lime200.color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: ThemeColors.lime500.color,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(
                color: ThemeColors.neutral1.color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError || _chewieController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: ThemeColors.red.color,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading video',
              style: TextStyle(
                color: ThemeColors.red.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: TextStyle(
                color: ThemeColors.neutral3.color,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeVideoPlayer,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.lime500.color,
                foregroundColor: ThemeColors.slateGreen900.color,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }

  Widget _buildActionButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: isMobile ? 45 : 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeColors.mauve300.color,
                width: 2,
              ),
            ),
            child: OutlinedButton(
              onPressed: widget.onReselect,
              style: OutlinedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: ThemeColors.mauve300.color.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh,
                    color: ThemeColors.mauve300.color,
                    size: isMobile ? 18 : 20,
                  ),
                  SizedBox(width: isMobile ? 6 : 8),
                  Text(
                    'Choose Different',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.mauve300.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.onConfirm != null) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: isMobile ? 45 : 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ThemeColors.lime200.color,
                    ThemeColors.lime500.color,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ThemeColors.lime500.color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: widget.onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: ThemeColors.slateGreen900.color,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check,
                      color: ThemeColors.slateGreen900.color,
                      size: isMobile ? 18 : 20,
                    ),
                    SizedBox(width: isMobile ? 6 : 8),
                    Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.slateGreen900.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ],
    );
  }
}