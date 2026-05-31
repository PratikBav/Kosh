/// Typed failure classes for error handling.
///
/// Failures represent errors that the UI layer can understand
/// and present to the user. Each has a user-friendly [message].
sealed class Failure {
  const Failure(this.message);
  final String message;
}

/// A failure originating from database operations.
class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'A database error occurred']);
}

/// A failure originating from input validation.
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input']);
}

/// A failure when a requested resource is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

/// A failure originating from storage operations.
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'A storage error occurred']);
}

/// A failure originating from authentication.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

/// A generic unexpected failure.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred']);
}
