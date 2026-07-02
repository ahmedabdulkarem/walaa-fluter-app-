// lib/shared/repositories/dynamic_field_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/permission_constants.dart';
import '../../core/error/failure.dart';
import '../../core/utils/result.dart';
import '../models/dynamic_field_schema.dart';
import '../models/user_schema.dart';

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

  Future<Result<void>> upsert(DynamicFieldSchema field, UserSchema author) async {
    if (!author.can(PermissionConstants.manageDetachment)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db.collection('dynamic_fields').doc(field.key).set(field.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> delete(String key, UserSchema author) async {
    if (!author.can(PermissionConstants.manageDetachment)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      await _db.collection('dynamic_fields').doc(key).delete();
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
