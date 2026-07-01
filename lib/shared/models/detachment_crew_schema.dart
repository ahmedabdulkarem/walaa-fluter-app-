// lib/shared/models/detachment_crew_schema.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class DetachmentCrewSchema {
  String id;
  String uid;
  String dayId;
  String fullName;
  String role;
  String? phone;
  String? addedBy;
  DateTime? addedAt;

  DetachmentCrewSchema({
    this.id = '',
    this.uid = '',
    this.dayId = '',
    this.fullName = '',
    this.role = '',
    this.phone,
    this.addedBy,
    this.addedAt,
  });

  factory DetachmentCrewSchema.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DetachmentCrewSchema(
      id: doc.id,
      uid: data['uid'] ?? doc.id,
      dayId: data['dayId'] ?? '',
      fullName: data['fullName'] ?? '',
      role: data['role'] ?? '',
      phone: data['phone'],
      addedBy: data['addedBy'],
      addedAt: data['addedAt'] != null
          ? (data['addedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'dayId': dayId,
      'fullName': fullName,
      'role': role,
      'phone': phone,
      'addedBy': addedBy,
      'addedAt':
          addedAt != null ? Timestamp.fromDate(addedAt!) : null,
    };
  }
}
