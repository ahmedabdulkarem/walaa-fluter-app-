import 'package:cloud_firestore/cloud_firestore.dart';

class DetachmentPatientModel {
  final String uid;
  final String detachmentId;
  final String name;
  final int age;
  final String illness;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  static const statusLabels = {
    'stable': 'مستقر',
    'critical': 'حرج',
    'moderate': 'متوسط',
    'recovered': 'متعافي',
    'transferred': 'محول',
  };

  static const statusColors = {
    'stable': 0xFF22C55E,
    'critical': 0xFFEF4444,
    'moderate': 0xFFF59E0B,
    'recovered': 0xFF3B82F6,
    'transferred': 0xFF8B5CF6,
  };

  const DetachmentPatientModel({
    required this.uid,
    required this.detachmentId,
    required this.name,
    required this.age,
    required this.illness,
    this.status = 'stable',
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  factory DetachmentPatientModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    return DetachmentPatientModel(
      uid: doc.id,
      detachmentId: data['detachmentId'] as String? ?? data['dayId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      illness: data['illness'] as String? ?? '',
      status: data['status'] as String? ?? 'stable',
      notes: data['notes'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, Object?> toFirestore() => {
        'detachmentId': detachmentId,
        'name': name,
        'age': age,
        'illness': illness,
        'status': status,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
        'createdBy': createdBy,
      };

  DetachmentPatientModel copyWith({
    String? uid,
    String? name,
    int? age,
    String? illness,
    String? status,
    String? notes,
  }) {
    return DetachmentPatientModel(
      uid: uid ?? this.uid,
      detachmentId: detachmentId,
      name: name ?? this.name,
      age: age ?? this.age,
      illness: illness ?? this.illness,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}
