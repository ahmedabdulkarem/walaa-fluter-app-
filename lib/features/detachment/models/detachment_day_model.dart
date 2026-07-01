import 'package:cloud_firestore/cloud_firestore.dart';

class DetachmentDayModel {
  final String uid;
  final String dayName;
  final DateTime dayDate;
  final int weekDay;
  final bool isActive;
  final DateTime createdAt;
  final String createdBy;

  const DetachmentDayModel({
    required this.uid,
    required this.dayName,
    required this.dayDate,
    required this.weekDay,
    required this.isActive,
    required this.createdAt,
    required this.createdBy,
  });

  factory DetachmentDayModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    return DetachmentDayModel(
      uid: doc.id,
      dayName: data['dayName'] as String? ?? '',
      dayDate: (data['dayDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weekDay: data['weekDay'] as int? ?? 1,
      isActive: data['isActive'] as bool? ?? true,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, Object?> toFirestore() => {
        'dayName': dayName,
        'dayDate': Timestamp.fromDate(dayDate),
        'weekDay': weekDay,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
        'createdBy': createdBy,
      };
}
