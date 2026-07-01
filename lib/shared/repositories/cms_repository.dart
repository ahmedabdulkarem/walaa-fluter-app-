// lib/shared/repositories/cms_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cms_section_schema.dart';

class CmsRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<CmsSectionSchema>> streamSections() {
    return _db
        .collection('cms_sections')
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs.map(CmsSectionSchema.fromFirestore).toList());
  }

  Stream<List<CmsSectionSchema>> streamPublishedByType(String type) {
    return _db
        .collection('cms_sections')
        .where('type', isEqualTo: type)
        .where('isPublished', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) => snap.docs.map(CmsSectionSchema.fromFirestore).toList());
  }

  Future<CmsSectionSchema?> getByKey(String key) async {
    final snap = await _db
        .collection('cms_sections')
        .where('key', isEqualTo: key)
        .get();
    if (snap.docs.isEmpty) return null;
    return CmsSectionSchema.fromFirestore(snap.docs.first);
  }

  Future<void> upsert(CmsSectionSchema section) async {
    await _db.collection('cms_sections').doc(section.key).set(section.toFirestore());
  }

  Future<void> delete(String key) async {
    await _db.collection('cms_sections').doc(key).delete();
  }
}
