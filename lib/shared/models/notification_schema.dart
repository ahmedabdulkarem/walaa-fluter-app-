// lib/shared/models/notification_schema.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationSchema {
  String id;
  String uid;
  String title;
  String body;
  String type;
  String? targetId;
  String? createdBy;
  List<String> readByUids;
  DateTime? createdAt;

  NotificationSchema({
    this.id = '',
    this.uid = '',
    this.title = '',
    this.body = '',
    this.type = '',
    this.targetId,
    this.createdBy,
    this.readByUids = const [],
    this.createdAt,
  });

  factory NotificationSchema.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationSchema(
      id: doc.id,
      uid: data['uid'] ?? doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? '',
      targetId: data['targetId'],
      createdBy: data['createdBy'],
      readByUids: List<String>.from(data['readByUids'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'title': title,
      'body': body,
      'type': type,
      'targetId': targetId,
      'createdBy': createdBy,
      'readByUids': readByUids,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
