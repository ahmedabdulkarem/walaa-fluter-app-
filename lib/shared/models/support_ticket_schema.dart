// lib/shared/models/support_ticket_schema.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class SupportTicketSchema {
  String id;
  String uid;
  String subject;
  String message;
  String category;
  String createdBy;
  String createdByName;
  String status;
  String? assignedTo;
  String? response;
  DateTime? createdAt;
  DateTime? updatedAt;

  SupportTicketSchema({
    this.id = '',
    this.uid = '',
    this.subject = '',
    this.message = '',
    this.category = '',
    this.createdBy = '',
    this.createdByName = '',
    this.status = 'open',
    this.assignedTo,
    this.response,
    this.createdAt,
    this.updatedAt,
  });

  factory SupportTicketSchema.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportTicketSchema(
      id: doc.id,
      uid: data['uid'] ?? doc.id,
      subject: data['subject'] ?? '',
      message: data['message'] ?? '',
      category: data['category'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdByName: data['createdByName'] ?? '',
      status: data['status'] ?? 'open',
      assignedTo: data['assignedTo'],
      response: data['response'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'subject': subject,
      'message': message,
      'category': category,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'status': status,
      'assignedTo': assignedTo,
      'response': response,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
