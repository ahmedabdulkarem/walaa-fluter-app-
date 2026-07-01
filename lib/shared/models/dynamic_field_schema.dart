// lib/shared/models/dynamic_field_schema.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class DynamicFieldSchema {
  String id;
  String key;
  String category;
  String labelAr;
  String labelEn;
  int sortOrder;
  bool isActive;

  DynamicFieldSchema({
    this.id = '',
    this.key = '',
    this.category = '',
    this.labelAr = '',
    this.labelEn = '',
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory DynamicFieldSchema.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DynamicFieldSchema(
      id: doc.id,
      key: data['key'] ?? '',
      category: data['category'] ?? '',
      labelAr: data['labelAr'] ?? '',
      labelEn: data['labelEn'] ?? '',
      sortOrder: data['sortOrder'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'key': key,
      'category': category,
      'labelAr': labelAr,
      'labelEn': labelEn,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }
}
