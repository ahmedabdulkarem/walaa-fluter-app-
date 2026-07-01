// lib/shared/repositories/post_repository.dart
// WHY: Post CRUD operations — creates, reads, updates, deletes posts with permission checks.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/permission_constants.dart';
import '../../core/error/failure.dart';
import '../../core/utils/result.dart';
import '../models/post_schema.dart';
import '../models/user_schema.dart';

class PostRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<PostSchema>> streamPosts() {
    return _db
        .collection('posts')
        .orderBy('isPinned', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(PostSchema.fromFirestore).toList());
  }

  Future<PostSchema?> getPost(String uid) async {
    final snap = await _db.collection('posts').where('uid', isEqualTo: uid).get();
    if (snap.docs.isEmpty) return null;
    return PostSchema.fromFirestore(snap.docs.first);
  }

  Future<Result<void>> createPost(PostSchema post, UserSchema author) async {
    if (!author.can(PermissionConstants.publishPosts)) {
      return const FailureResult(
        PermissionFailure('Insufficient permissions to publish posts'),
      );
    }
    try {
      await _db.collection('posts').doc(post.uid).set(post.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> updatePost(PostSchema post, UserSchema author) async {
    if (!author.can(PermissionConstants.publishPosts)) {
      return const FailureResult(PermissionFailure('Insufficient permissions'));
    }
    try {
      post.updatedAt = DateTime.now();
      await _db.collection('posts').doc(post.uid).update(post.toFirestore());
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> deletePost(String uid, UserSchema author) async {
    if (!author.can(PermissionConstants.editDeletePosts) && !author.isSuperAdmin) {
      return const FailureResult(
        PermissionFailure('Insufficient permissions to delete posts'),
      );
    }
    try {
      await _db.collection('posts').doc(uid).delete();
      return const Success(null);
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
