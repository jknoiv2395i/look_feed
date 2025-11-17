class NetworkException implements Exception {
  NetworkException([this.message = 'Network error']);

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class AuthenticationException implements Exception {
  AuthenticationException([this.message = 'Authentication error']);

  final String message;

  @override
  String toString() => 'AuthenticationException: $message';
}

class ValidationException implements Exception {
  ValidationException([this.message = 'Validation error']);

  final String message;

  @override
  String toString() => 'ValidationException: $message';
}

class InsufficientCreditsException implements Exception {
  InsufficientCreditsException([this.message = 'Not enough credits']);

  final String message;

  @override
  String toString() => 'InsufficientCreditsException: $message';
}

class RateLimitException implements Exception {
  RateLimitException([this.message = 'Rate limit exceeded']);

  final String message;

  @override
  String toString() => 'RateLimitException: $message';
}
