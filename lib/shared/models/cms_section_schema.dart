// lib/shared/models/cms_section_schema.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CmsSectionSchema {
  String id;
  String key;
  String type;
  String titleAr;
  String titleEn;
  String bodyAr;
  String bodyEn;
  int sortOrder;
  bool isPublished;
  String? iconName;
  String? imageUrl;
  DateTime? updatedAt;
  String? updatedBy;

  CmsSectionSchema({
    this.id = '',
    this.key = '',
    this.type = '',
    this.titleAr = '',
    this.titleEn = '',
    this.bodyAr = '',
    this.bodyEn = '',
    this.sortOrder = 0,
    this.isPublished = true,
    this.iconName,
    this.imageUrl,
    this.updatedAt,
    this.updatedBy,
  });

  factory CmsSectionSchema.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CmsSectionSchema(
      id: doc.id,
      key: data['key'] ?? '',
      type: data['type'] ?? '',
      titleAr: data['titleAr'] ?? '',
      titleEn: data['titleEn'] ?? '',
      bodyAr: data['bodyAr'] ?? '',
      bodyEn: data['bodyEn'] ?? '',
      sortOrder: data['sortOrder'] ?? 0,
      isPublished: data['isPublished'] ?? true,
      iconName: data['iconName'],
      imageUrl: data['imageUrl'],
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      updatedBy: data['updatedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'key': key,
      'type': type,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'bodyAr': bodyAr,
      'bodyEn': bodyEn,
      'sortOrder': sortOrder,
      'isPublished': isPublished,
      'iconName': iconName,
      'imageUrl': imageUrl,
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'updatedBy': updatedBy,
    };
  }
}
