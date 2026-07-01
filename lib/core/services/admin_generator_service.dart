// lib/core/services/admin_generator_service.dart
// WHY: Generates sub-admin credentials and saves to Firestore.

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class AdminGeneratorService {
  static String generateUsername() {
    const adjectives = ['swift', 'noble', 'brave', 'calm', 'sharp'];
    const nouns = ['eagle', 'lion', 'wolf', 'hawk', 'bear'];
    final rand = Random();
    final adj = adjectives[rand.nextInt(adjectives.length)];
    final noun = nouns[rand.nextInt(nouns.length)];
    final num = rand.nextInt(900) + 100;
    return '$adj$noun$num';
  }

  static String generatePassword() {
    const chars =
        'abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ23456789!@#';
    final rand = Random.secure();
    return List.generate(10, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  static Future<Map<String, String>> createSubAdmin({
    required String name,
    required List<String> permissions,
    required DateTime sessionExpiresAt,
  }) async {
    final username = generateUsername();
    final password = generatePassword();
    final hashedPassword = AuthService.hashPassword(password);

    final docRef =
        FirebaseFirestore.instance.collection('admins').doc();
    await docRef.set({
      'uid': docRef.id,
      'name': name,
      'username': username,
      'passwordHash': hashedPassword,
      'permissions': permissions,
      'sessionExpiresAt': Timestamp.fromDate(sessionExpiresAt),
      'isActive': true,
      'createdAt': Timestamp.now(),
    });

    return {
      'name': name,
      'username': username,
      'password': password,
    };
  }
}
