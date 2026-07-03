import 'package:cloud_firestore/cloud_firestore.dart';

class DetachmentDayModel {
  final String uid;
  final String dayName;
  final String? leaderName;
  final String location;
  final int durationDays;
  final DateTime dayDate;
  final int weekDay;
  final bool isActive;
  final String status;
  final String? description;
  final String? rules;
  final List<String> memberIds;
  final DateTime createdAt;
  final String createdBy;

  const DetachmentDayModel({
    required this.uid,
    required this.dayName,
    this.leaderName,
    required this.location,
    this.durationDays = 1,
    required this.dayDate,
    required this.weekDay,
    required this.isActive,
    this.status = 'active',
    this.description,
    this.rules,
    this.memberIds = const [],
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
      leaderName: data['leaderName'] as String?,
      location: data['location'] as String? ?? '',
      durationDays: data['durationDays'] as int? ?? 1,
      dayDate: (data['dayDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weekDay: data['weekDay'] as int? ?? 1,
      isActive: data['isActive'] as bool? ?? true,
      status: data['status'] as String? ?? 'active',
      description: data['description'] as String?,
      rules: data['rules'] as String?,
      memberIds: List<String>.from(data['memberIds'] as List? ?? []),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, Object?> toFirestore() => {
        'dayName': dayName,
        'leaderName': leaderName,
        'location': location,
        'durationDays': durationDays,
        'dayDate': Timestamp.fromDate(dayDate),
        'weekDay': weekDay,
        'isActive': isActive,
        'status': status,
        'description': description,
        'rules': rules,
        'memberIds': memberIds,
        'createdAt': Timestamp.fromDate(createdAt),
        'createdBy': createdBy,
      };

  DetachmentDayModel copyWith({
    String? uid,
    String? dayName,
    String? leaderName,
    String? location,
    int? durationDays,
    DateTime? dayDate,
    int? weekDay,
    bool? isActive,
    String? status,
    String? description,
    String? rules,
    List<String>? memberIds,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return DetachmentDayModel(
      uid: uid ?? this.uid,
      dayName: dayName ?? this.dayName,
      leaderName: leaderName ?? this.leaderName,
      location: location ?? this.location,
      durationDays: durationDays ?? this.durationDays,
      dayDate: dayDate ?? this.dayDate,
      weekDay: weekDay ?? this.weekDay,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      description: description ?? this.description,
      rules: rules ?? this.rules,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
