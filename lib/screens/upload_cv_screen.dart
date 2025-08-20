import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:profesh_forms/constants.dart';
import 'package:profesh_forms/screens/upload_video_screen.dart';
import 'package:profesh_forms/components/pdf_preview_widget.dart';
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

  XFile? _selectedFile;
  bool _isUploading = false;
  bool _showPreview = false;
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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _uploadController, curve: Curves.linear));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _uploadController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = XFile(result.files.single.path!);
        _showPreview = true;
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedFile = null;
      _showPreview = false;
    });
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    _uploadController.repeat();
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          _uploadProgress = i / 100;
        });
      }
    }

    try {
      final apiService = ApiService();
      final response = await apiService.uploadCV(
        _selectedFile!,
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
              builder: (context) => UploadVideoScreen(
                jobId: widget.jobId,
                userData: widget.userData,
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
            content: Text('Error uploading CV: $e'),
            backgroundColor: ThemeColors.red.color,
          ),
        );
      }
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildProgressIndicator(),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _isUploading
                          ? _buildUploadProgress()
                          : _showPreview && _selectedFile != null
                          ? _buildPreviewArea()
                          : _buildUploadArea(),
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
                'Upload Your CV',
                style: TextStyle(
                  color: ThemeColors.mauve100.color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Step 2 of 3',
                style: TextStyle(
                  color: ThemeColors.slateGreen200.color,
                  fontSize: 14,
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
          _buildProgressStep(2, 'CV', true, false),
          _buildProgressLine(false),
          _buildProgressStep(3, 'Video', false, false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(
    int step,
    String label,
    bool active,
    bool completed,
  ) {
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
                ? Icon(Icons.check, color: ThemeColors.neutral1.color, size: 16)
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

  Widget _buildPreviewArea() {
    return SingleChildScrollView(
      child: PDFPreviewWidget(
        pdfFile: _selectedFile!,
        onReselect: _clearSelection,
        onConfirm: _uploadFile,
        showActions: true,
      ),
    );
  }

  Widget _buildUploadArea() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    return Center(
      child: GestureDetector(
        onTap: _isUploading ? null : _pickFile,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
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
              color: ThemeColors.slateGreen200.color.withValues(alpha: 0.3),
              width: 2,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
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
                  Icons.description_outlined,
                  size: 64,
                  color: ThemeColors.mauve300.color,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Upload Your CV',
                style: TextStyle(
                  color: ThemeColors.neutral1.color,
                  fontSize: isMobile ? 16 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Drag and drop your CV or click to browse',
                style: TextStyle(
                  color: ThemeColors.slateGreen200.color,
                  fontSize: isMobile ? 12 : 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Supported formats: PDF,',
                style: TextStyle(
                  color: ThemeColors.neutral3.color,
                  fontSize: isMobile ? 11 : 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: ThemeColors.lime500.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ThemeColors.lime500.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: ThemeColors.lime200.color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Choose File',
                      style: TextStyle(
                        color: ThemeColors.lime200.color,
                        fontSize: isMobile ? 12 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
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
            color: ThemeColors.lime500.color.withValues(alpha: 0.3),
            width: 2,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _rotationAnimation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ThemeColors.lime500.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.upload_file,
                  size: 64,
                  color: ThemeColors.lime500.color,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Uploading CV...',
              style: TextStyle(
                color: ThemeColors.neutral1.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 250,
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
            const SizedBox(height: 12),
            Text(
              '${(_uploadProgress * 100).toInt()}%',
              style: TextStyle(
                color: ThemeColors.lime200.color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          // Only show upload button when preview is visible and not uploading
          if (_showPreview && _selectedFile != null && !_isUploading) ...[
            // Action buttons are now handled by the PDFPreviewWidget
            const SizedBox.shrink(),
          ],
          // else if (!_showPreview && !_isUploading) ...[
          //   // Show skip button when no file is selected
          //   SizedBox(
          //     width: double.infinity,
          //     height: 60,
          //     child: OutlinedButton(
          //       onPressed: _skipToVideo,
          //       style: OutlinedButton.styleFrom(
          //         side: BorderSide(color: ThemeColors.mauve300.color, width: 2),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(20),
          //         ),
          //       ),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Icon(
          //             Icons.skip_next_rounded,
          //             color: ThemeColors.mauve300.color,
          //             size: 24,
          //           ),
          //           const SizedBox(width: 12),
          //           Text(
          //             'Skip & Continue',
          //             style: TextStyle(
          //               fontSize: 18,
          //               fontWeight: FontWeight.bold,
          //               color: ThemeColors.mauve300.color,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ]
        ],
      ),
    );
  }
}
