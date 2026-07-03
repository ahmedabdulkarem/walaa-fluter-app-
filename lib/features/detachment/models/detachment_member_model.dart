import 'package:cloud_firestore/cloud_firestore.dart';

class DetachmentMemberModel {
  final String uid;
  final String detachmentId;
  final String name;
  final String role;
  final String? specialty;
  final String? phone;
  final String? rule;
  final bool isActive;
  final DateTime createdAt;

  const DetachmentMemberModel({
    required this.uid,
    this.detachmentId = '',
    required this.name,
    this.role = 'عضو',
    this.specialty,
    this.phone,
    this.rule,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isLeader => role == 'leader' || role == 'مسؤول';

  factory DetachmentMemberModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    return DetachmentMemberModel(
      uid: doc.id,
      detachmentId: data['detachmentId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      role: data['role'] as String? ?? 'عضو',
      specialty: data['specialty'] as String?,
      phone: data['phone'] as String?,
      rule: data['rule'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, Object?> toFirestore() => {
        'detachmentId': detachmentId,
        'name': name,
        'role': role,
        'specialty': specialty,
        'phone': phone,
        'rule': rule,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  DetachmentMemberModel copyWith({
    String? uid,
    String? detachmentId,
    String? name,
    String? role,
    String? specialty,
    String? phone,
    String? rule,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return DetachmentMemberModel(
      uid: uid ?? this.uid,
      detachmentId: detachmentId ?? this.detachmentId,
      name: name ?? this.name,
      role: role ?? this.role,
      specialty: specialty ?? this.specialty,
      phone: phone ?? this.phone,
      rule: rule ?? this.rule,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
