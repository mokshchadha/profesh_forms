// Create this file: lib/screens/error_screen.dart

import 'package:flutter/material.dart';
import 'package:profesh_forms/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final String? debugInfo;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final bool showHomeButton;

  const ErrorScreen({
    super.key,
    required this.title,
    required this.message,
    this.debugInfo,
    this.onRetry,
    this.showRetryButton = true,
    this.showHomeButton = true,
  });

  // Predefined error screens
  static ErrorScreen jobNotFound({String? jobId, VoidCallback? onRetry}) {
    return ErrorScreen(
      title: 'Job Not Found',
      message: 'This job posting is no longer available or the link may be invalid. Please check the URL and try again.',
      debugInfo: jobId != null ? 'Job ID: $jobId' : null,
      onRetry: onRetry,
    );
  }

  static ErrorScreen invalidUrl({String? url, VoidCallback? onRetry}) {
    return ErrorScreen(
      title: 'Invalid URL',
      message: 'The job link appears to be invalid. Please check the URL format and try again.',
      debugInfo: url != null ? 'URL: $url' : null,
      onRetry: onRetry,
    );
  }

  static ErrorScreen networkError({VoidCallback? onRetry}) {
    return ErrorScreen(
      title: 'Connection Error',
      message: 'Unable to connect to the server. Please check your internet connection and try again.',
      onRetry: onRetry,
    );
  }

  static ErrorScreen serverError({VoidCallback? onRetry}) {
    return ErrorScreen(
      title: 'Server Error',
      message: 'The server is currently experiencing issues. Please try again later.',
      onRetry: onRetry,
    );
  }

  Future<void> _launchProfeshApp() async {
    const url = downloadApp;
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: try to open in current window
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      // You could show a snackbar here to inform the user
    }
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
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Error icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ThemeColors.red.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: ThemeColors.red.color, width: 2),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      color: ThemeColors.red.color,
                      size: 48,
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Error title
                  Text(
                    title,
                    style: TextStyle(
                      color: ThemeColors.neutral1.color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Error message
                  Text(
                    message,
                    style: TextStyle(
                      color: ThemeColors.neutral2.color,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action buttons
                  Column(
                    children: [
                      if (showRetryButton && onRetry != null) ...[
                        Container(
                          width: 200,
                          constraints: const BoxConstraints(maxWidth: 300),
                          height: 56,
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
                                color: ThemeColors.lime500.color.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: onRetry,
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
                                  Icons.refresh,
                                  size: 20,
                                  color: ThemeColors.slateGreen900.color,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Try Again',
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
                        const SizedBox(height: 16),
                      ],
                      
                      if (showHomeButton) ...[
                        Container(
                          constraints: const BoxConstraints(maxWidth: 300),
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ThemeColors.mauve300.color,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeColors.mauve300.color.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: OutlinedButton(
                            onPressed: _launchProfeshApp,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide.none,
                              backgroundColor: ThemeColors.mauve300.color.withValues(alpha: 0.05),
                              foregroundColor: ThemeColors.mauve300.color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.home_rounded,
                                  color: ThemeColors.mauve300.color,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Go to Main Site',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColors.mauve300.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Debug info (only in debug mode)
                  if (debugInfo != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ThemeColors.neutral4.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ThemeColors.neutral4.color.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Debug Information:',
                            style: TextStyle(
                              color: ThemeColors.neutral3.color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            debugInfo!,
                            style: TextStyle(
                              color: ThemeColors.neutral3.color,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}