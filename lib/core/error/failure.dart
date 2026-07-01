// lib/core/error/failure.dart
// WHY: Sealed class for repository return types — enables pattern matching on success/failure.

sealed class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  const ValidationFailure(super.message, {this.fieldErrors});
}

class UnpaidAttendeeFailure extends Failure {
  const UnpaidAttendeeFailure(super.message);
}
