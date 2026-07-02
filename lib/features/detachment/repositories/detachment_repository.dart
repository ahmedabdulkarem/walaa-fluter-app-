import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../models/detachment_member_model.dart';
import '../models/detachment_day_model.dart';
import '../models/detachment_shift_model.dart';
import '../models/week_day.dart';

class DetachmentRepository {
  final _db = FirebaseFirestore.instance;

  static const _colDays = 'detachment_days';
  static const _colMembers = 'detachment_members';
  static const _colShifts = 'detachment_shifts';

  Stream<List<DetachmentMemberModel>> watchMembers() {
    return _db
        .collection(_colMembers)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .withConverter<DetachmentMemberModel>(
          fromFirestore: DetachmentMemberModel.fromFirestore,
          toFirestore: (model, _) => model.toFirestore(),
        )
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Future<Result<String>> addMember(DetachmentMemberModel member) async {
    try {
      final ref = await _db
          .collection(_colMembers)
          .withConverter<DetachmentMemberModel>(
            fromFirestore: DetachmentMemberModel.fromFirestore,
            toFirestore: (m, _) => m.toFirestore(),
          )
          .add(member);
      return Success(ref.id);
    } catch (e) {
      return const FailureResult(ServerFailure('فشل إضافة العضو'));
    }
  }

  Future<Result<void>> deleteMember(String uid) async {
    try {
      await _db.collection(_colMembers).doc(uid).delete();
      return const Success(null);
    } catch (e) {
      return const FailureResult(ServerFailure('فشل حذف العضو'));
    }
  }

  Stream<List<DetachmentDayModel>> watchDays() {
    return _db
        .collection(_colDays)
        .orderBy('dayDate', descending: false)
        .withConverter<DetachmentDayModel>(
          fromFirestore: DetachmentDayModel.fromFirestore,
          toFirestore: (model, _) => model.toFirestore(),
        )
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Future<Result<String>> createDay(DetachmentDayModel day) async {
    try {
      final ref = await _db
          .collection(_colDays)
          .withConverter<DetachmentDayModel>(
            fromFirestore: DetachmentDayModel.fromFirestore,
            toFirestore: (m, _) => m.toFirestore(),
          )
          .add(day);
      return Success(ref.id);
    } catch (e) {
      return const FailureResult(ServerFailure('فشل إنشاء اليوم'));
    }
  }

  Future<Result<void>> deleteDay(String dayId) async {
    try {
      final batch = _db.batch();

      final shifts = await _db
          .collection(_colShifts)
          .where('dayId', isEqualTo: dayId)
          .get();
      for (final doc in shifts.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(_db.collection(_colDays).doc(dayId));
      await batch.commit();
      return const Success(null);
    } catch (e) {
      return const FailureResult(ServerFailure('فشل حذف اليوم'));
    }
  }

  Stream<List<DetachmentShiftModel>> watchAllShifts() {
    return _db
        .collection(_colShifts)
        .orderBy('createdAt', descending: true)
        .withConverter<DetachmentShiftModel>(
          fromFirestore: DetachmentShiftModel.fromFirestore,
          toFirestore: (model, _) => model.toFirestore(),
        )
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Stream<List<DetachmentShiftModel>> watchShiftsForDay(String dayId) {
    return _db
        .collection(_colShifts)
        .where('dayId', isEqualTo: dayId)
        .orderBy('startTime')
        .withConverter<DetachmentShiftModel>(
          fromFirestore: DetachmentShiftModel.fromFirestore,
          toFirestore: (model, _) => model.toFirestore(),
        )
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Stream<List<DetachmentShiftModel>> watchShiftsForWeekDay(WeekDay day) {
    return _db
        .collection(_colShifts)
        .where('weekDay', isEqualTo: day.storageKey)
        .orderBy('startTime')
        .withConverter<DetachmentShiftModel>(
          fromFirestore: DetachmentShiftModel.fromFirestore,
          toFirestore: (model, _) => model.toFirestore(),
        )
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  String? _validateShift({
    required List<String> memberIds,
    required String leaderId,
    required String startTime,
    required String endTime,
  }) {
    if (memberIds.isEmpty) {
      return 'اختر عضوًا واحدًا على الأقل للشفت';
    }
    if (leaderId.isEmpty) {
      return 'حدد مسؤول الشفت';
    }
    if (!memberIds.contains(leaderId)) {
      return 'مسؤول الشفت يجب أن يكون أحد الأعضاء المختارين بالشفت';
    }
    if (startTime == endTime) {
      return 'وقت البداية والنهاية لا يمكن أن يكونا متطابقين';
    }
    return null;
  }

  Future<Result<String>> createShift(DetachmentShiftModel shift) async {
    final validationError = _validateShift(
      memberIds: shift.memberIds,
      leaderId: shift.leaderId,
      startTime: shift.startTime,
      endTime: shift.endTime,
    );
    if (validationError != null) {
      return FailureResult(ValidationFailure(validationError));
    }
    try {
      final ref = await _db
          .collection(_colShifts)
          .withConverter<DetachmentShiftModel>(
            fromFirestore: DetachmentShiftModel.fromFirestore,
            toFirestore: (m, _) => m.toFirestore(),
          )
          .add(shift);
      return Success(ref.id);
    } catch (e) {
      return const FailureResult(ServerFailure('فشل إنشاء الشفت'));
    }
  }

  Future<Result<void>> updateShift(DetachmentShiftModel shift) async {
    final validationError = _validateShift(
      memberIds: shift.memberIds,
      leaderId: shift.leaderId,
      startTime: shift.startTime,
      endTime: shift.endTime,
    );
    if (validationError != null) {
      return FailureResult(ValidationFailure(validationError));
    }
    try {
      await _db.collection(_colShifts).doc(shift.uid).update({
        'shiftName': shift.shiftName,
        'weekDay': shift.weekDay.storageKey,
        'startTime': shift.startTime,
        'endTime': shift.endTime,
        'durationHours': shift.durationHours,
        'memberIds': shift.memberIds,
        'memberCount': shift.memberCount,
        'leaderId': shift.leaderId,
      });
      return const Success(null);
    } catch (e) {
      return const FailureResult(ServerFailure('فشل تحديث الشفت'));
    }
  }

  Future<Result<void>> updateShiftMembers(
    String shiftId,
    List<String> memberIds,
  ) async {
    try {
      await _db.collection(_colShifts).doc(shiftId).update({
        'memberIds': memberIds,
        'memberCount': memberIds.length,
      });
      return const Success(null);
    } catch (e) {
      return const FailureResult(ServerFailure('فشل تحديث أعضاء الشفت'));
    }
  }

  Future<Result<void>> deleteShift(String shiftId) async {
    try {
      await _db.collection(_colShifts).doc(shiftId).delete();
      return const Success(null);
    } catch (e) {
      return const FailureResult(ServerFailure('فشل حذف الشفت'));
    }
  }
}
