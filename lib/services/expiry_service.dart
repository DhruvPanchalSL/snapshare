import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transfer_model.dart';
import 'transfer_service.dart';

class ExpiryService {
  static final _firestore = FirebaseFirestore.instance;

  /// Called on app launch — finds and deletes all expired transfers
  /// that belong to the current user. Free-tier alternative to Cloud Functions.
  static Future<void> cleanupExpiredTransfers() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await _firestore
          .collection('transfers')
          .where('uploaderUid', isEqualTo: uid)
          .get();

      for (final doc in snapshot.docs) {
        final transfer = TransferModel.fromFirestore(doc.data());
        if (transfer.isExpired) {
          await TransferService.deleteTransfer(transfer);
        }
      }
    } catch (_) {
      // Non-critical — silently ignore cleanup errors
    }
  }
}
