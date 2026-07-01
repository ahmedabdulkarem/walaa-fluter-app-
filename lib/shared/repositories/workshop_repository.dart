// lib/shared/repositories/workshop_repository.dart
// WHY: Workshop data access — CRUD, staff, attendees with payment + attendance rules.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/permission_constants.dart';
import '../../core/error/failure.dart';
import '../../core/utils/result.dart';
import '../models/workshop_schema.dart';
import '../models/workshop_staff_schema.dart';
import '../models/workshop_attendee_schema.dart';
import '../models/user_schema.dart';

class WorkshopRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<WorkshopSchema>> streamWorkshops() {
    return _db
        .collection('workshops')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(WorkshopSchema.fromFirestore).toList());
  }

  Future<WorkshopSchema?> getWorkshop(String uid) async {
    final snap =
        await _db.collection('workshops').where('uid', isEqualTo: uid).get();
    if (snap.docs.isEmpty) return null;
    return WorkshopSchema.fromFirestore(snap.docs.first);
  }

  Future<Result<void>> createWorkshop(WorkshopSchema w, UserSchema author) async {
    if (!author.can(PermissionConstants.manageWorkshops)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db.collection('workshops').doc(w.uid).set(w.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> updateWorkshop(WorkshopSchema w, UserSchema author) async {
    if (!author.can(PermissionConstants.manageWorkshops)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      w.updatedAt = DateTime.now();
      await _db.collection('workshops').doc(w.uid).update(w.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> deleteWorkshop(String workshopUid, UserSchema author) async {
    if (!author.can(PermissionConstants.manageWorkshops)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      final staffSnap = await _db
          .collection('workshops')
          .doc(workshopUid)
          .collection('staff')
          .get();
      for (final doc in staffSnap.docs) {
        await doc.reference.delete();
      }
      final attendeeSnap = await _db
          .collection('workshops')
          .doc(workshopUid)
          .collection('attendees')
          .get();
      for (final doc in attendeeSnap.docs) {
        await doc.reference.delete();
      }
      await _db.collection('workshops').doc(workshopUid).delete();
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Stream<List<WorkshopStaffSchema>> streamStaff(String workshopId) {
    return _db
        .collection('workshops')
        .doc(workshopId)
        .collection('staff')
        .snapshots()
        .map((snap) => snap.docs.map(WorkshopStaffSchema.fromFirestore).toList());
  }

  Stream<List<WorkshopAttendeeSchema>> streamAttendees(String workshopId) {
    return _db
        .collection('workshops')
        .doc(workshopId)
        .collection('attendees')
        .snapshots()
        .map((snap) => snap.docs.map(WorkshopAttendeeSchema.fromFirestore).toList());
  }

  Future<Result<void>> addStaff(
    String workshopId,
    WorkshopStaffSchema staff,
    UserSchema author,
  ) async {
    if (!author.can(PermissionConstants.manageWorkshops)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      staff.workshopId = workshopId;
      await _db
          .collection('workshops')
          .doc(workshopId)
          .collection('staff')
          .doc(staff.uid)
          .set(staff.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> updateStaff(
    WorkshopStaffSchema staff,
    UserSchema author,
  ) async {
    if (!author.can(PermissionConstants.manageWorkshops)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db
          .collection('workshops')
          .doc(staff.workshopId)
          .collection('staff')
          .doc(staff.uid)
          .update(staff.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> deleteStaff(String workshopId, String staffUid, UserSchema author) async {
    if (!author.can(PermissionConstants.manageWorkshops)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db
          .collection('workshops')
          .doc(workshopId)
          .collection('staff')
          .doc(staffUid)
          .delete();
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> toggleStaffPayment(
    String workshopId,
    String staffUid,
    bool hasPaid,
    UserSchema author,
  ) async {
    if (!author.can(PermissionConstants.confirmPayment)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db
          .collection('workshops')
          .doc(workshopId)
          .collection('staff')
          .doc(staffUid)
          .update({
        'hasPaidSubscription': hasPaid,
        'paymentConfirmedBy': author.uid,
        'paymentConfirmedAt': Timestamp.fromDate(DateTime.now()),
      });
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> markStaffAttendance(
    String workshopId,
    String staffUid,
    String status,
    UserSchema author,
  ) async {
    if (!author.can(PermissionConstants.recordWorkshopAttendance)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db
          .collection('workshops')
          .doc(workshopId)
          .collection('staff')
          .doc(staffUid)
          .update({
        'attendanceStatus': status,
        'attendanceMarkedBy': author.uid,
        'attendanceMarkedAt': Timestamp.fromDate(DateTime.now()),
      });
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> addAttendee(
    String workshopId,
    WorkshopAttendeeSchema attendee,
    UserSchema author,
  ) async {
    if (!author.can(PermissionConstants.addWorkshopAttendees)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      attendee.workshopId = workshopId;
      await _db
          .collection('workshops')
          .doc(workshopId)
          .collection('attendees')
          .doc(attendee.uid)
          .set(attendee.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> updateAttendee(
    WorkshopAttendeeSchema attendee,
    UserSchema author,
  ) async {
    if (!author.can(PermissionConstants.addWorkshopAttendees)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db
          .collection('workshops')
          .doc(attendee.workshopId)
          .collection('attendees')
          .doc(attendee.uid)
          .update(attendee.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> deleteAttendee(
    String workshopId,
    String attendeeUid,
    UserSchema author,
  ) async {
    if (!author.can(PermissionConstants.addWorkshopAttendees)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db
          .collection('workshops')
          .doc(workshopId)
          .collection('attendees')
          .doc(attendeeUid)
          .delete();
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> toggleAttendeePayment(
    String workshopId,
    String attendeeUid,
    bool hasPaid,
    UserSchema author,
  ) async {
    if (!author.can(PermissionConstants.confirmPayment)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db
          .collection('workshops')
          .doc(workshopId)
          .collection('attendees')
          .doc(attendeeUid)
          .update({
        'hasPaidSubscription': hasPaid,
        'paymentConfirmedBy': author.uid,
        'paymentConfirmedAt': Timestamp.fromDate(DateTime.now()),
      });
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> markAttendance(
    String workshopId,
    String attendeeUid,
    String status,
    UserSchema author,
  ) async {
    if (!author.can(PermissionConstants.recordWorkshopAttendance)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      final attendeeDoc = await _db
          .collection('workshops')
          .doc(workshopId)
          .collection('attendees')
          .doc(attendeeUid)
          .get();
      if (!attendeeDoc.exists) {
        return const FailureResult(NotFoundFailure('Attendee not found'));
      }
      final attendee = WorkshopAttendeeSchema.fromFirestore(attendeeDoc);
      if (!attendee.hasPaidSubscription && status == 'present') {
        return const FailureResult(
          UnpaidAttendeeFailure('Cannot mark attendance for unpaid attendee'),
        );
      }
      await attendeeDoc.reference.update({
        'attendanceStatus': status,
        'attendanceMarkedBy': author.uid,
        'attendanceMarkedAt': Timestamp.fromDate(DateTime.now()),
      });
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
