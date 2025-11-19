import 'package:flutter/foundation.dart';
import 'type_aliases.dart';
import 'view_injection_rule.dart';

/// Defines a route with shell and view selection rules
@immutable
class RouteDefinition {
  /// Route pattern that this definition matches
  ///
  /// Supports:
  /// - Static segments: `/users/profile`
  /// - Path parameters: `/users/:userId/posts/:postId`
  /// - Wildcard: `/docs/*`
  /// - Optional segments: `/users/:userId?`
  final String pattern;

  /// Function that determines which shell layout to use for this route
  final ShellLayoutSelector shellSelector;

  /// List of view injection rules for this route
  final List<ViewInjectionRule> viewRules;

  /// Creates a new [RouteDefinition]
  const RouteDefinition({required this.pattern, required this.shellSelector, required this.viewRules});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteDefinition && other.pattern == pattern && other.shellSelector == shellSelector && listEquals(other.viewRules, viewRules);
  }

  @override
  int get hashCode {
    return Object.hash(pattern, shellSelector, Object.hashAll(viewRules));
  }

  @override
  String toString() {
    return 'RouteDefinition(pattern: $pattern, viewRules: ${viewRules.length})';
  }
}
