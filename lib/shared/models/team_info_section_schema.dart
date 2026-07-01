// lib/shared/models/team_info_section_schema.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TeamInfoSectionSchema {
  String id;
  String key;
  int sortOrder;
  String titleAr;
  String titleEn;
  String bodyAr;
  String bodyEn;
  DateTime? updatedAt;
  String? updatedBy;

  TeamInfoSectionSchema({
    this.id = '',
    this.key = '',
    this.sortOrder = 0,
    this.titleAr = '',
    this.titleEn = '',
    this.bodyAr = '',
    this.bodyEn = '',
    this.updatedAt,
    this.updatedBy,
  });

  factory TeamInfoSectionSchema.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeamInfoSectionSchema(
      id: doc.id,
      key: data['key'] ?? '',
      sortOrder: data['sortOrder'] ?? 0,
      titleAr: data['titleAr'] ?? '',
      titleEn: data['titleEn'] ?? '',
      bodyAr: data['bodyAr'] ?? '',
      bodyEn: data['bodyEn'] ?? '',
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      updatedBy: data['updatedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'key': key,
      'sortOrder': sortOrder,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'bodyAr': bodyAr,
      'bodyEn': bodyEn,
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'updatedBy': updatedBy,
    };
  }
}
