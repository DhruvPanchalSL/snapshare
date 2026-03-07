import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'receive_screen.dart';
import 'send_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = kIsWeb && w > 900;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      body: isDesktop ? const _DesktopHome() : const _MobileHome(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DESKTOP
// ─────────────────────────────────────────────────────────────────────────────
class _DesktopHome extends StatelessWidget {
  const _DesktopHome();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const _NavBar(),
          const _HeroSection(),
          const _FeaturesSection(),
          const _CtaSection(),
          const _Footer(),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A12),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Row(
        children: [
          _logoWidget(),
          const Spacer(),
          ...[
            ('Features', () {}),
            ('How it Works', () {}),
            ('Security', () {}),
            ('API', () {}),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: 32),
              child: TextButton(
                onPressed: item.$2,
                child: Text(
                  item.$1,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 32),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SendScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 80),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left hero text
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
                    color: const Color(0xFF7C3AED).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF7C3AED).withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xFFAB8EF8),
                        size: 12,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'ENCRYPTED & INSTANT',
                        style: TextStyle(
                          color: Color(0xFFAB8EF8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),

                const SizedBox(height: 28),

                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Share files in\n',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          height: 1.05,
                          letterSpacing: -2.5,
                        ),
                      ),
                      TextSpan(
                        text: 'seconds.',
                        style: TextStyle(
                          color: Color(0xFF7C3AED),
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          height: 1.05,
                          letterSpacing: -2.5,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

                const SizedBox(height: 20),

                Text(
                  'Fast, secure file sharing with a 50MB limit. No registration\nrequired. Use 6-digit codes for instant cross-device access.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 15,
                    height: 1.7,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 36),

                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SendScreen()),
                      ),
                      icon: const Icon(
                        Icons.upload_rounded,
                        color: Colors.white,
                        size: 17,
                      ),
                      label: const Text(
                        'Send a File',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReceiveScreen(),
                        ),
                      ),
                      icon: Icon(
                        Icons.download_rounded,
                        color: Colors.white.withOpacity(0.65),
                        size: 17,
                      ),
                      label: Text(
                        'Receive a File',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 15,
                        ),
                        side: BorderSide(color: Colors.white.withOpacity(0.15)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 28),

                Row(
                  children: [
                    SizedBox(
                      width: 90,
                      height: 28,
                      child: Stack(
                        children: List.generate(
                          4,
                          (i) => Positioned(
                            left: i * 20.0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: [
                                  const Color(0xFF7C3AED),
                                  const Color(0xFF00C896),
                                  const Color(0xFFFF6B6B),
                                  const Color(0xFF3B82F6),
                                ][i],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF0A0A12),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Trusted by over ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                            ),
                          ),
                          const TextSpan(
                            text: '2,000 users',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: ' daily',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),

          const SizedBox(width: 64),

          // Right — drag drop zone
          Expanded(
            flex: 4,
            child: _DropZoneCard()
                .animate()
                .fadeIn(delay: 200.ms)
                .slideX(begin: 0.08),
          ),
        ],
      ),
    );
  }
}

// ── Drag & Drop Card ──────────────────────────────────────────────────────────
class _DropZoneCard extends StatefulWidget {
  @override
  State<_DropZoneCard> createState() => _DropZoneCardState();
}

class _DropZoneCardState extends State<_DropZoneCard> {
  bool _isDragging = false;

