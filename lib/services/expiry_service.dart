import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transfer_model.dart';
import 'transfer_service.dart';

class ExpiryService {
  static final _firestore = FirebaseFirestore.instance;

  /// Called on app launch — deletes ALL expired transfers from ALL users.
  /// This means even if user A never reopens the app, user B's launch
  /// will clean up user A's expired files from Supabase + Firestore.
  static Future<void> cleanupExpiredTransfers() async {
    try {
      // Query all transfers — no uid filter, clean up everyone's expired files
      final snapshot = await _firestore.collection('transfers').get();

      final now = DateTime.now().toUtc();
      final expired = snapshot.docs.where((doc) {
        try {
          final transfer = TransferModel.fromFirestore(doc.data());
          return transfer.expiresAt.isBefore(now);
        } catch (_) {
          return false;
        }
      }).toList();

      if (expired.isEmpty) return;

      // Delete in parallel for speed
      await Future.wait(
        expired.map((doc) async {
          try {
            final transfer = TransferModel.fromFirestore(doc.data());
            await TransferService.deleteTransfer(transfer);
          } catch (_) {
            // Best-effort — skip if individual delete fails
          }
        }),
      );
    } catch (_) {
      // Non-critical — silently ignore
    }
  }
}
