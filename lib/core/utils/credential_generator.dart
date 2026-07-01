// lib/core/utils/credential_generator.dart
// WHY: Generates secure random usernames and passwords for sub-admin accounts.
// Uses dart:math with Random.secure() — avoids ambiguous chars (I,O,0,1,i,l,o).

import 'dart:math';

class CredentialGenerator {
  CredentialGenerator._();

  static const _upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; // no I, O
  static const _lower = 'abcdefghjkmnpqrstuvwxyz'; // no i, l, o
  static const _digits = '23456789'; // no 0, 1
  static const _symbols = '@#!%&*';

  static String generateUsername({int length = 8}) {
    final rng = Random.secure();
    final pool = _lower + _digits;
    final suffix = List.generate(length, (_) => pool[rng.nextInt(pool.length)]).join();
    return 'alw_$suffix';
  }

  static String generatePassword({int length = 12}) {
    final rng = Random.secure();
    // Ensure at least one of each character class
    final chars = [
      _upper[rng.nextInt(_upper.length)],
      _lower[rng.nextInt(_lower.length)],
      _digits[rng.nextInt(_digits.length)],
      _symbols[rng.nextInt(_symbols.length)],
      ...List.generate(
        length - 4,
        (_) {
          final pool = _upper + _lower + _digits + _symbols;
          return pool[rng.nextInt(pool.length)];
        },
      ),
    ]..shuffle(rng);
    return chars.join();
  }
}