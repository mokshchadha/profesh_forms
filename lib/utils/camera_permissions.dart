// Create this file: lib/utils/camera_permissions.dart

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class CameraPermissions {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<bool> requestAllPermissions() async {
    final cameraPermission = await requestCameraPermission();
    final microphonePermission = await requestMicrophonePermission();
    
    return cameraPermission && microphonePermission;
  }

  static Future<bool> checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;
    
    return cameraStatus.isGranted && microphoneStatus.isGranted;
  }

  static void showPermissionDialog(BuildContext context, VoidCallback onRetry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Camera and microphone permissions are required to record videos. Please grant permissions in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}