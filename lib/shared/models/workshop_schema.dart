// lib/shared/models/workshop_schema.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class WorkshopSchema {
  String id;
  String uid;
  String title;
  String description;
  String instructorName;
  DateTime? dateTime;
  DateTime? endDateTime;
  String location;
  bool isOnline;
  String? meetingLink;
  int capacity;
  String status;
  double subscriptionFee;
  String? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;

  WorkshopSchema({
    this.id = '',
    this.uid = '',
    this.title = '',
    this.description = '',
    this.instructorName = '',
    this.dateTime,
    this.endDateTime,
    this.location = '',
    this.isOnline = false,
    this.meetingLink,
    this.capacity = 0,
    this.status = 'upcoming',
    this.subscriptionFee = 0,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkshopSchema.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkshopSchema(
      id: doc.id,
      uid: data['uid'] ?? doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      instructorName: data['instructorName'] ?? '',
      dateTime: data['dateTime'] != null
          ? (data['dateTime'] as Timestamp).toDate()
          : null,
      endDateTime: data['endDateTime'] != null
          ? (data['endDateTime'] as Timestamp).toDate()
          : null,
      location: data['location'] ?? '',
      isOnline: data['isOnline'] ?? false,
      meetingLink: data['meetingLink'],
      capacity: data['capacity'] ?? 0,
      status: data['status'] ?? 'upcoming',
      subscriptionFee: (data['subscriptionFee'] ?? 0).toDouble(),
      createdBy: data['createdBy'],
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
      'title': title,
      'description': description,
      'instructorName': instructorName,
      'dateTime':
          dateTime != null ? Timestamp.fromDate(dateTime!) : null,
      'endDateTime':
          endDateTime != null ? Timestamp.fromDate(endDateTime!) : null,
      'location': location,
      'isOnline': isOnline,
      'meetingLink': meetingLink,
      'capacity': capacity,
      'status': status,
      'subscriptionFee': subscriptionFee,
      'createdBy': createdBy,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
