// lib/shared/repositories/notification_repository.dart
// WHY: Notifications data access from Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_schema.dart';

class NotificationRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<NotificationSchema>> streamNotifications() {
    return _db
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(NotificationSchema.fromFirestore).toList());
  }

  Future<void> markAsRead(String uid, String userId) async {
    await _db.collection('notifications').doc(uid).update({
      'readByUids': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> markAllAsRead(String userId, List<String> uids) async {
    for (final uid in uids) {
      await _db.collection('notifications').doc(uid).update({
        'readByUids': FieldValue.arrayUnion([userId]),
      });
    }
  }
}
