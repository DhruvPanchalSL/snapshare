import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/responsive.dart';
import '../widgets/nav_bar.dart';
import 'receive_screen.dart';
import 'send_screen.dart';

class _StepData {
  final IconData icon;
  final String title;
  final String desc;
  const _StepData(this.icon, this.title, this.desc);
}

class _FaqData {
  final String question;
  final String answer;
  const _FaqData(this.question, this.answer);
}

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      appBar: const SnapNavBar(current: 'How it Works'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Hero(),
            _SendSteps(),
            Container(
              margin: R.hPadding(context).copyWith(top: 24, bottom: 24),
              height: 1,
              color: Colors.white.withOpacity(0.06),
            ),
            _ReceiveSteps(),
            _FaqSection(),
            _Cta(),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    return Container(
      width: double.infinity,
      padding: R.padding(context),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF7C3AED).withOpacity(0.3),
              ),
            ),
            child: const Text(
              'SIMPLE BY DESIGN',
              style: TextStyle(
                color: Color(0xFFAB8EF8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 24),
          Text(
            'How SnapShare Works',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: mobile ? 30 : 48,
              fontWeight: FontWeight.bold,
              letterSpacing: mobile ? -1 : -2,
              height: 1.1,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 16),
          Text(
            'Two sides. Sender and receiver. That\'s it.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: mobile ? 14 : 16,
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}

class _SendSteps extends StatelessWidget {
  static final _steps = [
    _StepData(
      Icons.upload_file_rounded,
      'Pick your file',
      'Tap "Send a File" and select any file from your device — photos, documents, videos, APKs up to 50MB.',
    ),
    _StepData(
      Icons.cloud_done_outlined,
      'It uploads instantly',
      'Your file is securely uploaded to our servers and encrypted in transit. Takes just a few seconds.',
    ),
    _StepData(
      Icons.pin_outlined,
      'Get your 6-digit code',
      'A unique 6-digit code and QR code are generated. Share either one with whoever needs the file.',
    ),
    _StepData(
      Icons.timer_outlined,
      'File expires in 5 minutes',
      'Once the timer runs out, the file is permanently deleted from our servers. Zero trace.',
    ),
  ];

  const _SendSteps();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: R.hPadding(context).copyWith(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.upload_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Sending a File',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ).animate().fadeIn(),
          const SizedBox(height: 28),
          ...List.generate(
            _steps.length,
            (i) => _StepRow(
              _steps[i],
              i,
              isLast: i == _steps.length - 1,
              accent: const Color(0xFF7C3AED),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiveSteps extends StatelessWidget {
  static final _steps = [
    _StepData(
      Icons.dialpad_rounded,
      'Get the code',
      'Ask the sender for their 6-digit code, or scan the QR code directly with your camera.',
    ),
    _StepData(
      Icons.search_rounded,
      'Enter it in the app',
      'Open SnapShare, tap "Receive a File", and type the 6 digits. Hit Find File.',
    ),
    _StepData(
      Icons.download_done_rounded,
      'Download instantly',
      'The file downloads immediately to your device in its original quality — no compression, no waiting.',
    ),
  ];

  const _ReceiveSteps();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: R.hPadding(context).copyWith(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C896),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Receiving a File',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ).animate().fadeIn(),
          const SizedBox(height: 28),
          ...List.generate(
            _steps.length,
            (i) => _StepRow(
              _steps[i],
              i,
              isLast: i == _steps.length - 1,
              accent: const Color(0xFF00C896),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final _StepData data;
  final int index;
  final bool isLast;
  final Color accent;
  const _StepRow(
    this.data,
    this.index, {
    required this.isLast,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(data.icon, color: accent, size: 22),
                  ),
                  if (!isLast)
                    Container(
                      width: 1,
                      height: 36,
                      color: accent.withOpacity(0.2),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        data.desc,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 80))
        .slideX(begin: -0.04);
  }
}

class _FaqSection extends StatelessWidget {
  static final _faqs = [
    _FaqData(
      'Is SnapShare free?',
      'Yes, completely free. No hidden fees, no premium tier, no ads.',
    ),
    _FaqData(
      'What happens after 5 minutes?',
      'The file is permanently deleted from our servers. The code stops working and cannot be used again.',
    ),
    _FaqData(
      'Can I extend the expiry time?',
      'Not currently — 5 minutes is fixed by design. It keeps the service simple and your data private.',
    ),
    _FaqData(
      'What file types are supported?',
      'Any file type up to 50MB — images, videos, PDFs, APKs, ZIPs, documents, and more.',
    ),
    _FaqData(
      'Is my file actually deleted?',
      'Yes. Files are deleted from Supabase Storage and the metadata is removed from our database. There\'s no backup.',
    ),
    _FaqData(
      'Do I need an account to receive?',
      'No. Anyone with the 6-digit code can download the file — no login, no app install on web.',
    ),
  ];

  const _FaqSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: R.padding(context).copyWith(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              color: Colors.white,
              fontSize: R.isMobile(context) ? 22 : 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.8,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 28),
          ...List.generate(_faqs.length, (i) => _FaqItem(_faqs[i], i)),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final _FaqData data;
  final int index;
  const _FaqItem(this.data, this.index);
  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _open
              ? const Color(0xFF7C3AED).withOpacity(0.06)
              : const Color(0xFF0F0F1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _open
                ? const Color(0xFF7C3AED).withOpacity(0.3)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.data.question,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  _open ? Icons.remove_rounded : Icons.add_rounded,
                  color: const Color(0xFF7C3AED),
                  size: 20,
                ),
              ],
            ),
            if (_open) ...[
              const SizedBox(height: 10),
              Text(
                widget.data.answer,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: widget.index * 50));
  }
}

class _Cta extends StatelessWidget {
  const _Cta();
  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    return Container(
      margin: R.padding(context).copyWith(top: 16),
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: mobile ? 24 : 56),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'See it in action',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Send your first file in under 30 seconds.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SendScreen()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Send',
                          style: TextStyle(
                            color: Color(0xFF7C3AED),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReceiveScreen(),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Receive',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'See it in action',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Send your first file in under 30 seconds.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SendScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Send a File',
                        style: TextStyle(
                          color: Color(0xFF7C3AED),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReceiveScreen(),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.4)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Receive a File',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
