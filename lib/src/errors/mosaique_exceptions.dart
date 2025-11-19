/// Custom exceptions for Mosaique
library;

/// Base exception class for all Mosaique errors
abstract class MosaiqueException implements Exception {
  /// Error message
  final String message;

  /// Optional context information
  final Map<String, dynamic>? context;

  /// Creates a new [MosaiqueException]
  const MosaiqueException(this.message, {this.context});

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: $message');
    if (context != null && context!.isNotEmpty) {
      buffer.write('\nContext: $context');
    }
    return buffer.toString();
  }
}

/// Exception thrown when a shell layout reference is invalid
class InvalidShellLayoutException extends MosaiqueException {
  /// The invalid shell layout ID
  final String shellLayoutId;

  /// The route pattern that referenced the invalid shell layout
  final String? routePattern;

  /// Creates a new [InvalidShellLayoutException]
  InvalidShellLayoutException(this.shellLayoutId, {this.routePattern})
    : super('Shell layout "$shellLayoutId" not found', context: {'shellLayoutId': shellLayoutId, if (routePattern != null) 'routePattern': routePattern});
}

/// Exception thrown when circular nesting is detected
class CircularNestingException extends MosaiqueException {
  /// The chain of shell layout IDs that form the circular reference
  final List<String> nestingChain;

  /// Creates a new [CircularNestingException]
  CircularNestingException(this.nestingChain)
    : super('Circular nesting detected: ${nestingChain.join(" -> ")} -> ${nestingChain.first}', context: {'nestingChain': nestingChain});
}

/// Exception thrown when required parameters are missing
class MissingParametersException extends MosaiqueException {
  /// The missing parameter names
  final List<String> missingParameters;

  /// The context where parameters were expected
  final String? contextDescription;

  /// Creates a new [MissingParametersException]
  MissingParametersException(this.missingParameters, {this.contextDescription})
    : super(
        'Missing required parameters: ${missingParameters.join(", ")}',
        context: {'missingParameters': missingParameters, if (contextDescription != null) 'context': contextDescription},
      );
}

/// Exception thrown when no route matches the current context
class RouteMatchFailureException extends MosaiqueException {
  /// The path that failed to match
  final String path;

  /// The number of routes that were checked
  final int routeCount;

  /// Creates a new [RouteMatchFailureException]
  RouteMatchFailureException(this.path, {this.routeCount = 0}) : super('No route matched path "$path"', context: {'path': path, 'routeCount': routeCount});
}

/// Exception thrown when a widget builder throws an exception
class WidgetBuilderException extends MosaiqueException {
  /// The region key where the error occurred
  final String regionKey;

  /// The original exception that was thrown
  final Object originalException;

  /// The stack trace of the original exception
  final StackTrace? stackTrace;

  /// Creates a new [WidgetBuilderException]
  WidgetBuilderException(this.regionKey, this.originalException, {this.stackTrace})
    : super(
        'Widget builder for region "$regionKey" threw an exception: $originalException',
        context: {'regionKey': regionKey, 'originalException': originalException.toString(), if (stackTrace != null) 'stackTrace': stackTrace.toString()},
      );
}

/// Exception thrown when validation fails
class ValidationException extends MosaiqueException {
  /// The validation errors
  final List<String> errors;

  /// Creates a new [ValidationException]
  ValidationException(this.errors)
    : super('Validation failed with ${errors.length} error(s):\n${errors.map((e) => "  - $e").join("\n")}', context: {'errors': errors});
}
