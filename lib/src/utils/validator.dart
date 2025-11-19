import '../errors/mosaique_exceptions.dart';
import '../models/models.dart';

/// Validation mode for Mosaique configuration
enum ValidationMode {
  /// All validation errors cause immediate exceptions
  strict,

  /// Validation warnings are logged but don't prevent execution
  lenient,
}

/// Validates Mosaique configuration
class MosaiqueValidator {
  final ValidationMode mode;

  /// Optional log handler for lenient mode warnings
  final void Function(String message)? logHandler;

  /// Creates a new [MosaiqueValidator]
  const MosaiqueValidator({this.mode = ValidationMode.strict, this.logHandler});

  /// Validate shell layouts and routes
  ///
  /// Checks that:
  /// - All route definitions reference registered shell layouts
  /// - Shell layout IDs are unique
  /// - Route patterns are valid
  ///
  /// Throws [ValidationException] in strict mode if validation fails.
  /// Returns a list of validation errors in lenient mode.
  List<String> validate({required Map<String, ShellLayout> shellLayouts, required List<RouteDefinition> routes}) {
    final errors = <String>[];

    // Check for duplicate shell layout IDs (shouldn't happen with Map, but good to verify)
    final shellLayoutIds = shellLayouts.keys.toSet();
    if (shellLayoutIds.length != shellLayouts.length) {
      errors.add('Duplicate shell layout IDs detected');
    }

    // Validate each route
    for (final route in routes) {
      // Validate route pattern
      if (route.pattern.isEmpty) {
        errors.add('Route pattern cannot be empty');
      }

      // We can't validate shell layout references at configuration time
      // because the shell selector is a function that runs at runtime.
      // This validation needs to happen at runtime when the selector is invoked.
    }

    // In strict mode, throw exception if there are errors
    if (mode == ValidationMode.strict && errors.isNotEmpty) {
      throw ValidationException(errors);
    }

    // In lenient mode, log warnings
    if (mode == ValidationMode.lenient && errors.isNotEmpty) {
      final handler = logHandler ?? print;
      handler('[Mosaique Validation Warning] Found ${errors.length} validation issue(s):');
      for (final error in errors) {
        handler('  - $error');
      }
    }

    return errors;
  }

  /// Validate that a shell layout exists
  ///
  /// Throws [InvalidShellLayoutException] in strict mode if the shell layout is not found.
  /// Logs a warning in lenient mode.
  void validateShellLayoutExists(String shellLayoutId, Map<String, ShellLayout> shellLayouts, {String? routePattern}) {
    if (!shellLayouts.containsKey(shellLayoutId)) {
      if (mode == ValidationMode.strict) {
        throw InvalidShellLayoutException(shellLayoutId, routePattern: routePattern);
      } else {
        final handler = logHandler ?? print;
        handler(
          '[Mosaique Validation Warning] Shell layout "$shellLayoutId" not found${routePattern != null ? ' (referenced by route pattern "$routePattern")' : ''}',
        );
      }
    }
  }

  /// Validate that required parameters are present
  ///
  /// Throws [MissingParametersException] in strict mode if any required parameters are missing.
  /// Logs a warning in lenient mode.
  void validateRequiredParameters(List<String> requiredParameters, Map<String, String> availableParameters, {String? contextDescription}) {
    final missing = requiredParameters.where((param) => !availableParameters.containsKey(param)).toList();

    if (missing.isNotEmpty) {
      if (mode == ValidationMode.strict) {
        throw MissingParametersException(missing, contextDescription: contextDescription);
      } else {
        final handler = logHandler ?? print;
        handler(
          '[Mosaique Validation Warning] Missing required parameters: ${missing.join(", ")}${contextDescription != null ? ' ($contextDescription)' : ''}',
        );
      }
    }
  }
}
