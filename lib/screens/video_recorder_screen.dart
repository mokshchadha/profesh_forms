import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:profesh_forms/constants.dart';

class VideoRecorderScreen extends StatefulWidget {
  static const String route = '/video-recorder';
  const VideoRecorderScreen({super.key});
  @override
  State<VideoRecorderScreen> createState() => _VideoRecorderScreenState();
}

class _VideoRecorderScreenState extends State<VideoRecorderScreen> {
  CameraController? _controller;
  XFile? _video;
  int _timer = 0;
  bool isRecording = false;
  Timer? _recordingTimer;
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first);
    print(firstCamera);
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    await _controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future<void> _startVideoRecording() async {
    if (!_controller!.value.isInitialized) {
      return null;
    }

    if (!isRecording) {
      // Start recording
      await _controller!.startVideoRecording();
      isRecording = true;
      setState(() {});

      // Start a timer to track recording duration
      _recordingTimer =
          Timer.periodic(const Duration(seconds: 1), (timer) async {
        print(_timer);
        setState(() {
          _timer++;
        });

        if (_timer > 10) {
          // Stop recording after 90 seconds
          await _stopVideoRecording();
        }
      });
    } else {
      // Pause (stop) recording
      await _stopVideoRecording();
    }
  }

  Future<void> _stopVideoRecording() async {
    if (!isRecording) return;

    isRecording = false;
    _recordingTimer?.cancel();

    final XFile file = await _controller!.stopVideoRecording();
    setState(() {
      _video = file;
      _timer = 0; // Reset timer
    });
    if (_video?.path != null) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => WebVideoPlayer(
      //       url: _video!.path,
      //       isVideoUpload: true,
      //     ),
      //   ),
      // );
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    setState(() {});
  }

  @override
  Future<void> dispose() async {
    await _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        
        appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Tell Us About Yourself',
              style: TextStyle(color: Colors.white),
            )),
        body: _controller == null
            ? Center(
                child: CircularProgressIndicator(
                color: ThemeColors.lavender.color,
              ))
            : Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Expanded(
                      child: CameraPreview(
                        _controller!,
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Center(
                                  child: Text(
                                    ' Ensure your entire face is visible & there are no background sounds',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () => _startVideoRecording(),
                                      child: CircleAvatar(
                                        radius: 34,
                                        backgroundColor: Colors.white,
                                        child: Container(
                                          height: 60,
                                          width: 60,
                                          decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(32)),
                                          child: isRecording
                                              ? const Icon(
                                                  Icons.square,
                                                  color: Colors.white,
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            )),
                      ),
                    )
                  ],
                ),
              ));
  }
}
