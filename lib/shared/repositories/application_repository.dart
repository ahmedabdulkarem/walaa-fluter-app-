// lib/shared/repositories/application_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/failure.dart';
import '../../core/utils/result.dart';
import '../models/pending_application_schema.dart';

class ApplicationRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<PendingApplicationSchema>> streamAll() {
    return _db
        .collection('pending_applications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PendingApplicationSchema.fromFirestore).toList());
  }

  Stream<List<PendingApplicationSchema>> streamByStatus(String status) {
    return _db
        .collection('pending_applications')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PendingApplicationSchema.fromFirestore).toList());
  }

  Future<PendingApplicationSchema?> getByUid(String uid) async {
    final snap = await _db
        .collection('pending_applications')
        .where('uid', isEqualTo: uid)
        .get();
    if (snap.docs.isEmpty) return null;
    return PendingApplicationSchema.fromFirestore(snap.docs.first);
  }

  Future<Result<void>> submit(PendingApplicationSchema app) async {
    try {
      await _db.collection('pending_applications').doc(app.uid).set(app.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> review(
    String uid,
    String status,
    String? reviewedBy,
    String? reviewNotes,
  ) async {
    try {
      await _db.collection('pending_applications').doc(uid).update({
        'status': status,
        'reviewedBy': reviewedBy,
        'reviewedAt': Timestamp.fromDate(DateTime.now()),
        'reviewNotes': reviewNotes,
      });
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> deleteApp(String uid) async {
    try {
      await _db.collection('pending_applications').doc(uid).delete();
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
