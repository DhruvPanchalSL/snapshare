import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/transfer_model.dart';

class TransferService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static final _supabase = Supabase.instance.client;

  static const _bucket = 'transfers';
  static const _maxFileSize = 50 * 1024 * 1024; // 50MB

  static String _generateCode() {
    const chars = '123456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  static String _storagePath(String uid, String code, String fileName) {
    return '$uid/$code/$fileName';
  }

  // ── Ensure anonymous auth before any operation ────────────────────────────
  static Future<void> _ensureAuth() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  // ── Upload file (mobile) ──────────────────────────────────────────────────
  static Future<TransferModel> uploadFile({
    required File file,
    required String fileName,
    required String mimeType,
    required int fileSize,
    required void Function(double progress) onProgress,
  }) async {
    await _ensureAuth();

    if (fileSize > _maxFileSize) throw Exception('File exceeds 50MB limit');

    final uid = _auth.currentUser!.uid;
    final code = _generateCode();
    final path = _storagePath(uid, code, fileName);

    onProgress(0.1);
    final bytes = await file.readAsBytes();

    await _supabase.storage
        .from(_bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: false),
        );
    onProgress(0.9);

    final fileUrl = _supabase.storage.from(_bucket).getPublicUrl(path);
    onProgress(1.0);

    return await _saveToFirestore(
      code: code,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType,
      uid: uid,
      storagePath: path,
    );
  }

  // ── Upload bytes (web) ────────────────────────────────────────────────────
  static Future<TransferModel> uploadBytes({
    required List<int> bytes,
    required String fileName,
    required String mimeType,
    required void Function(double progress) onProgress,
  }) async {
    await _ensureAuth();

    if (bytes.length > _maxFileSize) throw Exception('File exceeds 50MB limit');

    final uid = _auth.currentUser!.uid;
    final code = _generateCode();
    final path = _storagePath(uid, code, fileName);

    onProgress(0.1);
    await _supabase.storage
        .from(_bucket)
        .uploadBinary(
          path,
          bytes as dynamic,
          fileOptions: FileOptions(contentType: mimeType, upsert: false),
        );
    onProgress(0.9);

    final fileUrl = _supabase.storage.from(_bucket).getPublicUrl(path);
    onProgress(1.0);

    return await _saveToFirestore(
      code: code,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: bytes.length,
      mimeType: mimeType,
      uid: uid,
      storagePath: path,
    );
  }

  // ── Save metadata to Firestore ────────────────────────────────────────────
  static Future<TransferModel> _saveToFirestore({
    required String code,
    required String fileUrl,
    required String fileName,
    required int fileSize,
    required String mimeType,
    required String uid,
    required String storagePath,
  }) async {
    final now = DateTime.now().toUtc(); // ← always UTC to avoid timezone issues
    final expiresAt = now.add(const Duration(minutes: 5));

    final transfer = TransferModel(
      code: code,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType,
      createdAt: now,
      expiresAt: expiresAt,
      uploaderUid: uid,
      storagePath: storagePath,
    );

    await _firestore
        .collection('transfers')
        .doc(code)
        .set(transfer.toFirestore());

    return transfer;
  }

  // ── Fetch transfer by code ────────────────────────────────────────────────
  static Future<TransferModel?> fetchByCode(String code) async {
    await _ensureAuth(); // ← ensure auth before reading Firestore

    try {
      final doc = await _firestore
          .collection('transfers')
          .doc(code.toUpperCase().trim())
          .get();

      if (!doc.exists || doc.data() == null) return null;

      final transfer = TransferModel.fromFirestore(doc.data()!);

      // Client-side expiry check
      if (transfer.isExpired) {
        await deleteTransfer(transfer);
        return null;
      }

      return transfer;
    } catch (e) {
      rethrow; // let the UI handle and show the error
    }
  }

  // ── Delete transfer ───────────────────────────────────────────────────────
  static Future<void> deleteTransfer(TransferModel transfer) async {
    try {
      await _supabase.storage.from(_bucket).remove([transfer.storagePath]);
      await _firestore.collection('transfers').doc(transfer.code).delete();
    } catch (_) {
      // best-effort
    }
  }
}
