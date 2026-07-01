// lib/shared/models/detachment_day_schema.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class DetachmentDaySchema {
  String id;
  String uid;
  String title;
  DateTime? date;
  String location;
  String? description;
  bool isActive;
  String? createdBy;
  DateTime? createdAt;

  DetachmentDaySchema({
    this.id = '',
    this.uid = '',
    this.title = '',
    this.date,
    this.location = '',
    this.description,
    this.isActive = true,
    this.createdBy,
    this.createdAt,
  });

  factory DetachmentDaySchema.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DetachmentDaySchema(
      id: doc.id,
      uid: data['uid'] ?? doc.id,
      title: data['title'] ?? '',
      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : null,
      location: data['location'] ?? '',
      description: data['description'],
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'title': title,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'location': location,
      'description': description,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
