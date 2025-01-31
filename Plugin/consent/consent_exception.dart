class ConsentException implements Exception {
  final String message;
  final String? field;
  final String? process;
  final String? errorCode;
  final StackTrace? stackTrace;

  // Constructor allowing additional context
  ConsentException(
    this.message, {
    this.field,
    this.process,
    this.errorCode,
    this.stackTrace,
  });

  @override
  String toString() {
    // Return a detailed string representation of the error
    return 'ConsentException: $message${field != null ? ' [Field: $field]' : ''}${process != null ? ' [Process: $process]' : ''}${errorCode != null ? ' [ErrorCode: $errorCode]' : ''}${stackTrace != null ? '\nStackTrace: $stackTrace' : ''}';
  }

  // Optional: Method to serialize the exception to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'field': field,
      'process': process,
      'errorCode': errorCode,
      'stackTrace': stackTrace?.toString(),
    };
  }
}
