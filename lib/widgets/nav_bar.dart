import 'package:flutter/material.dart';

import '../screens/features_screen.dart';
import '../screens/home_screen.dart';
import '../screens/how_it_works_screen.dart';
import '../screens/security_screen.dart';
import '../screens/send_screen.dart';

class SnapNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String current;
  const SnapNavBar({super.key, required this.current});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  void _navigate(BuildContext context, String label) {
    if (label == current) return;
    Widget screen;
    switch (label) {
      case 'Home':
        screen = const HomeScreen();
        break;
      case 'Features':
        screen = const FeaturesScreen();
        break;
      case 'How it Works':
        screen = const HowItWorksScreen();
        break;
      case 'Security':
        screen = const SecurityScreen();
        break;
      case 'Send':
        screen = const SendScreen();
        break;
      default:
        return;
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 700;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A12),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48),
      child: Row(
        children: [
          // Logo
          GestureDetector(
            onTap: () => _navigate(context, 'Home'),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 7),
                const Text(
                  'SnapShare',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // On mobile: just show hamburger menu
          if (isMobile)
            _MobileMenu(
              current: current,
              onNavigate: (l) => _navigate(context, l),
            )
          else ...[
            ...['Features', 'How it Works', 'Security'].map((label) {
              final isActive = label == current;
              return Padding(
                padding: const EdgeInsets.only(left: 28),
                child: GestureDetector(
                  onTap: () => _navigate(context, label),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : Colors.white.withOpacity(0.45),
                            fontSize: 13,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 2,
                          width: isActive ? 18 : 0,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(width: 28),
            ElevatedButton(
              onPressed: () => _navigate(context, 'Send'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MobileMenu extends StatelessWidget {
  final String current;
  final void Function(String) onNavigate;
  const _MobileMenu({required this.current, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: const Color(0xFF12121F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      icon: Icon(Icons.menu_rounded, color: Colors.white.withOpacity(0.8)),
      onSelected: onNavigate,
      itemBuilder: (_) => [
        ...['Features', 'How it Works', 'Security'].map(
          (label) => PopupMenuItem(
            value: label,
            child: Text(
              label,
              style: TextStyle(
                color: label == current
                    ? const Color(0xFF7C3AED)
                    : Colors.white,
                fontWeight: label == current
                    ? FontWeight.w600
                    : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'Send',
          child: Row(
            children: [
              Icon(Icons.upload_rounded, color: Color(0xFF7C3AED), size: 16),
              SizedBox(width: 8),
              Text(
                'Get Started',
                style: TextStyle(
                  color: Color(0xFF7C3AED),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
