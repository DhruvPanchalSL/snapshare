import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../models/transfer_model.dart';
import '../services/transfer_service.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/qr_display.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  _UploadState _state = _UploadState.idle;
  double _uploadProgress = 0;
  TransferModel? _transfer;
  String? _errorMessage;

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: kIsWeb,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    if (picked.size > 50 * 1024 * 1024) {
      setState(() {
        _errorMessage = 'File exceeds 50MB limit.';
        _state = _UploadState.error;
      });
      return;
    }

    setState(() {
      _state = _UploadState.uploading;
      _uploadProgress = 0;
      _errorMessage = null;
    });

    try {
      TransferModel transfer;
      if (kIsWeb) {
        transfer = await TransferService.uploadBytes(
          bytes: picked.bytes!,
          fileName: picked.name,
          mimeType: _guessMime(picked.name),
          onProgress: (p) => setState(() => _uploadProgress = p),
        );
      } else {
        transfer = await TransferService.uploadFile(
          file: File(picked.path!),
          fileName: picked.name,
          mimeType: _guessMime(picked.name),
          fileSize: picked.size,
          onProgress: (p) => setState(() => _uploadProgress = p),
        );
      }
      setState(() {
        _transfer = transfer;
        _state = _UploadState.done;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Upload failed: $e';
        _state = _UploadState.error;
      });
    }
  }

  String _guessMime(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    const map = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'pdf': 'application/pdf',
      'apk': 'application/vnd.android.package-archive',
      'mp4': 'video/mp4',
      'zip': 'application/zip',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    };
    return map[ext] ?? 'application/octet-stream';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Send File',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: kIsWeb ? 40 : 24,
              vertical: 24,
            ),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _UploadState.idle:
        return _buildIdle();
      case _UploadState.uploading:
        return _buildUploading();
      case _UploadState.done:
        return _buildDone();
      case _UploadState.error:
        return _buildError();
    }
  }

  Widget _buildIdle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Select a file to share',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your file is encrypted in transit and deleted after 5 minutes.',
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
        ),
        const SizedBox(height: 32),

        // Drop zone
        GestureDetector(
          onTap: _pickAndUpload,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 32),
            decoration: BoxDecoration(
              color: const Color(0xFF12121F),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6C63FF).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.upload_file_rounded,
                    color: Color(0xFF6C63FF),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Click to select file',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Photos, APKs, PDFs, videos — up to 50MB',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn().scale(begin: const Offset(0.97, 0.97)),

        const SizedBox(height: 32),

        // Feature list
        _featureRow(Icons.lock_outline_rounded, 'No account required'),
        const SizedBox(height: 12),
        _featureRow(Icons.timer_outlined, 'Expires in exactly 5 minutes'),
        const SizedBox(height: 12),
        _featureRow(
          Icons.high_quality_outlined,
          'Zero compression — original quality',
        ),
      ],
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6C63FF), size: 16),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildUploading() {
    return SizedBox(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            color: Color(0xFF6C63FF),
            size: 56,
          ),
          const SizedBox(height: 24),
          const Text(
            'Uploading...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_uploadProgress * 100).toInt()}%',
            style: const TextStyle(color: Color(0xFF6B6B8A), fontSize: 14),
          ),
          const SizedBox(height: 28),
          LinearPercentIndicator(
            lineHeight: 6,
            percent: _uploadProgress,
            backgroundColor: const Color(0xFF1E1E30),
            progressColor: const Color(0xFF6C63FF),
            barRadius: const Radius.circular(6),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDone() {
    final t = _transfer!;
    return Column(
      children: [
        const SizedBox(height: 8),

        // File info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF12121F),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E1E30)),
          ),
          child: Row(
            children: [
              Text(t.fileIcon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.fileName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      t.fileSizeFormatted,
                      style: const TextStyle(
                        color: Color(0xFF6B6B8A),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF00C896),
                size: 22,
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.2),

        const SizedBox(height: 24),

        // QR + Code side by side on web
        if (kIsWeb)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: QrDisplay(transfer: t)),
              const SizedBox(width: 16),
              Expanded(child: _codeCard(t)),
            ],
          ).animate().fadeIn(delay: 100.ms)
        else
          Column(
            children: [
              QrDisplay(transfer: t),
              const SizedBox(height: 16),
              _codeCard(t),
            ],
          ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 16),
        CountdownTimer(expiresAt: t.expiresAt).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),

        TextButton.icon(
          onPressed: () => setState(() {
            _state = _UploadState.idle;
            _transfer = null;
          }),
          icon: const Icon(
            Icons.add_circle_outline,
            color: Color(0xFF6C63FF),
            size: 18,
          ),
          label: const Text(
            'Share another file',
            style: TextStyle(color: Color(0xFF6C63FF), fontSize: 14),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _codeCard(TransferModel t) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: t.code));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Code copied!')));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF12121F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Share this code',
              style: TextStyle(color: Color(0xFF6B6B8A), fontSize: 12),
            ),
            const SizedBox(height: 10),
            Text(
              t.code,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.copy_rounded,
                  color: Color(0xFF6C63FF),
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  'Tap to copy',
                  style: TextStyle(
                    color: const Color(0xFF6C63FF).withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return SizedBox(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 56,
          ),
          const SizedBox(height: 20),
          const Text(
            'Upload failed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6B6B8A), fontSize: 13),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => setState(() {
              _state = _UploadState.idle;
              _errorMessage = null;
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

enum _UploadState { idle, uploading, done, error }
