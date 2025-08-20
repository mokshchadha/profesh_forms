import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:profesh_forms/constants.dart';
import 'package:pdfrx/pdfrx.dart';

class PDFPreviewWidget extends StatefulWidget {
  final XFile pdfFile;
  final VoidCallback onReselect;
  final VoidCallback? onConfirm;
  final bool showActions;
  final String fileName;
  final String fileUrl;

  const PDFPreviewWidget({
    super.key,
    required this.pdfFile,
    required this.onReselect,
    this.onConfirm,
    this.showActions = true,
    this.fileName = "",
    this.fileUrl = "",
  });

  @override
  State<PDFPreviewWidget> createState() => _PDFPreviewWidgetState();
}

class _PDFPreviewWidgetState extends State<PDFPreviewWidget> {
  PdfViewerController? _pdfViewerController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String? fileSize;

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  void _loadPDF() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    _getFileSize();
    // Add a small delay to show loading state
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _getFileSize() async {
    try {
      final bytes = await widget.pdfFile.length();
      if (bytes < 1024) {
        fileSize = '$bytes B';
      } else if (bytes < 1048576) {
        fileSize = '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        fileSize = '${(bytes / 1048576).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      fileSize = 'Unknown size';
    } finally {
      setState(() {});
    }
  }

  void _onPdfError(Object error) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 10 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeColors.neutral1.color.withValues(alpha: 0.08),
            ThemeColors.slateGreen100.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ThemeColors.lime500.color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.black.color.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with file info
          // _buildFileInfo(),
          SizedBox(height: isMobile ? 16 : 20),

          // PDF Preview
          Container(
            height: isMobile ? 400 : 500,
            decoration: BoxDecoration(
              color: ThemeColors.neutral1.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ThemeColors.slateGreen200.color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildPDFContent(),
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
    final fileName = (widget.fileName.isNotEmpty)
        ? widget.fileName
        : widget.pdfFile.path.split('/').last;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.slateGreen900.color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeColors.slateGreen200.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeColors.lime500.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.picture_as_pdf,
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
                Text(
                  'Size: $fileSize',
                  style: TextStyle(
                    color: ThemeColors.neutral3.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ThemeColors.lime500.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: ThemeColors.lime500.color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              'PDF',
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

  Widget _buildPDFContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: ThemeColors.lime500.color),
            const SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: TextStyle(color: ThemeColors.neutral4.color, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: ThemeColors.red.color, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading PDF',
              style: TextStyle(
                color: ThemeColors.red.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: TextStyle(color: ThemeColors.neutral4.color, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadPDF, child: const Text('Retry')),
          ],
        ),
      );
    }

    try {
      if (widget.fileUrl.isNotEmpty) {
        return PdfViewer.uri(
          Uri.parse(widget.fileUrl),
          controller: _pdfViewerController,
          params: PdfViewerParams(
            // Show loading indicator
            loadingBannerBuilder: (context, bytesDownloaded, totalBytes) =>
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: ThemeColors.lime500.color,
                        value: totalBytes != null
                            ? bytesDownloaded / totalBytes
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading PDF...',
                        style: TextStyle(
                          color: ThemeColors.neutral4.color,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

            // Set background color
            backgroundColor: ThemeColors.neutral1.color,
          ),
        );
      }
      return PdfViewer.file(
        widget.pdfFile.path,
        controller: _pdfViewerController,
        params: PdfViewerParams(
          // Show loading indicator
          loadingBannerBuilder: (context, bytesDownloaded, totalBytes) =>
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: ThemeColors.lime500.color,
                      value: totalBytes != null
                          ? bytesDownloaded / totalBytes
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading PDF...',
                      style: TextStyle(
                        color: ThemeColors.neutral4.color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

          // Set background color
          backgroundColor: ThemeColors.neutral1.color,
        ),
      );
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              color: ThemeColors.neutral4.color,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'PDF Preview',
              style: TextStyle(
                color: ThemeColors.neutral2.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'File selected successfully',
              style: TextStyle(color: ThemeColors.neutral4.color, fontSize: 12),
            ),
          ],
        ),
      );
    }
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
              border: Border.all(color: ThemeColors.mauve300.color, width: 2),
            ),
            child: OutlinedButton(
              onPressed: widget.onReselect,
              style: OutlinedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: ThemeColors.mauve300.color.withValues(
                  alpha: 0.05,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh,
                    color: ThemeColors.mauve300.color,
                    size: isMobile ? 18 : 20,
                  ),
                  SizedBox(width: isMobile ? 6 : 8),
                  Text(
                    'Reupload',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 16,
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
                    color: ThemeColors.lime500.color.withValues(alpha: 0.3),
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
                  padding: EdgeInsets.zero,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
