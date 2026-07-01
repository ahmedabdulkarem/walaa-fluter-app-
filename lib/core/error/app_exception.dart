// lib/core/error/app_exception.dart
// WHY: Typed exceptions for predictable error handling in repositories and controllers.

abstract class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});

  @override
  String toString() => '$runtimeType: $message${code != null ? ' ($code)' : ''}';
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException(super.message) : super(code: 'PERMISSION_DENIED');
}

class SessionExpiredException extends AppException {
  const SessionExpiredException(super.message) : super(code: 'SESSION_EXPIRED');
}

class UserDeactivatedException extends AppException {
  const UserDeactivatedException(super.message) : super(code: 'USER_DEACTIVATED');
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

class NotFoundException extends AppException {
  const NotFoundException(super.message) : super(code: 'NOT_FOUND');
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;
  const ValidationException(super.message, {this.fieldErrors}) : super(code: 'VALIDATION_ERROR');
}

class UnpaidAttendeeException extends AppException {
  const UnpaidAttendeeException(super.message) : super(code: 'UNPAID_ATTENDEE');
}

class FirestoreException extends AppException {
  const FirestoreException(super.message, {super.code});
}