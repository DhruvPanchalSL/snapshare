// File generated manually — equivalent to FlutterFire CLI output
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Web config ────────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCeQjcWYsySnJ5c4lhqW_JP4K4xJKtpehE',
    authDomain: 'snapshare-7c0d5.firebaseapp.com',
    projectId: 'snapshare-7c0d5',
    storageBucket: 'snapshare-7c0d5.firebasestorage.app',
    messagingSenderId: '405846484028',
    appId: '1:405846484028:web:f31c39208f541920258f39',
  );

  // ── Android config ────────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAf1TzLD6MuCa5gFca1agKHlwrT_Y4mYik',
    appId: '1:405846484028:android:7574aecbc624d982258f39',
    messagingSenderId: '405846484028',
    projectId: 'snapshare-7c0d5',
    storageBucket: 'snapshare-7c0d5.firebasestorage.app',
  );
}
