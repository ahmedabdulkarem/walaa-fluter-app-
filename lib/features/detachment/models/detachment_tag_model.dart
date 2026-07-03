import 'package:cloud_firestore/cloud_firestore.dart';

class DetachmentTagModel {
  final String id;
  final String type;
  final String value;
  final DateTime createdAt;

  const DetachmentTagModel({
    required this.id,
    required this.type,
    required this.value,
    required this.createdAt,
  });

  factory DetachmentTagModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    return DetachmentTagModel(
      id: doc.id,
      type: data['type'] as String? ?? '',
      value: data['value'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, Object?> toFirestore() => {
        'type': type,
        'value': value,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
