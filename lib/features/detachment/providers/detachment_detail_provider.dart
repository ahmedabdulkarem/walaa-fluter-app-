import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app.dart';
import '../models/detachment_day_model.dart';
import '../models/detachment_member_model.dart';
import '../models/detachment_shift_model.dart';
import '../models/detachment_patient_model.dart';

final detachmentDetailProvider =
    FutureProvider.family<DetachmentDayModel?, String>((ref, dayId) {
  final repo = ref.watch(detachmentNewRepoProvider);
  return repo.watchDay(dayId).first;
});

final detachmentMembersProvider =
    StreamProvider.family<List<DetachmentMemberModel>, String>(
        (ref, detachmentId) {
  return ref
      .watch(detachmentNewRepoProvider)
      .watchMembersForDetachment(detachmentId);
});

final detachmentShiftsProvider =
    StreamProvider.family<List<DetachmentShiftModel>, String>(
        (ref, detachmentId) {
  return ref
      .watch(detachmentNewRepoProvider)
      .watchShiftsForDetachment(detachmentId);
});

final detachmentPatientsProvider =
    StreamProvider.family<List<DetachmentPatientModel>, String>(
        (ref, detachmentId) {
  return ref
      .watch(detachmentNewRepoProvider)
      .watchPatientsForDetachment(detachmentId);
});
