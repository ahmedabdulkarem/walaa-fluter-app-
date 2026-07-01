// lib/core/services/auth_service.dart
// WHY: Local auth — device-based super admin detection, sub-admin login via Firestore + SHA-256.

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/user_schema.dart';
import 'device_service.dart';

class AuthService {
  static const _superDeviceKey = 'super_admin_device_id';
  static const _sessionKey = 'logged_in_admin_uid';
  static const _sessionRoleKey = 'logged_in_role';
  static const _adminsCollection = 'admins';

  static String? _currentUid;
  static String? _currentRole;

  static String? get currentUid => _currentUid;
  static String? get currentRole => _currentRole;
  static bool get isSuperAdmin => _currentRole == 'super_admin';
  static bool get isLoggedIn => _currentUid != null;

  static Future<String> checkAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final currentDeviceId = await DeviceService.getDeviceId();

    final savedSuperDeviceId = prefs.getString(_superDeviceKey);
    if (savedSuperDeviceId == null) {
      await prefs.setString(_superDeviceKey, currentDeviceId);
      await prefs.setString(_sessionKey, 'super_admin');
      await prefs.setString(_sessionRoleKey, 'super_admin');
      _currentUid = 'super_admin';
      _currentRole = 'super_admin';
      return 'super_admin';
    }

    if (savedSuperDeviceId == currentDeviceId) {
      await prefs.setString(_sessionKey, 'super_admin');
      await prefs.setString(_sessionRoleKey, 'super_admin');
      _currentUid = 'super_admin';
      _currentRole = 'super_admin';
      return 'super_admin';
    }

    final sessionUid = prefs.getString(_sessionKey);
    if (sessionUid != null && sessionUid != 'super_admin') {
      try {
        final doc = await FirebaseFirestore.instance
            .collection(_adminsCollection)
            .doc(sessionUid)
            .get();
        if (doc.exists) {
          final data = doc.data()!;
          final isActive = data['isActive'] as bool? ?? true;
          final expiresAt =
              (data['sessionExpiresAt'] as Timestamp?)?.toDate();
          if (isActive &&
              expiresAt != null &&
              DateTime.now().isBefore(expiresAt)) {
            _currentUid = sessionUid;
            _currentRole = 'sub_admin';
            return 'sub_admin';
          }
        }
      } catch (_) {}
      await prefs.remove(_sessionKey);
      await prefs.remove(_sessionRoleKey);
    }

    return 'none';
  }

  static Future<bool> login(String username, String password) async {
    try {
      final hashedPassword = hashPassword(password);

      final query = await FirebaseFirestore.instance
          .collection(_adminsCollection)
          .where('username', isEqualTo: username.trim())
          .where('passwordHash', isEqualTo: hashedPassword)
          .where('isActive', isEqualTo: true)
          .get();

      if (query.docs.isEmpty) return false;

      final doc = query.docs.first;
      final data = doc.data();
      final expiresAt = (data['sessionExpiresAt'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiresAt)) return false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, doc.id);
      await prefs.setString(_sessionRoleKey, 'sub_admin');
      _currentUid = doc.id;
      _currentRole = 'sub_admin';

      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_sessionRoleKey);
    _currentUid = null;
    _currentRole = null;
  }

  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  static Future<UserSchema?> getUserByUid(String uid) async {
    if (uid == 'super_admin') {
      return UserSchema()
        ..uid = 'super_admin'
        ..displayName = 'Super Admin'
        ..email = 'super@admin.internal'
        ..role = 'super_admin'
        ..isSuperAdmin = true
        ..permissions = []
        ..language = 'ar'
        ..isActive = true;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_adminsCollection)
          .doc(uid)
          .get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return UserSchema()
        ..uid = doc.id
        ..displayName = data['name'] ?? ''
        ..email = data['username'] ?? ''
        ..username = data['username']
        ..role = 'sub_admin'
        ..isSuperAdmin = false
        ..permissions = List<String>.from(data['permissions'] ?? [])
        ..isActive = data['isActive'] ?? true
        ..accountExpiresAt =
            (data['sessionExpiresAt'] as Timestamp?)?.toDate()
        ..language = 'ar';
    } catch (_) {
      return null;
    }
  }

  static Future<UserSchema?> getCurrentUser() async {
    if (_currentUid == null || _currentUid == 'super_admin') {
      return UserSchema()
        ..uid = 'super_admin'
        ..displayName = 'Super Admin'
        ..email = 'super@admin.internal'
        ..role = 'super_admin'
        ..isSuperAdmin = true
        ..permissions = []
        ..language = 'ar'
        ..isActive = true;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_adminsCollection)
          .doc(_currentUid!)
          .get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return UserSchema()
        ..uid = doc.id
        ..displayName = data['name'] ?? ''
        ..email = data['username'] ?? ''
        ..username = data['username']
        ..role = 'sub_admin'
        ..isSuperAdmin = false
        ..permissions = List<String>.from(data['permissions'] ?? [])
        ..isActive = data['isActive'] ?? true
        ..accountExpiresAt =
            (data['sessionExpiresAt'] as Timestamp?)?.toDate()
        ..createdAt = (data['createdAt'] as Timestamp?)?.toDate()
        ..language = 'ar';
    } catch (_) {
      return null;
    }
  }

  static Stream<List<UserSchema>> streamSubAdmins() {
    return FirebaseFirestore.instance
        .collection(_adminsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              return UserSchema()
                ..uid = doc.id
                ..displayName = data['name'] ?? ''
                ..email = data['username'] ?? ''
                ..username = data['username']
                ..role = 'sub_admin'
                ..isSuperAdmin = false
                ..permissions = List<String>.from(data['permissions'] ?? [])
                ..isActive = data['isActive'] ?? true
                ..accountExpiresAt =
                    (data['sessionExpiresAt'] as Timestamp?)?.toDate()
                ..createdAt = (data['createdAt'] as Timestamp?)?.toDate()
                ..language = 'ar';
            }).toList());
  }
}
