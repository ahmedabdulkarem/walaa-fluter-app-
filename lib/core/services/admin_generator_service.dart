// lib/core/services/admin_generator_service.dart
// WHY: Generates sub-admin credentials (username, password, salt) and saves to Firestore.
// Uses CredentialGenerator for secure random generation.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import '../utils/credential_generator.dart';

class AdminGeneratorService {
  static Future<Map<String, String>> createSubAdmin({
    required String name,
    required List<String> permissions,
    required DateTime sessionExpiresAt,
  }) async {
    final username = CredentialGenerator.generateUsername();
    final password = CredentialGenerator.generatePassword();
    final salt = AuthService.generateSalt();
    final hashedPassword = AuthService.hashPasswordWithSalt(password, salt);

    final docRef = FirebaseFirestore.instance.collection('admins').doc();
    await docRef.set({
      'uid': docRef.id,
      'name': name,
      'username': username,
      'passwordHash': hashedPassword,
      'passwordSalt': salt,
      'permissions': permissions,
      'sessionExpiresAt': Timestamp.fromDate(sessionExpiresAt),
      'isActive': true,
      'isSuperAdmin': false,
      'createdAt': Timestamp.now(),
    });

    return {
      'name': name,
      'username': username,
      'password': password,
    };
  }
}
