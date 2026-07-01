// lib/shared/models/team_member_schema.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TeamMemberSchema {
  String id;
  String uid;
  String fullName;
  String role;
  String? department;
  String? phone;
  String? email;
  String? photoUrl;
  int sortOrder;
  bool isLeadership;

  TeamMemberSchema({
    this.id = '',
    this.uid = '',
    this.fullName = '',
    this.role = '',
    this.department,
    this.phone,
    this.email,
    this.photoUrl,
    this.sortOrder = 0,
    this.isLeadership = false,
  });

  factory TeamMemberSchema.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TeamMemberSchema(
      id: doc.id,
      uid: data['uid'] ?? doc.id,
      fullName: data['fullName'] ?? '',
      role: data['role'] ?? '',
      department: data['department'],
      phone: data['phone'],
      email: data['email'],
      photoUrl: data['photoUrl'],
      sortOrder: data['sortOrder'] ?? 0,
      isLeadership: data['isLeadership'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'fullName': fullName,
      'role': role,
      'department': department,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'sortOrder': sortOrder,
      'isLeadership': isLeadership,
    };
  }
}
