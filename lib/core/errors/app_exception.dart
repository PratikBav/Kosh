/// Base exception class for the Kosh application.
///
/// All custom exceptions extend this class for consistent error handling.
class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException($code): $message';

  factory AppException.from(dynamic exception) {
    if (exception is AppException) return exception;
    return AppException(message: exception.toString());
  }
}

/// Thrown when a database operation fails.
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code = 'DATABASE_ERROR',
    super.stackTrace,
  });
}

/// Thrown when user input validation fails.
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.stackTrace,
  });
}

/// Thrown when a required resource is not found.
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code = 'NOT_FOUND',
    super.stackTrace,
  });
}

/// Thrown when a storage operation fails.
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code = 'STORAGE_ERROR',
    super.stackTrace,
  });
}

/// Thrown when authentication fails.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = 'AUTH_ERROR',
    super.stackTrace,
  });
}
