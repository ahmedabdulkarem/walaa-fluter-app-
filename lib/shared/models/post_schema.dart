// lib/shared/models/post_schema.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PostSchema {
  String id;
  String uid;
  String title;
  String body;
  String category;
  String authorUid;
  String authorName;
  String? imageUrl;
  bool isPinned;
  bool isUrgent;
  List<String> visibilityRoles;
  DateTime? createdAt;
  DateTime? updatedAt;

  PostSchema({
    this.id = '',
    this.uid = '',
    this.title = '',
    this.body = '',
    this.category = '',
    this.authorUid = '',
    this.authorName = '',
    this.imageUrl,
    this.isPinned = false,
    this.isUrgent = false,
    this.visibilityRoles = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory PostSchema.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostSchema(
      id: doc.id,
      uid: data['uid'] ?? doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      category: data['category'] ?? '',
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? '',
      imageUrl: data['imageUrl'],
      isPinned: data['isPinned'] ?? false,
      isUrgent: data['isUrgent'] ?? false,
      visibilityRoles: List<String>.from(data['visibilityRoles'] ?? []),
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
      'body': body,
      'category': category,
      'authorUid': authorUid,
      'authorName': authorName,
      'imageUrl': imageUrl,
      'isPinned': isPinned,
      'isUrgent': isUrgent,
      'visibilityRoles': visibilityRoles,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