  void _navigateToSend(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SendScreen()),
    );
  }

  Future<void> _handleDrop(
    BuildContext context,
    DropDoneDetails details,
  ) async {
    setState(() => _isDragging = false);
    if (details.files.isEmpty) return;

    final xfile = details.files.first;
    final bytes = await xfile.readAsBytes();

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SendScreen(droppedFileName: xfile.name, droppedBytes: bytes),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isDragging
              ? const Color(0xFF7C3AED)
              : Colors.white.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.06),
            blurRadius: 48,
          ),
        ],
      ),
      child: Column(
        children: [
          DropTarget(
            onDragEntered: (_) => setState(() => _isDragging = true),
            onDragExited: (_) => setState(() => _isDragging = false),
            onDragDone: (details) => _handleDrop(context, details),
            child: GestureDetector(
              onTap: () => _navigateToSend(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 52),
                decoration: BoxDecoration(
                  color: _isDragging
                      ? const Color(0xFF7C3AED).withOpacity(0.07)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isDragging
                        ? const Color(0xFF7C3AED).withOpacity(0.5)
                        : Colors.white.withOpacity(0.07),
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF7C3AED,
                        ).withOpacity(_isDragging ? 0.25 : 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isDragging
                            ? Icons.file_download_rounded
                            : Icons.cloud_upload_outlined,
                        color: const Color(0xFF7C3AED),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _isDragging ? 'Release to upload' : 'Drop it here',
                      style: TextStyle(
                        color: _isDragging
                            ? const Color(0xFF7C3AED)
                            : Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Drag and drop your file or browse your device.\nMaximum file size: 50MB',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToSend(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Select File',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Features ──────────────────────────────────────────────────────────────────
class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 80),
      child: Column(
        children: [
          const Text(
            'Simple. Fast. Secure.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Move files between your devices or share them with friends\nwithout the complexity of traditional cloud storage.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 56),
          Row(
            children: [
              _FeatureCard(
                icon: Icons.person_off_outlined,
                title: 'No account needed',
                desc:
                    "Skip the sign-up form. Start sharing immediately. We don't store your personal data.",
              ),
              const SizedBox(width: 16),
              _FeatureCard(
                icon: Icons.devices_rounded,
                title: 'Any device',
                desc:
                    'Works seamlessly on mobile, tablet, and desktop. No apps or plugins required.',
              ),
              const SizedBox(width: 16),
              _FeatureCard(
                icon: Icons.lock_rounded,
                title: 'End-to-end encryption',
                desc:
                    'Files are encrypted during transit and automatically deleted after 5 minutes.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF7C3AED), size: 22),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              desc,
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

// ── CTA ───────────────────────────────────────────────────────────────────────
class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 56),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ready to share your\nfirst file?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Join thousands of users who prefer speed and\nsimplicity over cluttered cloud services.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SendScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Start Sending',
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 15,
                        ),
                        side: BorderSide(color: Colors.white.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'View Demo',
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
          ),
          const SizedBox(width: 48),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.grid_view_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Enter 6-Digit Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['4', '9', '1', '—', '—', '—'].map((d) {
                      final filled = d != '—';
                      return Container(
                        width: 40,
                        height: 48,
                        decoration: BoxDecoration(
                          color: filled
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              color: filled
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 56),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _logoWidget(),
                    const SizedBox(height: 14),
                    Text(
                      'The fastest way to move data between\nyour devices without any middleman.\nSimple, private, and secure.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Icon(
                          Icons.share_outlined,
                          color: Colors.white.withOpacity(0.35),
                          size: 18,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.language_outlined,
                          color: Colors.white.withOpacity(0.35),
                          size: 18,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.email_outlined,
                          color: Colors.white.withOpacity(0.35),
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ...[
                (
                  'Product',
                  ['Features', 'Encryption', 'File Limits', 'Browser Support'],
                ),
                (
                  'Company',
                  ['About Us', 'Blog', 'Privacy Policy', 'Terms of Service'],
                ),
                (
                  'Support',
                  ['Help Center', 'Contact Support', 'Status Page', 'Feedback'],
                ),
              ].map(
                (col) => Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        col.$1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...col.$2.map(
                        (link) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            link,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Divider(color: Colors.white.withOpacity(0.06)),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                '© 2024 SnapShare Inc. All rights reserved.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                'Designed for Speed',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 24),
              Text(
                'Privacy First',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE
// ─────────────────────────────────────────────────────────────────────────────
class _MobileHome extends StatelessWidget {
  const _MobileHome();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _logoWidget(),
              const Spacer(),
              Icon(
                Icons.settings_outlined,
                color: Colors.white.withOpacity(0.35),
                size: 22,
              ),
            ],
          ).animate().fadeIn(),

          const SizedBox(height: 36),

          const Text(
            'Instant file sharing',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.8,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 6),
          Text(
            'No account needed. Just snap and share.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 32),

          _MobileCard(
            topIcon: Icons.play_arrow_rounded,
            cornerIcon: Icons.upload_file_outlined,
            title: 'Send a File',
            desc: 'Share your files instantly with anyone via a secure link.',
            buttonLabel: 'Send Now →',
            accent: const Color(0xFF7C3AED),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SendScreen()),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15),

          const SizedBox(height: 14),

          _MobileCard(
            topIcon: Icons.hub_outlined,
            cornerIcon: Icons.download_outlined,
            title: 'Receive a File',
            desc: 'Enter a 6-digit code or scan a QR code to download files.',
            buttonLabel: 'Receive Now ↓',
            accent: const Color(0xFF00C896),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReceiveScreen()),
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15),

          const SizedBox(height: 24),

          Row(
            children: [
              _MobileStat(value: '50MB', label: 'MAX SIZE'),
              Container(
                width: 1,
                height: 28,
                color: Colors.white.withOpacity(0.08),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              _MobileStat(value: '5 MIN', label: 'VALIDITY'),
              Container(
                width: 1,
                height: 28,
                color: Colors.white.withOpacity(0.08),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              _MobileStat(value: '100%', label: 'ORIGINAL'),
            ],
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

class _MobileCard extends StatelessWidget {
  final IconData topIcon, cornerIcon;
  final String title, desc, buttonLabel;
  final Color accent;
  final VoidCallback onTap;

  const _MobileCard({
    required this.topIcon,
    required this.cornerIcon,
    required this.title,
    required this.desc,
    required this.buttonLabel,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(topIcon, color: accent, size: 20),
              ),
              const Spacer(),
              Icon(cornerIcon, color: Colors.white.withOpacity(0.12), size: 22),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileStat extends StatelessWidget {
  final String value, label;
  const _MobileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────
Widget _logoWidget() => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
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
);
