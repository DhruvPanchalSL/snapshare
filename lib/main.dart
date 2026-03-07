import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'services/expiry_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (Auth + Firestore)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase (Storage only)
  await Supabase.initialize(
    url: 'https://ynlirvfsjkumsgikjcmq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlubGlydmZzamt1bXNnaWtqY21xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI3ODg3NTksImV4cCI6MjA4ODM2NDc1OX0.i73rmoJA-P4nBOIoelTv9V4Xhp1qzolVbYSW4Uf7ow0',
  );

  // Sign in anonymously via Firebase
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }

  // Clean up expired transfers on launch (free-tier strategy)
  await ExpiryService.cleanupExpiredTransfers();

  runApp(const SnapShareApp());
}

class SnapShareApp extends StatelessWidget {
  const SnapShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
