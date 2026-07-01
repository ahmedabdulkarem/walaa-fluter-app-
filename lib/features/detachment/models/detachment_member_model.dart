import 'package:cloud_firestore/cloud_firestore.dart';

class DetachmentMemberModel {
  final String uid;
  final String name;
  final String role;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;

  const DetachmentMemberModel({
    required this.uid,
    required this.name,
    required this.role,
    this.phone,
    required this.isActive,
    required this.createdAt,
  });

  factory DetachmentMemberModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!;
    return DetachmentMemberModel(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      role: data['role'] as String? ?? 'volunteer',
      phone: data['phone'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, Object?> toFirestore() => {
        'name': name,
        'role': role,
        'phone': phone,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  DetachmentMemberModel copyWith({
    String? uid,
    String? name,
    String? role,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return DetachmentMemberModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
