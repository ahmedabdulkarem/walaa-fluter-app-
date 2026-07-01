// lib/shared/models/workshop_staff_schema.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class WorkshopStaffSchema {
  String id;
  String uid;
  String workshopId;
  String fullName;
  String? role;
  bool hasPaidSubscription;
  String? paymentConfirmedBy;
  DateTime? paymentConfirmedAt;
  String attendanceStatus;
  String? attendanceMarkedBy;
  DateTime? attendanceMarkedAt;
  String? addedBy;
  DateTime? addedAt;

  WorkshopStaffSchema({
    this.id = '',
    this.uid = '',
    this.workshopId = '',
    this.fullName = '',
    this.role,
    this.hasPaidSubscription = false,
    this.paymentConfirmedBy,
    this.paymentConfirmedAt,
    this.attendanceStatus = 'absent',
    this.attendanceMarkedBy,
    this.attendanceMarkedAt,
    this.addedBy,
    this.addedAt,
  });

  factory WorkshopStaffSchema.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkshopStaffSchema(
      id: doc.id,
      uid: data['uid'] ?? doc.id,
      workshopId: data['workshopId'] ?? '',
      fullName: data['fullName'] ?? '',
      role: data['role'],
      hasPaidSubscription: data['hasPaidSubscription'] ?? false,
      paymentConfirmedBy: data['paymentConfirmedBy'],
      paymentConfirmedAt: data['paymentConfirmedAt'] != null
          ? (data['paymentConfirmedAt'] as Timestamp).toDate()
          : null,
      attendanceStatus: data['attendanceStatus'] ?? 'absent',
      attendanceMarkedBy: data['attendanceMarkedBy'],
      attendanceMarkedAt: data['attendanceMarkedAt'] != null
          ? (data['attendanceMarkedAt'] as Timestamp).toDate()
          : null,
      addedBy: data['addedBy'],
      addedAt: data['addedAt'] != null
          ? (data['addedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'workshopId': workshopId,
      'fullName': fullName,
      'role': role,
      'hasPaidSubscription': hasPaidSubscription,
      'paymentConfirmedBy': paymentConfirmedBy,
      'paymentConfirmedAt': paymentConfirmedAt != null
          ? Timestamp.fromDate(paymentConfirmedAt!)
          : null,
      'attendanceStatus': attendanceStatus,
      'attendanceMarkedBy': attendanceMarkedBy,
      'attendanceMarkedAt': attendanceMarkedAt != null
          ? Timestamp.fromDate(attendanceMarkedAt!)
          : null,
      'addedBy': addedBy,
      'addedAt':
          addedAt != null ? Timestamp.fromDate(addedAt!) : null,
    };
  }
}
