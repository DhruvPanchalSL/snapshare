import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../models/transfer_model.dart';
import '../services/transfer_service.dart';
import '../utils/web_download.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  _ReceiveState _state = _ReceiveState.input;
  final List<TextEditingController> _digitControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _showScanner = false;
  TransferModel? _transfer;
  String? _errorMessage;
  double _downloadProgress = 0;
  String? _savedFilePath;

  @override
  void dispose() {
    for (final c in _digitControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _enteredCode =>
      _digitControllers.map((c) => c.text).join().toUpperCase();

  Future<void> _lookupCode(String code) async {
    final clean = code.trim().toUpperCase();
    if (clean.length != 6) {
      setState(() => _errorMessage = 'Please enter all 6 characters');
      return;
    }

    setState(() {
      _state = _ReceiveState.loading;
      _errorMessage = null;
    });

    try {
      final transfer = await TransferService.fetchByCode(clean);
      if (transfer == null) {
        setState(() {
          _state = _ReceiveState.input;
          _errorMessage = 'Code not found or has expired.';
        });
        return;
      }
      setState(() {
        _transfer = transfer;
        _state = _ReceiveState.preview;
      });
    } catch (e) {
      setState(() {
        _state = _ReceiveState.input;
        _errorMessage = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  Future<void> _downloadFile() async {
    final t = _transfer!;

    if (kIsWeb) {
      // ── Web: trigger real browser download via anchor click ──────────────
      try {
        setState(() {
          _state = _ReceiveState.downloading;
          _downloadProgress = 0;
        });

        // Trigger browser download using conditional dart:html helper
        triggerWebDownload(t.fileUrl, t.fileName);

        setState(() {
          _state = _ReceiveState.done;
          _savedFilePath = null;
        });
      } catch (e) {
        triggerWebDownload(t.fileUrl, t.fileName);
        setState(() {
          _state = _ReceiveState.done;
          _savedFilePath = null;
        });
      }
      return;
    }

    // ── Mobile: download to device storage ──────────────────────────────────
    setState(() {
      _state = _ReceiveState.downloading;
      _downloadProgress = 0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/${t.fileName}';

      await Dio().download(
        t.fileUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );

      setState(() {
        _state = _ReceiveState.done;
        _savedFilePath = savePath;
      });
    } catch (e) {
      setState(() {
        _state = _ReceiveState.preview;
        _errorMessage = 'Download failed: $e';
      });
    }
  }

  void _resetInput() {
    for (final c in _digitControllers) c.clear();
    if (_focusNodes[0].canRequestFocus) _focusNodes[0].requestFocus();
    setState(() {
      _state = _ReceiveState.input;
      _transfer = null;
      _errorMessage = null;
    });
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
          'Receive File',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
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
      case _ReceiveState.input:
        return _buildInput();
      case _ReceiveState.loading:
        return _buildLoading();
      case _ReceiveState.preview:
        return _buildPreview();
      case _ReceiveState.downloading:
        return _buildDownloading();
      case _ReceiveState.done:
        return _buildDone();
    }
  }

  Widget _buildInput() {
    if (_showScanner && !kIsWeb) return _buildQrScanner();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Enter your code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 8),
        Text(
          '6-character code from the sender',
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 40),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _digitBox(i)),
        ).animate().fadeIn(delay: 150.ms),

        if (_errorMessage != null) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _lookupCode(_enteredCode),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C896),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Find File',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ).animate().fadeIn(delay: 200.ms),

        if (!kIsWeb) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showScanner = true),
              icon: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Color(0xFF00C896),
                size: 18,
              ),
              label: const Text(
                'Scan QR instead',
                style: TextStyle(color: Color(0xFF00C896), fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: const Color(0xFF00C896).withOpacity(0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],

        const SizedBox(height: 40),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF12121F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E1E30)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF6B6B8A),
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Codes expire 5 minutes after the file was uploaded.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _digitBox(int index) {
    return SizedBox(
      width: 52,
      height: 60,
      child: TextField(
        controller: _digitControllers[index],
        focusNode: _focusNodes[index],
        maxLength: 1,
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.characters,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFF12121F),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E1E30)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E1E30)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00C896), width: 2),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
          if (val.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (index == 5 && val.isNotEmpty) {
            _lookupCode(_enteredCode);
          }
        },
      ),
    );
  }

  Widget _buildQrScanner() {
    return SizedBox(
      height: 480,
      child: Column(
        children: [
          const Text(
            'Point at the QR code',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: MobileScanner(
                onDetect: (capture) {
                  final barcode = capture.barcodes.firstOrNull;
                  if (barcode?.rawValue != null) {
                    setState(() => _showScanner = false);
                    _lookupCode(barcode!.rawValue!);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _showScanner = false),
            child: const Text(
              'Enter code manually',
              style: TextStyle(color: Color(0xFF00C896)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF00C896), strokeWidth: 2),
            SizedBox(height: 20),
            Text(
              'Looking up code...',
              style: TextStyle(color: Color(0xFF6B6B8A), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final t = _transfer!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'File found!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF12121F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E1E30)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(t.fileIcon, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.fileName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.fileSizeFormatted,
                          style: const TextStyle(
                            color: Color(0xFF6B6B8A),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFAA33).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFFAA33).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Color(0xFFFFAA33),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Expires in ${t.timeRemaining.inMinutes}m ${t.timeRemaining.inSeconds % 60}s',
                      style: const TextStyle(
                        color: Color(0xFFFFAA33),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _downloadFile,
            icon: const Icon(
              Icons.download_rounded,
              color: Colors.white,
              size: 20,
            ),
            label: Text(
              'Download ${t.fileSizeFormatted}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C896),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _resetInput,
            child: Text(
              'Enter a different code',
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloading() {
    return SizedBox(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.downloading_rounded,
            color: Color(0xFF00C896),
            size: 56,
          ),
          const SizedBox(height: 24),
          const Text(
            'Downloading...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_downloadProgress * 100).toInt()}%',
            style: const TextStyle(color: Color(0xFF6B6B8A), fontSize: 14),
          ),
          const SizedBox(height: 28),
          LinearPercentIndicator(
            lineHeight: 6,
            percent: _downloadProgress,
            backgroundColor: const Color(0xFF1E1E30),
            progressColor: const Color(0xFF00C896),
            barRadius: const Radius.circular(6),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDone() {
    return SizedBox(
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFF00C896),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 44,
            ),
          ).animate().scale(begin: const Offset(0, 0)),
          const SizedBox(height: 24),
          const Text(
            'Download started!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            kIsWeb
                ? 'Check your browser downloads folder'
                : _transfer!.fileName,
            style: const TextStyle(color: Color(0xFF6B6B8A), fontSize: 14),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 36),
          if (_savedFilePath != null)
            ElevatedButton.icon(
              onPressed: () => OpenFile.open(_savedFilePath),
              icon: const Icon(
                Icons.open_in_new_rounded,
                color: Colors.white,
                size: 18,
              ),
              label: const Text(
                'Open File',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _resetInput,
            child: const Text(
              'Receive another file',
              style: TextStyle(color: Color(0xFF00C896), fontSize: 14),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

enum _ReceiveState { input, loading, preview, downloading, done }
