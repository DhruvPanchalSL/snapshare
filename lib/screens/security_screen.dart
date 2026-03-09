import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/responsive.dart';
import '../widgets/nav_bar.dart';

class _PData {
  final IconData icon;
  final String title;
  final Color color;
  final String desc;
  const _PData(this.icon, this.title, this.color, this.desc);
}

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      appBar: const SnapNavBar(current: 'Security'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Hero(),
            _PrinciplesSection(),
            _TechSection(),
            _WhatWeDoNotSection(),
            _BottomNote(),
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
              color: const Color(0xFF00C896).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00C896).withOpacity(0.3),
              ),
            ),
            child: const Text(
              'PRIVACY FIRST',
              style: TextStyle(
                color: Color(0xFF00C896),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 24),
          Text(
            'Security &\nPrivacy Policy',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: mobile ? 32 : 50,
              fontWeight: FontWeight.bold,
              letterSpacing: mobile ? -1 : -2,
              height: 1.1,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 16),
          Text(
            'We built SnapShare on a simple belief:\nyour files are yours, not ours.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: mobile ? 14 : 16,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 36),
          // Stats — wrap on mobile
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatPill(Icons.timer_outlined, '5 min', 'max file lifetime'),
              _StatPill(Icons.person_off_outlined, '0', 'accounts stored'),
              _StatPill(
                Icons.visibility_off_outlined,
                '0',
                'files we can read',
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _StatPill(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF00C896), size: 16),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrinciplesSection extends StatelessWidget {
  static final _items = [
    _PData(
      Icons.lock_rounded,
      'Encrypted in Transit',
      const Color(0xFF3B82F6),
      'All files are transferred over HTTPS/TLS. Your file is encrypted between your device and our servers.',
    ),
    _PData(
      Icons.timer_outlined,
      'Automatic Deletion',
      const Color(0xFF00C896),
      'Files are hard-deleted from storage exactly 5 minutes after upload. No archive, no backup, no recovery.',
    ),
    _PData(
      Icons.person_off_outlined,
      'No Identity Required',
      const Color(0xFF7C3AED),
      'We use anonymous Firebase Auth — a random ID with no email, name, or phone number attached.',
    ),
    _PData(
      Icons.code_off_rounded,
      'No Tracking',
      const Color(0xFFFF6B6B),
      'No analytics, cookies, or tracking technology. We cannot tell who uploaded what, or who downloaded what.',
    ),
    _PData(
      Icons.storage_rounded,
      'Minimal Data Storage',
      const Color(0xFFFFAA33),
      'We only store what\'s needed to make the transfer work: the file, a 6-digit code, and a timestamp.',
    ),
    _PData(
      Icons.public_off_rounded,
      'Codes Are Not Guessable',
      const Color(0xFF8B5CF6),
      'Codes are 6 random digits from 1,000,000 possibilities. With 5-minute expiry, brute-forcing is impractical.',
    ),
  ];

  const _PrinciplesSection();

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    final cols = mobile ? 1 : 2;
    return Padding(
      padding: R.hPadding(context).copyWith(top: 8, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Security Principles',
            style: TextStyle(
              color: Colors.white,
              fontSize: mobile ? 22 : 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.8,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 24),
          for (int i = 0; i < _items.length; i += cols)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _PrincipleCard(
                      _items[i],
                    ).animate().fadeIn(delay: Duration(milliseconds: i * 60)),
                  ),
                  if (!mobile && i + 1 < _items.length) ...[
                    const SizedBox(width: 14),
                    Expanded(
                      child: _PrincipleCard(_items[i + 1]).animate().fadeIn(
                        delay: Duration(milliseconds: (i + 1) * 60),
                      ),
                    ),
                  ] else if (!mobile)
                    const Expanded(child: SizedBox()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PrincipleCard extends StatelessWidget {
  final _PData data;
  const _PrincipleCard(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            data.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
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
    );
  }
}

class _TechSection extends StatelessWidget {
  const _TechSection();

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    return Container(
      margin: R.hPadding(context).copyWith(top: 8, bottom: 32),
      padding: EdgeInsets.all(mobile ? 20 : 36),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Technical Stack',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 6),
          Text(
            'What powers SnapShare under the hood',
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 13,
            ),
          ).animate().fadeIn(delay: 50.ms),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _TechChip(
                'Firebase Auth',
                'Anonymous sessions',
                Icons.fingerprint_rounded,
                const Color(0xFFFFAA33),
              ),
              _TechChip(
                'Cloud Firestore',
                'Transfer metadata',
                Icons.storage_rounded,
                const Color(0xFF3B82F6),
              ),
              _TechChip(
                'Supabase Storage',
                'File storage',
                Icons.folder_rounded,
                const Color(0xFF00C896),
              ),
              _TechChip(
                'HTTPS / TLS',
                'All transfers',
                Icons.https_rounded,
                const Color(0xFF7C3AED),
              ),
              _TechChip(
                'Flutter',
                'Cross-platform',
                Icons.flutter_dash_rounded,
                const Color(0xFF06B6D4),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.06)),
          const SizedBox(height: 20),
          if (mobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _techDetail(
                  'File Storage',
                  'Files stored at uid/code/filename in Supabase. Only accessible via the public URL revealed after entering the correct code.',
                ),
                const SizedBox(height: 16),
                _techDetail(
                  'Code Generation',
                  'Codes use dart:math Random.secure() — cryptographically secure. 6 digits = 1,000,000 possibilities.',
                ),
                const SizedBox(height: 16),
                _techDetail(
                  'Cleanup Strategy',
                  'Deleted client-side on expiry access. Global cleanup runs on every app launch — even for inactive users\' files.',
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _techDetail(
                    'File Storage',
                    'Files stored at uid/code/filename in Supabase. Only accessible via the public URL revealed after entering the correct code.',
                  ),
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: _techDetail(
                    'Code Generation',
                    'Codes use dart:math Random.secure() — cryptographically secure. 6 digits = 1,000,000 possibilities.',
                  ),
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: _techDetail(
                    'Cleanup Strategy',
                    'Deleted client-side on expiry access. Global cleanup on every app launch covers inactive users\' files too.',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _techDetail(String title, String body) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        body,
        style: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 12,
          height: 1.6,
        ),
      ),
    ],
  );
}

class _TechChip extends StatelessWidget {
  final String label, sub;
  final IconData icon;
  final Color color;
  const _TechChip(this.label, this.sub, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WhatWeDoNotSection extends StatelessWidget {
  static const _items = [
    'Store your name, email, or phone number',
    'Read or scan the contents of your files',
    'Sell your data to third parties',
    'Use cookies or tracking pixels',
    'Keep any file after the 5-minute timer',
    'Log IP addresses or device fingerprints',
  ];

  const _WhatWeDoNotSection();

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    return Padding(
      padding: R.hPadding(context).copyWith(top: 8, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What We Will Never Do',
            style: TextStyle(
              color: Colors.white,
              fontSize: mobile ? 22 : 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.8,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 6),
          Text(
            'Our commitment to you — in plain language.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 13,
            ),
          ).animate().fadeIn(delay: 50.ms),
          const SizedBox(height: 24),
          ..._items.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.redAccent,
                      size: 13,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.value,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: Duration(milliseconds: e.key * 50)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNote extends StatelessWidget {
  const _BottomNote();

  @override
  Widget build(BuildContext context) {
    final mobile = R.isMobile(context);
    return Container(
      margin: R.padding(context).copyWith(top: 8),
      padding: EdgeInsets.all(mobile ? 20 : 30),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF00C896).withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF00C896).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF00C896),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Our Promise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'SnapShare was built because we were tired of file sharing services that require accounts, '
                  'compress your photos, store your files forever, and sell your data. '
                  'We built the service we wanted to use ourselves.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
