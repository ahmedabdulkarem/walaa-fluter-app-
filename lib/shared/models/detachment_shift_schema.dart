// lib/shared/models/detachment_shift_schema.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInEntry {
  String uid;
  String name;
  DateTime? checkedInAt;

  CheckInEntry({
    this.uid = '',
    this.name = '',
    this.checkedInAt,
  });

  factory CheckInEntry.fromJson(Map<String, dynamic> json) {
    return CheckInEntry(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      checkedInAt: json['checkedInAt'] != null
          ? (json['checkedInAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'checkedInAt':
          checkedInAt != null ? Timestamp.fromDate(checkedInAt!) : null,
    };
  }
}

class DetachmentShiftSchema {
  String id;
  String uid;
  String dayId;
  String label;
  String startTime;
  String endTime;
  List<String> assignedAdminUids;
  List<String> checkedInUids;
  List<CheckInEntry> checkIns;
  DateTime? createdAt;

  DetachmentShiftSchema({
    this.id = '',
    this.uid = '',
    this.dayId = '',
    this.label = '',
    this.startTime = '',
    this.endTime = '',
    this.assignedAdminUids = const [],
    this.checkedInUids = const [],
    this.checkIns = const [],
    this.createdAt,
  });

  factory DetachmentShiftSchema.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DetachmentShiftSchema(
      id: doc.id,
      uid: data['uid'] ?? doc.id,
      dayId: data['dayId'] ?? '',
      label: data['label'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      assignedAdminUids: List<String>.from(data['assignedAdminUids'] ?? []),
      checkedInUids: List<String>.from(data['checkedInUids'] ?? []),
      checkIns: (data['checkIns'] as List<dynamic>?)
              ?.map((e) => CheckInEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'dayId': dayId,
      'label': label,
      'startTime': startTime,
      'endTime': endTime,
      'assignedAdminUids': assignedAdminUids,
      'checkedInUids': checkedInUids,
      'checkIns': checkIns.map((e) => e.toJson()).toList(),
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
