import '../models/route_context.dart';
import '../models/route_definition.dart';
import '../utils/debug_config.dart';

/// Handles route pattern matching and parameter extraction
class RouteMatcher {
  /// Debug configuration for logging
  final MosaiqueDebugConfig? debugConfig;

  /// Creates a new [RouteMatcher]
  const RouteMatcher({this.debugConfig});

  /// Find the best matching route for the given context
  ///
  /// Returns the route with the highest specificity score that matches
  /// the given path. Returns null if no routes match.
  RouteDefinition? match(List<RouteDefinition> routes, RouteContext context) {
    debugConfig?.logRouteMatch('Matching route for path: ${context.path}');
    debugConfig?.logRouteMatch('Checking ${routes.length} route(s)');

    RouteDefinition? bestMatch;
    int bestSpecificity = -1;
    int matchCount = 0;

    for (final route in routes) {
      if (_matches(route.pattern, context.path)) {
        matchCount++;
        final specificity = calculateSpecificity(route.pattern, context.path);
        debugConfig?.logRouteMatch('  ✓ Pattern "${route.pattern}" matches (specificity: $specificity)');

        if (specificity > bestSpecificity) {
          bestSpecificity = specificity;
          bestMatch = route;
        }
      } else {
        debugConfig?.logRouteMatch('  ✗ Pattern "${route.pattern}" does not match');
      }
    }

    if (bestMatch != null) {
      debugConfig?.logRouteMatch('Selected route: "${bestMatch.pattern}" (specificity: $bestSpecificity, $matchCount match(es) found)');
    } else {
      debugConfig?.logRouteMatch('No matching route found for path: ${context.path}');
    }

    return bestMatch;
  }

  /// Calculate specificity score for a route pattern
  ///
  /// Higher scores indicate more specific patterns.
  /// Scoring rules:
  /// - Static segments: 100 points each
  /// - Path parameters: 10 points each
  /// - Optional parameters: 5 points each
  /// - Wildcards: 1 point
  int calculateSpecificity(String pattern, String path) {
    final segments = _parsePattern(pattern);
    int score = 0;

    for (final segment in segments) {
      if (segment.type == _SegmentType.static_) {
        score += 100;
      } else if (segment.type == _SegmentType.parameter) {
        score += segment.isOptional ? 5 : 10;
      } else if (segment.type == _SegmentType.wildcard) {
        score += 1;
      }
    }

    return score;
  }

  /// Extract path parameters from URL based on pattern
  ///
  /// Returns a map where keys are parameter names from the pattern
  /// and values are the corresponding segments from the path.
  /// Returns an empty map if the pattern does not match the path.
  Map<String, String> extractPathParameters(String pattern, String path) {
    // First check if the pattern matches
    if (!_matches(pattern, path)) {
      debugConfig?.logRouteMatch('Cannot extract parameters: pattern "$pattern" does not match path "$path"');
      return {};
    }

    final parameters = <String, String>{};
    final patternSegments = _parsePattern(pattern);
    final pathSegments = _splitPath(path);

    int pathIndex = 0;

    for (int i = 0; i < patternSegments.length; i++) {
      final segment = patternSegments[i];

      if (segment.type == _SegmentType.static_) {
        // Static segment, just advance
        pathIndex++;
      } else if (segment.type == _SegmentType.parameter) {
        if (pathIndex < pathSegments.length) {
          parameters[segment.name] = pathSegments[pathIndex];
          pathIndex++;
        } else if (!segment.isOptional) {
          // Required parameter missing
          return {};
        }
      } else if (segment.type == _SegmentType.wildcard) {
        // Wildcard consumes remaining path
        if (pathIndex < pathSegments.length) {
          parameters['*'] = pathSegments.sublist(pathIndex).join('/');
        }
        break;
      }
    }

    if (parameters.isNotEmpty) {
      debugConfig?.logRouteMatch('Extracted path parameters: $parameters');
    }

    return parameters;
  }

  /// Check if a pattern matches a path
  bool _matches(String pattern, String path) {
    final patternSegments = _parsePattern(pattern);
    final pathSegments = _splitPath(path);

    int pathIndex = 0;

    for (int i = 0; i < patternSegments.length; i++) {
      final segment = patternSegments[i];

      if (segment.type == _SegmentType.static_) {
        if (pathIndex >= pathSegments.length || pathSegments[pathIndex] != segment.name) {
          return false;
        }
        pathIndex++;
      } else if (segment.type == _SegmentType.parameter) {
        if (pathIndex < pathSegments.length) {
          pathIndex++;
        } else if (!segment.isOptional) {
          // Required parameter missing
          return false;
        }
      } else if (segment.type == _SegmentType.wildcard) {
        // Wildcard matches everything remaining
        return true;
      }
    }

    // All segments must be consumed
    return pathIndex == pathSegments.length;
  }

  /// Parse a route pattern into segments
  List<_PatternSegment> _parsePattern(String pattern) {
    final segments = <_PatternSegment>[];
    final parts = _splitPath(pattern);

    for (final part in parts) {
      if (part == '*') {
        segments.add(_PatternSegment(type: _SegmentType.wildcard, name: '*', isOptional: false));
      } else if (part.startsWith(':')) {
        final isOptional = part.endsWith('?');
        final name = isOptional ? part.substring(1, part.length - 1) : part.substring(1);
        segments.add(_PatternSegment(type: _SegmentType.parameter, name: name, isOptional: isOptional));
      } else {
        segments.add(_PatternSegment(type: _SegmentType.static_, name: part, isOptional: false));
      }
    }

    return segments;
  }

  /// Split a path into segments, removing empty segments
  List<String> _splitPath(String path) {
    return path.split('/').where((s) => s.isNotEmpty).toList();
  }
}

/// Type of pattern segment
enum _SegmentType { static_, parameter, wildcard }

/// Represents a parsed segment of a route pattern
class _PatternSegment {
  final _SegmentType type;
  final String name;
  final bool isOptional;

  _PatternSegment({required this.type, required this.name, required this.isOptional});
}
