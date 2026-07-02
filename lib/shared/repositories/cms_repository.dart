// lib/shared/repositories/cms_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/failure.dart';
import '../../core/utils/result.dart';
import '../models/cms_section_schema.dart';
import '../models/user_schema.dart';

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
        .doc(key)
        .get();
    if (!snap.exists) return null;
    return CmsSectionSchema.fromFirestore(snap);
  }

  Future<Result<void>> upsert(CmsSectionSchema section, UserSchema author) async {
    if (!author.isSuperAdmin) {
      return const FailureResult(PermissionFailure('Insufficient permissions. Only super admin can manage CMS.'));
    }
    try {
      await _db.collection('cms_sections').doc(section.key).set(section.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> delete(String key, UserSchema author) async {
    if (!author.isSuperAdmin) {
      return const FailureResult(PermissionFailure('Insufficient permissions. Only super admin can manage CMS.'));
    }
    try {
      await _db.collection('cms_sections').doc(key).delete();
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
