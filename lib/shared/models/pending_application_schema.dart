// lib/shared/models/pending_application_schema.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PendingApplicationSchema {
  String id;
  String uid;
  String fullName;
  String email;
  String? phone;
  String applicationType;
  String message;
  String status;
  String? reviewedBy;
  DateTime? reviewedAt;
  String? reviewNotes;
  DateTime? createdAt;

  PendingApplicationSchema({
    this.id = '',
    this.uid = '',
    this.fullName = '',
    this.email = '',
    this.phone,
    this.applicationType = '',
    this.message = '',
    this.status = 'pending',
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
    this.createdAt,
  });

  factory PendingApplicationSchema.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PendingApplicationSchema(
      id: doc.id,
      uid: data['uid'] ?? doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      applicationType: data['applicationType'] ?? '',
      message: data['message'] ?? '',
      status: data['status'] ?? 'pending',
      reviewedBy: data['reviewedBy'],
      reviewedAt: data['reviewedAt'] != null
          ? (data['reviewedAt'] as Timestamp).toDate()
          : null,
      reviewNotes: data['reviewNotes'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'applicationType': applicationType,
      'message': message,
      'status': status,
      'reviewedBy': reviewedBy,
      'reviewedAt':
          reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewNotes': reviewNotes,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
