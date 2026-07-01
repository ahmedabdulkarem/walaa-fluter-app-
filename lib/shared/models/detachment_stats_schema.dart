// lib/shared/models/detachment_stats_schema.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PatientCategory {
  String label;
  int count;

  PatientCategory({
    this.label = '',
    this.count = 0,
  });

  factory PatientCategory.fromJson(Map<String, dynamic> json) {
    return PatientCategory(
      label: json['label'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'count': count,
    };
  }
}

class DetachmentStatsSchema {
  String id;
  String uid;
  String dayId;
  int totalPatients;
  List<PatientCategory> categories;
  String? notes;
  String? recordedBy;
  String? recordedByName;
  DateTime? recordedAt;
  DateTime? updatedAt;

  DetachmentStatsSchema({
    this.id = '',
    this.uid = '',
    this.dayId = '',
    this.totalPatients = 0,
    this.categories = const [],
    this.notes,
    this.recordedBy,
    this.recordedByName,
    this.recordedAt,
    this.updatedAt,
  });

  factory DetachmentStatsSchema.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DetachmentStatsSchema(
      id: doc.id,
      uid: data['uid'] ?? doc.id,
      dayId: data['dayId'] ?? '',
      totalPatients: data['totalPatients'] ?? 0,
      categories: (data['categories'] as List<dynamic>?)
              ?.map((e) => PatientCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: data['notes'],
      recordedBy: data['recordedBy'],
      recordedByName: data['recordedByName'],
      recordedAt: data['recordedAt'] != null
          ? (data['recordedAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'dayId': dayId,
      'totalPatients': totalPatients,
      'categories': categories.map((e) => e.toJson()).toList(),
      'notes': notes,
      'recordedBy': recordedBy,
      'recordedByName': recordedByName,
      'recordedAt':
          recordedAt != null ? Timestamp.fromDate(recordedAt!) : null,
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
