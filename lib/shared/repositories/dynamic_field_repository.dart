// lib/shared/repositories/dynamic_field_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dynamic_field_schema.dart';

class DynamicFieldRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<DynamicFieldSchema>> streamByCategory(String category) {
    return _db
        .collection('dynamic_fields')
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs.map(DynamicFieldSchema.fromFirestore).toList());
  }

  Future<List<DynamicFieldSchema>> getByCategory(String category) async {
    final snap = await _db
        .collection('dynamic_fields')
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return snap.docs.map(DynamicFieldSchema.fromFirestore).toList();
  }

  Future<void> upsert(DynamicFieldSchema field) async {
    await _db.collection('dynamic_fields').doc(field.key).set(field.toFirestore());
  }

  Future<void> delete(String key) async {
    await _db.collection('dynamic_fields').doc(key).delete();
  }
}
