import 'package:cloud_firestore/cloud_firestore.dart';
import 'week_day.dart';

class DetachmentShiftModel {
  final String uid;
  final String dayId;
  final WeekDay weekDay;
  final String shiftName;
  final String startTime;
  final String endTime;
  final double durationHours;
  final List<String> memberIds;
  final int memberCount;
  final String leaderId;
  final DateTime createdAt;
  final String createdBy;

  const DetachmentShiftModel({
    required this.uid,
    required this.dayId,
    required this.weekDay,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.memberIds,
    required this.memberCount,
    required this.leaderId,
    required this.createdAt,
    required this.createdBy,
  });

  factory DetachmentShiftModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    return DetachmentShiftModel(
      uid: doc.id,
      dayId: data['dayId'] as String? ?? '',
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
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, Object?> toFirestore() => {
        'dayId': dayId,
        'weekDay': weekDay.storageKey,
        'shiftName': shiftName,
        'startTime': startTime,
        'endTime': endTime,
        'durationHours': durationHours,
        'memberIds': memberIds,
        'memberCount': memberCount,
        'leaderId': leaderId,
        'createdAt': Timestamp.fromDate(createdAt),
        'createdBy': createdBy,
      };
}
