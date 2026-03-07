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
  final List<TextEditingController> _controllers = List.generate(
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
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _enteredCode =>
      _controllers.map((c) => c.text).join().toUpperCase();

  Future<void> _lookupCode(String code) async {
    final clean = code.trim().toUpperCase();
    if (clean.length != 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits');
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
          _errorMessage = 'Code not found or expired.';
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
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _downloadFile() async {
    final t = _transfer!;
    if (kIsWeb) {
      setState(() {
        _state = _ReceiveState.downloading;
        _downloadProgress = 0;
      });
      await Future.delayed(const Duration(milliseconds: 300));
      triggerWebDownload(t.fileUrl, t.fileName);
      setState(() {
        _state = _ReceiveState.done;
      });
      return;
    }
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
        onReceiveProgress: (r, total) {
          if (total > 0) setState(() => _downloadProgress = r / total);
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

  void _reset() {
    for (final c in _controllers) c.clear();
    if (_focusNodes[0].canRequestFocus) _focusNodes[0].requestFocus();
    setState(() {
      _state = _ReceiveState.input;
      _transfer = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = kIsWeb && w > 900;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      appBar: isDesktop ? _desktopAppBar(context) : _mobileAppBar(),
      body: isDesktop ? _buildDesktopBody() : _buildMobileBody(),
      bottomNavigationBar: isDesktop ? _desktopFooter() : null,
    );
  }

  PreferredSizeWidget _mobileAppBar() => AppBar(
    backgroundColor: const Color(0xFF0A0A12),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    ),
    title: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.share_rounded, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        const Text(
          'SnapShare',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
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
          const SizedBox(width: 32),
          _navItem('Send', false, context),
          const SizedBox(width: 24),
          _navItem('Receive', true, context),
          const SizedBox(width: 24),
          _navItem('History', false, context),
          const Spacer(),
          Icon(
            Icons.settings_outlined,
            color: Colors.white.withOpacity(0.4),
            size: 20,
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.person_outline_rounded,
            color: Colors.white.withOpacity(0.4),
            size: 20,
          ),
          const SizedBox(width: 16),
          CircleAvatar(radius: 16, backgroundColor: Colors.grey.shade600),
        ],
      ),
    ),
  );

  Widget _navItem(String label, bool active, BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        label,
        style: TextStyle(
          color: active
              ? const Color(0xFF7C3AED)
              : Colors.white.withOpacity(0.5),
          fontSize: 14,
          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      if (active) ...[
        const SizedBox(height: 2),
        Container(
          width: 16,
          height: 2,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    ],
  );

  Widget _desktopFooter() => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 32),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
    ),
    child: Row(
      children: [
        Text(
          '© 2024 SNAPSHARE SECURE TRANSFER',
          style: TextStyle(
            color: Colors.white.withOpacity(0.2),
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        ...[('PRIVACY', () {}), ('TERMS', () {}), ('HELP', () {})].map(
          (e) => Padding(
            padding: const EdgeInsets.only(left: 24),
            child: GestureDetector(
              onTap: e.$2,
              child: Text(
                e.$1,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // ── Mobile body ─────────────────────────────────────────────────────────────
  Widget _buildMobileBody() {
    if (_showScanner && !kIsWeb) return _buildQrScanner();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: _buildStateWidget(isMobile: true),
    );
  }

  // ── Desktop body ────────────────────────────────────────────────────────────
  Widget _buildDesktopBody() => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: _buildStateWidget(isMobile: false),
      ),
    ),
  );

  Widget _buildStateWidget({required bool isMobile}) {
    switch (_state) {
      case _ReceiveState.input:
        return _buildInput(isMobile: isMobile);
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

  // ── INPUT ───────────────────────────────────────────────────────────────────
  Widget _buildInput({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile) ...[
          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.download_rounded,
                color: Color(0xFF7C3AED),
                size: 26,
              ),
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Enter your code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.8,
              ),
            ),
          ).animate().fadeIn(delay: 50.ms),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Enter the 6-digit code shared with you to securely download the file.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ).animate().fadeIn(delay: 100.ms),
        ] else ...[
          const Text(
            'Receive File',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.8,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 6),
          const Text(
            'Enter your code',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(delay: 50.ms),
          const SizedBox(height: 4),
          Text(
            '6-character code from the sender',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ).animate().fadeIn(delay: 80.ms),
        ],

        const SizedBox(height: 36),

        // 6 digit boxes
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

        const SizedBox(height: 24),

        // Find File button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _lookupCode(_enteredCode),
            icon: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 20,
            ),
            label: const Text(
              'Find File',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ).animate().fadeIn(delay: 200.ms),

        if (!kIsWeb) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showScanner = true),
              icon: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Color(0xFF7C3AED),
                size: 18,
              ),
              label: const Text(
                'Scan QR instead',
                style: TextStyle(color: Color(0xFF7C3AED), fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: const Color(0xFF7C3AED).withOpacity(0.4),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 250.ms),
        ],

        const SizedBox(height: 28),

        // Info card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF7C3AED),
                  size: 15,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Codes expire ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                      const TextSpan(
                        text: '5 minutes',
                        style: TextStyle(
                          color: Color(0xFF7C3AED),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: ' after the file was uploaded for your security.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _digitBox(int i) => SizedBox(
    width: 52,
    height: 58,
    child: TextField(
      controller: _controllers[i],
      focusNode: _focusNodes[i],
      maxLength: 1,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: const Color(0xFF0F0F1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E1E30)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
        hintText: '•',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.2),
          fontSize: 20,
        ),
      ),
      onChanged: (val) {
        if (val.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
        if (val.isEmpty && i > 0) _focusNodes[i - 1].requestFocus();
        if (i == 5 && val.isNotEmpty) _lookupCode(_enteredCode);
      },
    ),
  );

  Widget _buildQrScanner() => Scaffold(
    backgroundColor: const Color(0xFF0A0A12),
    body: Column(
      children: [
        const SafeArea(child: SizedBox(height: 16)),
        const Text(
          'Point at QR code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
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
            style: TextStyle(color: Color(0xFF7C3AED)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    ),
  );

  Widget _buildLoading() => const SizedBox(
    height: 400,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF7C3AED), strokeWidth: 2),
          SizedBox(height: 20),
          Text(
            'Looking up code...',
            style: TextStyle(color: Color(0xFF6B6B8A), fontSize: 14),
          ),
        ],
      ),
    ),
  );

  Widget _buildPreview() {
    final t = _transfer!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'File found!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
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
              const SizedBox(height: 14),
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
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.15),

        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
          ),
        ],

        const SizedBox(height: 20),
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
              backgroundColor: const Color(0xFF7C3AED),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _reset,
            child: Text(
              'Enter a different code',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloading() => SizedBox(
    height: 400,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.downloading_rounded,
          color: Color(0xFF7C3AED),
          size: 52,
        ),
        const SizedBox(height: 22),
        const Text(
          'Downloading...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${(_downloadProgress * 100).toInt()}%',
          style: const TextStyle(color: Color(0xFF6B6B8A), fontSize: 14),
        ),
        const SizedBox(height: 24),
        LinearPercentIndicator(
          lineHeight: 5,
          percent: _downloadProgress,
          backgroundColor: const Color(0xFF1E1E2E),
          progressColor: const Color(0xFF7C3AED),
          barRadius: const Radius.circular(6),
          padding: EdgeInsets.zero,
        ),
      ],
    ),
  );

  Widget _buildDone() => SizedBox(
    height: 480,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Color(0xFF00C896),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
        ).animate().scale(begin: const Offset(0, 0)),
        const SizedBox(height: 22),
        const Text(
          'Download started!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Text(
          kIsWeb
              ? 'Check your browser downloads folder'
              : (_transfer?.fileName ?? ''),
          style: const TextStyle(color: Color(0xFF6B6B8A), fontSize: 14),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 32),
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
              backgroundColor: const Color(0xFF7C3AED),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _reset,
          child: const Text(
            'Receive another file',
            style: TextStyle(color: Color(0xFF7C3AED), fontSize: 14),
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    ),
  );
}

enum _ReceiveState { input, loading, preview, downloading, done }
