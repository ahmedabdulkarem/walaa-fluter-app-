import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/detachment_tag_model.dart';

class DetachmentTagRepository {
  final _db = FirebaseFirestore.instance;
  static const _colTags = 'detachment_tags';

  Stream<List<DetachmentTagModel>> watchTagsByType(String type) {
    return _db
        .collection(_colTags)
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .withConverter<DetachmentTagModel>(
          fromFirestore: DetachmentTagModel.fromFirestore,
          toFirestore: (model, _) => model.toFirestore(),
        )
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  Future<void> saveTag({required String type, required String value}) async {
    final id = value.trim();
    if (id.isEmpty) return;
    final ref = _db.collection(_colTags).doc(id);
    final existing = await ref.get();
    if (!existing.exists) {
      await ref.set({
        'type': type,
        'value': id,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> ensureDefaultRoles() async {
    const defaults = ['مسؤول', 'عضو', 'دعم', 'تنظيم', 'اداري', 'متابعة'];
    final existing = await _db
        .collection(_colTags)
        .where('type', isEqualTo: 'role')
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;
    final batch = _db.batch();
    for (final role in defaults) {
      batch.set(
        _db.collection(_colTags).doc(role),
        {
          'type': 'role',
          'value': role,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
    }
    await batch.commit();
  }

  Future<void> saveTags({
    required List<String> specialties,
    required List<String> roles,
  }) async {
    final batch = _db.batch();
    for (final s in specialties) {
      final v = s.trim();
      if (v.isEmpty) continue;
      batch.set(
        _db.collection(_colTags).doc(v),
        {
          'type': 'specialty',
          'value': v,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    for (final r in roles) {
      final v = r.trim();
      if (v.isEmpty) continue;
      batch.set(
        _db.collection(_colTags).doc(r),
        {
          'type': 'role',
          'value': v,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }
}
