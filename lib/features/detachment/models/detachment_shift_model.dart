import 'package:cloud_firestore/cloud_firestore.dart';
import 'week_day.dart';

class DetachmentShiftModel {
  final String uid;
  final String detachmentId;
  final WeekDay weekDay;
  final String shiftName;
  final String startTime;
  final String endTime;
  final double durationHours;
  final List<String> memberIds;
  final int memberCount;
  final String leaderId;
  final Map<String, bool> attendance;
  final DateTime createdAt;
  final String createdBy;

  const DetachmentShiftModel({
    required this.uid,
    this.detachmentId = '',
    required this.weekDay,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.memberIds,
    required this.memberCount,
    required this.leaderId,
    this.attendance = const {},
    required this.createdAt,
    required this.createdBy,
  });

  String get durationLabel {
    final h = durationHours;
    if (h == h.truncate()) return '${h.truncate()}h';
    final mins = ((h % 1) * 60).round();
    return '${h.truncate()}h ${mins}m';
  }

  int get presentCount => attendance.values.where((p) => p).length;
  int get absentCount => attendance.values.where((p) => !p).length;
  double get attendanceRate =>
      memberIds.isEmpty ? 0 : presentCount / memberIds.length;

  DetachmentShiftModel copyWith({
    String? shiftName,
    WeekDay? weekDay,
    String? startTime,
    String? endTime,
    double? durationHours,
    List<String>? memberIds,
    int? memberCount,
    String? leaderId,
    String? detachmentId,
    Map<String, bool>? attendance,
  }) {
    return DetachmentShiftModel(
      uid: uid,
      detachmentId: detachmentId ?? this.detachmentId,
      weekDay: weekDay ?? this.weekDay,
      shiftName: shiftName ?? this.shiftName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationHours: durationHours ?? this.durationHours,
      memberIds: memberIds ?? this.memberIds,
      memberCount: memberCount ?? memberIds?.length ?? this.memberCount,
      leaderId: leaderId ?? this.leaderId,
      attendance: attendance ?? this.attendance,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }

  factory DetachmentShiftModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    return DetachmentShiftModel(
      uid: doc.id,
      detachmentId: data['detachmentId'] as String? ?? data['dayId'] as String? ?? '',
      weekDay: WeekDay.fromStorageKey(
          (data['weekDay'] as String?) ?? 'saturday'),
      shiftName: data['shiftName'] as String? ?? data['name'] as String? ?? '',
      startTime: data['startTime'] as String? ?? '',
      endTime: data['endTime'] as String? ?? '',
      durationHours:
          (data['durationHours'] as num?)?.toDouble() ?? 0.0,
      memberIds: List<String>.from(data['memberIds'] as List? ?? []),
      memberCount: data['memberCount'] as int? ?? 0,
      leaderId: data['leaderId'] as String? ?? '',
      attendance: (data['attendance'] as Map?)?.map((k, v) => MapEntry(k as String, v as bool)) ?? {},
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, Object?> toFirestore() {
    final map = <String, Object?>{
      'detachmentId': detachmentId,
      'weekDay': weekDay.storageKey,
      'shiftName': shiftName,
      'startTime': startTime,
      'endTime': endTime,
      'durationHours': durationHours,
      'memberIds': memberIds,
      'memberCount': memberCount,
      'leaderId': leaderId,
      'attendance': attendance,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
    return map;
  }
}
