// lib/core/error/exception_mapper.dart
// WHY: Centralizes the translation of platform / Firebase exceptions into
//      our typed [Failure] hierarchy. Every repository wraps its try/catch
//      around the same `mapException(e)` call so error semantics are
//      consistent everywhere — no more silent `catch (_) {}`.

import 'package:cloud_firestore/cloud_firestore.dart';

import '../error/app_exception.dart';
import '../error/failure.dart';
import '../utils/result.dart';

/// Pure function — same input always produces the same [Failure]. Easy to
/// unit-test without mocking Firestore.
Failure mapExceptionToFailure(Object e, {String? fallbackMessage}) {
  // Already-typed failures just unwrap.
  if (e is AppException) {
    return _fromAppException(e);
  }

  // Firebase-specific codes surface as readable failures for the UI.
  if (e is FirebaseException) {
    return _fromFirebaseException(e, fallbackMessage);
  }

  // Defensive defaults so the UI never shows raw stack text.
  return ServerFailure(fallbackMessage ?? e.toString());
}

Failure _fromAppException(AppException e) {
  if (e is PermissionDeniedException) return PermissionFailure(e.message);
  if (e is SessionExpiredException) return SessionExpiredFailure(e.message);
  if (e is UserDeactivatedException) return AuthFailure(e.message);
  if (e is AuthException) return AuthFailure(e.message);
  if (e is NetworkException) return NetworkFailure(e.message);
  if (e is NotFoundException) return NotFoundFailure(e.message);
  if (e is ValidationException) {
    return ValidationFailure(e.message, fieldErrors: e.fieldErrors);
  }
  if (e is UnpaidAttendeeException) return UnpaidAttendeeFailure(e.message);
  return ServerFailure(e.message);
}

Failure _fromFirebaseException(FirebaseException e, String? fallback) {
  final message = e.message?.isNotEmpty == true ? e.message! : (fallback ?? e.code);

  switch (e.code) {
    case 'permission-denied':
      return PermissionFailure(message);
    case 'unauthenticated':
      return AuthFailure(message);
    case 'not-found':
      return NotFoundFailure(message);
    case 'already-exists':
      return ValidationFailure(message);
    case 'invalid-argument':
      return ValidationFailure(message);
    case 'unavailable':
    case 'deadline-exceeded':
      return NetworkFailure(message);
    case 'resource-exhausted':
      return ServerFailure('Quota exceeded: $message');
    default:
      return ServerFailure(message);
  }
}

FailureResult<T> failureOf<T>(Object e, {String? fallbackMessage}) {
  return FailureResult<T>(mapExceptionToFailure(e, fallbackMessage: fallbackMessage));
}
