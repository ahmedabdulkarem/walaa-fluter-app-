// lib/shared/repositories/detachment_repository.dart
// WHY: Detachment data access — days, shifts, stats, crew from Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/permission_constants.dart';
import '../../core/error/failure.dart';
import '../../core/utils/result.dart';
import '../models/detachment_day_schema.dart';
import '../models/detachment_shift_schema.dart';
import '../models/detachment_stats_schema.dart';
import '../models/detachment_crew_schema.dart';
import '../models/user_schema.dart';

class DetachmentRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<DetachmentDaySchema>> streamDays() {
    return _db
        .collection('detachment_days')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(DetachmentDaySchema.fromFirestore).toList());
  }

  Stream<List<DetachmentShiftSchema>> streamShifts(String dayId) {
    return _db
        .collection('detachment_days')
        .doc(dayId)
        .collection('shifts')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(DetachmentShiftSchema.fromFirestore).toList());
  }

  Stream<List<DetachmentStatsSchema>> streamStats(String dayId) {
    return _db
        .collection('detachment_days')
        .doc(dayId)
        .collection('stats')
        .snapshots()
        .map((snap) => snap.docs.map(DetachmentStatsSchema.fromFirestore).toList());
  }

  Stream<List<DetachmentCrewSchema>> streamCrew(String dayId) {
    return _db
        .collection('detachment_days')
        .doc(dayId)
        .collection('crew')
        .snapshots()
        .map((snap) => snap.docs.map(DetachmentCrewSchema.fromFirestore).toList());
  }

  Future<Result<void>> createDay(DetachmentDaySchema day, UserSchema author) async {
    if (!author.can(PermissionConstants.manageDetachment)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db.collection('detachment_days').doc(day.uid).set(day.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> updateDay(DetachmentDaySchema day, UserSchema author) async {
    if (!author.can(PermissionConstants.manageDetachment)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db.collection('detachment_days').doc(day.uid).update(day.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> deleteDay(String dayId, UserSchema author) async {
    if (!author.can(PermissionConstants.manageDetachment)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      final shiftsSnap = await _db
          .collection('detachment_days')
          .doc(dayId)
          .collection('shifts')
          .get();
      for (final doc in shiftsSnap.docs) {
        await doc.reference.delete();
      }
      final statsSnap = await _db
          .collection('detachment_days')
          .doc(dayId)
          .collection('stats')
          .get();
      for (final doc in statsSnap.docs) {
        await doc.reference.delete();
      }
      final crewSnap = await _db
          .collection('detachment_days')
          .doc(dayId)
          .collection('crew')
          .get();
      for (final doc in crewSnap.docs) {
        await doc.reference.delete();
      }
      await _db.collection('detachment_days').doc(dayId).delete();
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> addShift(
    String dayId,
    DetachmentShiftSchema shift,
    UserSchema author,
  ) async {
    if (!author.can(PermissionConstants.manageDetachment)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db
          .collection('detachment_days')
          .doc(dayId)
          .collection('shifts')
          .doc(shift.uid)
          .set(shift.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> updateShift(DetachmentShiftSchema shift, UserSchema author) async {
    if (!author.can(PermissionConstants.manageDetachment)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db
          .collection('detachment_days')
          .doc(shift.dayId)
          .collection('shifts')
          .doc(shift.uid)
          .update(shift.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> deleteShift(String dayId, String shiftUid, UserSchema author) async {
    if (!author.can(PermissionConstants.manageDetachment)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db
          .collection('detachment_days')
          .doc(dayId)
          .collection('shifts')
          .doc(shiftUid)
          .delete();
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> checkInShift(
    String dayId,
    String shiftUid,
    String uid,
    String name,
    UserSchema author,
  ) async {
    if (!author.can(PermissionConstants.recordDetachmentShifts)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      final shiftRef = _db
          .collection('detachment_days')
          .doc(dayId)
          .collection('shifts')
          .doc(shiftUid);
      final shiftDoc = await shiftRef.get();
      if (!shiftDoc.exists) {
        return const FailureResult(NotFoundFailure('Shift not found'));
      }

      final shift = DetachmentShiftSchema.fromFirestore(shiftDoc);
      if (shift.checkedInUids.contains(uid)) {
        return const FailureResult(ValidationFailure('Already checked in'));
      }

      final entry = CheckInEntry(uid: uid, name: name, checkedInAt: DateTime.now());
      shift.checkedInUids.add(uid);
      shift.checkIns.add(entry);
      await shiftRef.update(shift.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> upsertStats(
    String dayId,
    DetachmentStatsSchema stats,
    UserSchema author,
  ) async {
    if (!author.can(PermissionConstants.addPatientStats)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      stats.dayId = dayId;
      await _db
          .collection('detachment_days')
          .doc(dayId)
          .collection('stats')
          .doc(stats.uid)
          .set(stats.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> addCrew(DetachmentCrewSchema crew, UserSchema author) async {
    if (!author.can(PermissionConstants.manageDetachment)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db
          .collection('detachment_days')
          .doc(crew.dayId)
          .collection('crew')
          .doc(crew.uid)
          .set(crew.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> updateCrew(DetachmentCrewSchema crew, UserSchema author) async {
    if (!author.can(PermissionConstants.manageDetachment)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db
          .collection('detachment_days')
          .doc(crew.dayId)
          .collection('crew')
          .doc(crew.uid)
          .update(crew.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> deleteCrew(String dayId, String uid, UserSchema author) async {
    if (!author.can(PermissionConstants.manageDetachment)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db
          .collection('detachment_days')
          .doc(dayId)
          .collection('crew')
          .doc(uid)
          .delete();
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
