// lib/shared/models/user_schema.dart
// WHY: Core user data model — includes role, permissions, session expiry, and computed accessors.

import 'package:cloud_firestore/cloud_firestore.dart';

class UserSchema {
  String id;
  String uid;
  String displayName;
  String email;
  String? username;
  String role;
  bool isSuperAdmin;
  List<String> permissions;
  String? passwordHash;
  String? department;
  String? phone;
  String? photoUrl;
  String language;
  bool isActive;
  int? sessionDurationHours;
  DateTime? accountExpiresAt;
  String? createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? lastLoginAt;

  UserSchema({
    this.id = '',
    this.uid = '',
    this.displayName = '',
    this.email = '',
    this.username,
    this.role = '',
    this.isSuperAdmin = false,
    this.permissions = const [],
    this.passwordHash,
    this.department,
    this.phone,
    this.photoUrl,
    this.language = 'ar',
    this.isActive = true,
    this.sessionDurationHours,
    this.accountExpiresAt,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  // ── Computed accessors ──────────────────────────────────

  bool get isSessionExpired {
    if (isSuperAdmin) return false;
    if (accountExpiresAt == null) return false;
    return DateTime.now().isAfter(accountExpiresAt!);
  }

  bool get isSubAdmin => role == 'sub_admin';
  bool get isVolunteer => role == 'volunteer';

  bool can(String permission) {
    if (isSuperAdmin) return true;
    if (!isActive || isSessionExpired) return false;
    return permissions.contains(permission);
  }

  factory UserSchema.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSchema(
      id: doc.id,
      uid: data['uid'] ?? doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      username: data['username'],
      role: data['role'] ?? 'volunteer',
      isSuperAdmin: data['isSuperAdmin'] ?? false,
      permissions: List<String>.from(data['permissions'] ?? []),
      passwordHash: data['passwordHash'],
      department: data['department'],
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      language: data['language'] ?? 'ar',
      isActive: data['isActive'] ?? true,
      sessionDurationHours: data['sessionDurationHours'],
      accountExpiresAt: data['accountExpiresAt'] != null
          ? (data['accountExpiresAt'] as Timestamp).toDate()
          : null,
      createdBy: data['createdBy'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      lastLoginAt: data['lastLoginAt'] != null
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'username': username,
      'role': role,
      'isSuperAdmin': isSuperAdmin,
      'permissions': permissions,
      'passwordHash': passwordHash,
      'department': department,
      'phone': phone,
      'photoUrl': photoUrl,
      'language': language,
      'isActive': isActive,
      'sessionDurationHours': sessionDurationHours,
      'accountExpiresAt':
          accountExpiresAt != null ? Timestamp.fromDate(accountExpiresAt!) : null,
      'createdBy': createdBy,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
    };
  }

  UserSchema copyWith({
    String? displayName,
    String? phone,
    String? photoUrl,
    String? language,
    bool? isActive,
    List<String>? permissions,
    int? sessionDurationHours,
    DateTime? accountExpiresAt,
    DateTime? lastLoginAt,
  }) {
    return UserSchema(
      id: id,
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      username: username,
      role: role,
      isSuperAdmin: isSuperAdmin,
      permissions: permissions ?? this.permissions,
      passwordHash: passwordHash,
      department: department,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      language: language ?? this.language,
      isActive: isActive ?? this.isActive,
      sessionDurationHours: sessionDurationHours ?? this.sessionDurationHours,
      accountExpiresAt: accountExpiresAt ?? this.accountExpiresAt,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
