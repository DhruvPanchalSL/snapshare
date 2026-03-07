import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/transfer_model.dart';
import '../services/transfer_service.dart';
import '../widgets/countdown_timer.dart';

class SendScreen extends StatefulWidget {
  final String? droppedFileName;
  final List<int>? droppedBytes;
  const SendScreen({super.key, this.droppedFileName, this.droppedBytes});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  _UploadState _state = _UploadState.idle;
  double _uploadProgress = 0;
  TransferModel? _transfer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.droppedBytes != null && widget.droppedFileName != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _uploadDroppedBytes(widget.droppedFileName!, widget.droppedBytes!);
      });
    }
  }

  Future<void> _uploadDroppedBytes(String name, List<int> bytes) async {
    if (bytes.length > 50 * 1024 * 1024) {
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
      final transfer = await TransferService.uploadBytes(
        bytes: Uint8List.fromList(bytes),
        fileName: name,
        mimeType: _guessMime(name),
        onProgress: (p) => setState(() => _uploadProgress = p),
      );
      setState(() {
        _transfer = transfer;
        _state = _UploadState.done;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _state = _UploadState.error;
      });
    }
  }

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

  bool get _isDesktop =>
      kIsWeb &&
      (WidgetsBinding.instance.window.physicalSize.width /
              WidgetsBinding.instance.window.devicePixelRatio) >
          900;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = kIsWeb && w > 900;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      appBar: isDesktop ? _desktopAppBar(context) : _mobileAppBar(),
      body: (_state == _UploadState.done && isDesktop)
          ? _buildDesktopDone(context)
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 24,
                    vertical: 28,
                  ),
                  child: _buildBody(),
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget _mobileAppBar() => AppBar(
    backgroundColor: const Color(0xFF0A0A12),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    title: const Text(
      'Send File',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),
  );

  PreferredSizeWidget _desktopAppBar(BuildContext context) => AppBar(
    backgroundColor: const Color(0xFF0A0A12),
    elevation: 0,
    automaticallyImplyLeading: false,
    titleSpacing: 0,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Divider(height: 1, color: Colors.white.withOpacity(0.06)),
    ),
    title: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'SnapShare',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Icon(
            Icons.notifications_outlined,
            color: Colors.white.withOpacity(0.4),
            size: 22,
          ),
          const SizedBox(width: 16),
          CircleAvatar(radius: 16, backgroundColor: Colors.amber.shade300),
        ],
      ),
    ),
  );

  Widget _buildBody() {
    switch (_state) {
      case _UploadState.idle:
        return _buildIdle();
      case _UploadState.uploading:
        return _buildUploading();
      case _UploadState.done:
        return _buildMobileDone();
      case _UploadState.error:
        return _buildError();
    }
  }

  Widget _buildIdle() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 8),
      const Text(
        'Select a file to share',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Encrypted in transit · Deleted after 5 minutes',
        style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13),
      ),
      const SizedBox(height: 32),
      GestureDetector(
        onTap: _pickAndUpload,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 52, horizontal: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F1A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF7C3AED).withOpacity(0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  color: Color(0xFF7C3AED),
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Click to select file',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Photos, APKs, PDFs, videos — up to 50MB',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn().scale(begin: const Offset(0.97, 0.97)),
      const SizedBox(height: 28),
      ...[
        (Icons.lock_outline_rounded, 'No account required'),
        (Icons.timer_outlined, 'Expires in exactly 5 minutes'),
        (Icons.high_quality_outlined, 'Zero compression — original quality'),
      ].map(
        (e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(e.$1, color: const Color(0xFF7C3AED), size: 15),
              const SizedBox(width: 10),
              Text(
                e.$2,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildUploading() => SizedBox(
    height: 380,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.cloud_upload_outlined,
          color: Color(0xFF7C3AED),
          size: 52,
        ),
        const SizedBox(height: 22),
        const Text(
          'Uploading...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${(_uploadProgress * 100).toInt()}%',
          style: const TextStyle(color: Color(0xFF6B6B8A), fontSize: 14),
        ),
        const SizedBox(height: 24),
        LinearPercentIndicator(
          lineHeight: 5,
          percent: _uploadProgress,
          backgroundColor: const Color(0xFF1E1E2E),
          progressColor: const Color(0xFF7C3AED),
          barRadius: const Radius.circular(6),
          padding: EdgeInsets.zero,
        ),
      ],
    ),
  );

  Widget _buildMobileDone() {
    final t = _transfer!;
    return Column(
      children: [
        _fileCard(t).animate().fadeIn(),
        const SizedBox(height: 20),
        // QR
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F1A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF7C3AED).withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: QrImageView(
                  data: t.code,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Scan this code to download the file directly\non another device',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 16),
        // Code + copy
        _codeRow(t, context).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 16),
        const Text(
          'EXPIRES IN',
          style: TextStyle(
            color: Color(0xFF7C3AED),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        CountdownTimer(expiresAt: t.expiresAt),
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: () => setState(() {
            _state = _UploadState.idle;
            _transfer = null;
          }),
          icon: const Icon(
            Icons.add_circle_outline_rounded,
            color: Color(0xFF7C3AED),
            size: 18,
          ),
          label: const Text(
            'Share another file',
            style: TextStyle(
              color: Color(0xFF7C3AED),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt_rounded, color: Color(0xFF2A2A4C), size: 13),
            const SizedBox(width: 4),
            Text(
              'SNAPSHARE',
              style: TextStyle(
                color: Colors.white.withOpacity(0.18),
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDesktopDone(BuildContext context) {
    final t = _transfer!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C896).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00C896).withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF00C896),
                        size: 13,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Upload Complete',
                        style: TextStyle(
                          color: Color(0xFF00C896),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 20),
                const Text(
                  'Ready to share!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.5,
                  ),
                ).animate().fadeIn(delay: 50.ms),
                const SizedBox(height: 8),
                Text(
                  'Your file is securely hosted and ready for pick-up.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 15,
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 28),
                _fileCard(t).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 24),
                Text(
                  'SHARE CODE',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _codeRow(t, context).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Color(0xFF7C3AED),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Expires in ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 14,
                      ),
                    ),
                    CountdownTimer(expiresAt: t.expiresAt, compact: true),
                  ],
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _state = _UploadState.idle;
                    _transfer = null;
                  }),
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF7C3AED),
                    size: 16,
                  ),
                  label: const Text(
                    'Share another file →',
                    style: TextStyle(
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),
          const SizedBox(width: 48),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Scan QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Instant mobile download',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: QrImageView(
                      data: t.code,
                      version: QrVersions.auto,
                      size: 240,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _qrBtn(Icons.download_outlined),
                      const SizedBox(width: 12),
                      _qrBtn(Icons.share_outlined),
                      const SizedBox(width: 12),
                      _qrBtn(Icons.print_outlined),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.08),
          ),
        ],
      ),
    );
  }

  Widget _fileCard(TransferModel t) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF0F0F1A),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(t.fileIcon, style: const TextStyle(fontSize: 24)),
          ),
        ),
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
                style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF00C896),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
        ),
      ],
    ),
  );

  Widget _codeRow(TransferModel t, BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    decoration: BoxDecoration(
      color: const Color(0xFF1A0A2E),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '6-DIGIT SHARE CODE',
              style: TextStyle(
                color: Color(0xFF7C3AED),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${t.code.substring(0, 3)} ${t.code.substring(3)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: t.code));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Code copied!'),
                backgroundColor: Color(0xFF7C3AED),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.copy_rounded, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Tap to copy',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _qrBtn(IconData icon) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    ),
    child: Icon(icon, color: Colors.white.withOpacity(0.45), size: 18),
  );

  Widget _buildError() => SizedBox(
    height: 380,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: Colors.redAccent,
          size: 52,
        ),
        const SizedBox(height: 18),
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
            backgroundColor: const Color(0xFF7C3AED),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Try Again', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

enum _UploadState { idle, uploading, done, error }
