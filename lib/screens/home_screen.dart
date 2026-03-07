import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'receive_screen.dart';
import 'send_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080810),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: kIsWeb ? 48 : 24,
                vertical: 56,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF9B5DE5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SnapShare',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Instant file sharing',
                            style: TextStyle(
                              color: Color(0xFF6B6B8A),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 64),

                  // Hero
                  const Text(
                    'Share files\nin seconds.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      height: 1.05,
                      letterSpacing: -2.5,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

                  const SizedBox(height: 18),

                  const Text(
                    'Upload any file up to 50MB. Get a 6-digit code.\nAnyone with the app can download within 5 minutes.',
                    style: TextStyle(
                      color: Color(0xFF6B6B8A),
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 56),

                  // Action cards
                  _ActionCard(
                    icon: Icons.upload_rounded,
                    label: 'Send a File',
                    subtitle: 'Pick any file & get a shareable code',
                    accent: const Color(0xFF6C63FF),
                    onTap: (ctx) => Navigator.push(
                      ctx,
                      MaterialPageRoute(builder: (_) => const SendScreen()),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                  const SizedBox(height: 14),

                  _ActionCard(
                    icon: Icons.download_rounded,
                    label: 'Receive a File',
                    subtitle: 'Enter a 6-digit code to download',
                    accent: const Color(0xFF00C896),
                    onTap: (ctx) => Navigator.push(
                      ctx,
                      MaterialPageRoute(builder: (_) => const ReceiveScreen()),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 56),

                  // Stats row
                  Row(
                    children: [
                      _StatBox(value: '50MB', label: 'Max file size'),
                      const SizedBox(width: 12),
                      _StatBox(value: '5 min', label: 'Link validity'),
                      const SizedBox(width: 12),
                      _StatBox(value: '100%', label: 'Original quality'),
                    ],
                  ).animate().fadeIn(delay: 450.ms),

                  const SizedBox(height: 40),

                  // Pills
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _Pill(
                        icon: Icons.lock_outline_rounded,
                        label: 'No account needed',
                      ),
                      _Pill(icon: Icons.timer_outlined, label: '5 min expiry'),
                      _Pill(
                        icon: Icons.high_quality_outlined,
                        label: 'Zero compression',
                      ),
                      _Pill(icon: Icons.devices_outlined, label: 'Any device'),
                    ],
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 40),

                  Center(
                    child: Text(
                      'Files are permanently deleted after 5 minutes',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.2),
                        fontSize: 12,
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color accent;
  final void Function(BuildContext) onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.accent.withOpacity(0.08)
                : const Color(0xFF0E0E1C),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _hovered
                  ? widget.accent.withOpacity(0.45)
                  : const Color(0xFF1C1C2E),
              width: 1.5,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.accent.withOpacity(0.06),
                      blurRadius: 24,
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: widget.accent.withOpacity(_hovered ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: widget.accent, size: 26),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: widget.accent.withOpacity(_hovered ? 0.9 : 0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E1C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1C1C2E)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF6B6B8A), size: 13),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF6B6B8A), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E1C),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1C1C2E)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF6B6B8A), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
