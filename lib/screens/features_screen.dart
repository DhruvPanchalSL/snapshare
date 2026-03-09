import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/responsive.dart';
import '../widgets/nav_bar.dart';
import 'send_screen.dart';

class _FeatureData {
  final IconData icon;
  final String title;
  final Color color;
  final String desc;
  const _FeatureData(this.icon, this.title, this.color, this.desc);
}

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      appBar: const SnapNavBar(current: 'Features'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Hero(),
            _MainFeaturesGrid(),
            _ComparisonSection(),
            _BottomCta(),
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
              'EVERYTHING YOU NEED',
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
            'Built for speed.\nDesigned for privacy.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: mobile ? 32 : 52,
              fontWeight: FontWeight.bold,
              height: 1.1,
              letterSpacing: mobile ? -1 : -2,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 16),
          Text(
            'Every feature in SnapShare is designed around one goal — sharing files as fast as humanly possible.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: mobile ? 14 : 16,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}

class _MainFeaturesGrid extends StatelessWidget {
  static final _features = [
    _FeatureData(
      Icons.bolt_rounded,
      '6-Digit Codes',
      const Color(0xFF7C3AED),
      'Share a simple 6-digit number instead of long URLs. Anyone can type it in seconds on any device.',
    ),
    _FeatureData(
      Icons.lock_rounded,
      'Encrypted Transit',
      const Color(0xFF3B82F6),
      'All files are encrypted during upload and download. No one can read your files.',
    ),
    _FeatureData(
      Icons.timer_outlined,
      '5-Minute Expiry',
      const Color(0xFF00C896),
      'Files automatically delete after 5 minutes. Nothing lingers. Clean by design.',
    ),
    _FeatureData(
      Icons.devices_rounded,
      'Any Device',
      const Color(0xFFFF6B6B),
      'Works on Android, iOS, web, and desktop. No app install required on the receiving end.',
    ),
    _FeatureData(
      Icons.person_off_outlined,
      'No Account',
      const Color(0xFFFFAA33),
      'Zero sign-up friction. Open the app and share immediately. Anonymous by default.',
    ),
    _FeatureData(
      Icons.compress_rounded,
      'Zero Compression',
      const Color(0xFF8B5CF6),
      'Files are transferred exactly as-is. No quality loss, no re-encoding, no surprises.',
    ),
    _FeatureData(
      Icons.qr_code_rounded,
      'QR Code Share',
      const Color(0xFF06B6D4),
      'Every transfer generates a scannable QR code for instant mobile-to-mobile sharing.',
    ),
    _FeatureData(
      Icons.storage_rounded,
      'Up to 50MB',
      const Color(0xFFEC4899),
      'Transfer files up to 50MB — documents, photos, videos, APKs, archives and more.',
    ),
  ];

  const _MainFeaturesGrid();

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    final tablet = R.isTablet(context);
    final cols = mobile
        ? 1
        : tablet
        ? 2
        : 4;
    return Padding(
      padding: R.hPadding(context).copyWith(top: 8, bottom: 24),
      child: Column(
        children: List.generate((_features.length / cols).ceil(), (row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(cols, (col) {
                final idx = row * cols + col;
                if (idx >= _features.length)
                  return const Expanded(child: SizedBox());
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: col == 0 ? 0 : 16),
                    child: _FeatureCard(
                      _features[idx],
                    ).animate().fadeIn(delay: Duration(milliseconds: idx * 60)),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final _FeatureData data;
  const _FeatureCard(this.data);
  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final c = widget.data.color;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hovered ? c.withOpacity(0.06) : const Color(0xFF0F0F1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? c.withOpacity(0.4)
                : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.data.icon, color: c, size: 22),
            ),
            const SizedBox(height: 16),
            Text(
              widget.data.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.data.desc,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonSection extends StatelessWidget {
  const _ComparisonSection();
  @override
  Widget build(BuildContext context) {
    if (R.isMobile(context)) return const SizedBox.shrink();
    return Container(
      margin: R.hPadding(context).copyWith(top: 16, bottom: 40),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          const Text(
            'SnapShare vs Everything Else',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.8,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 32),
          _row('', 'SnapShare', 'Email', 'WeTransfer', isHeader: true),
          _div(),
          _row('Setup required', '✗ None', '✗ Account', '✗ Account'),
          _div(),
          _row('Transfer speed', '⚡ Instant', '🐢 Slow', '🐢 Slow'),
          _div(),
          _row('File expiry', '✓ 5 min', '✗ Never', '✓ 7 days'),
          _div(),
          _row('Max file size', '50MB', '25MB', '2GB (paid)'),
          _div(),
          _row('QR code share', '✓ Always', '✗ No', '✗ No'),
          _div(),
          _row('Privacy', '✓ Anonymous', '✗ Tracked', '✗ Tracked'),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String snap,
    String email,
    String wet, {
    bool isHeader = false,
  }) {
    final base = TextStyle(
      color: Colors.white.withOpacity(isHeader ? 1 : 0.45),
      fontSize: 13,
      fontWeight: isHeader ? FontWeight.w700 : FontWeight.normal,
    );
    final snapStyle = TextStyle(
      color: isHeader ? const Color(0xFF7C3AED) : Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: base)),
          Expanded(
            flex: 2,
            child: Text(snap, style: snapStyle, textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 2,
            child: Text(email, style: base, textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 2,
            child: Text(wet, style: base, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _div() => Divider(color: Colors.white.withOpacity(0.05), height: 1);
}

class _BottomCta extends StatelessWidget {
  const _BottomCta();
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
                  'Ready to try it?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No sign-up. No credit card. Just share.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SendScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Share a File Now',
                      style: TextStyle(
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
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
                        'Ready to try it?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No sign-up. No credit card. Just share.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SendScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Share a File Now',
                    style: TextStyle(
                      color: Color(0xFF7C3AED),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
