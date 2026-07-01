// lib/core/utils/result.dart
// WHY: Either monad for repository returns — avoids null checks and provides typed error handling.

import '../error/failure.dart';

sealed class Result<T> {
  const Result();

  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess);

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;
  Failure? get failureOrNull =>
      this is FailureResult<T> ? (this as FailureResult<T>).failure : null;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess) {
    return onSuccess(data);
  }
}

class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);

  @override
  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess) {
    return onFailure(failure);
  }
}