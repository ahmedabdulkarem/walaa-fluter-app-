// lib/core/auth/permission_checker.dart
// WHY: Central permission gate — super admin bypasses all, others checked against permissions list.

import '../../shared/models/user_schema.dart';

class PermissionChecker {
  final UserSchema currentUser;
  const PermissionChecker(this.currentUser);

  bool can(String permission) {
    if (currentUser.isSuperAdmin) return true;
    if (!currentUser.isActive) return false;
    if (currentUser.isSessionExpired) return false;
    return currentUser.permissions.contains(permission);
  }

  bool canAny(Iterable<String> permissions) {
    return permissions.any(can);
  }

  bool canAll(Iterable<String> permissions) {
    return permissions.every(can);
  }

  bool get isSuperAdmin => currentUser.isSuperAdmin;
  bool get isActive => currentUser.isActive;
}
