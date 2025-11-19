import 'package:flutter/foundation.dart';

/// Immutable representation of current navigation state
@immutable
class RouteContext {
  /// The current URL path
  final String path;

  /// Path parameters extracted from the URL pattern
  final Map<String, String> pathParameters;

  /// Query parameters from the URL
  final Map<String, String> queryParameters;

  /// Additional navigation state data
  final Map<String, dynamic> extra;

  /// Creates a new [RouteContext]
  const RouteContext({required this.path, this.pathParameters = const {}, this.queryParameters = const {}, this.extra = const {}});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteContext &&
        other.path == path &&
        mapEquals(other.pathParameters, pathParameters) &&
        mapEquals(other.queryParameters, queryParameters) &&
        mapEquals(other.extra, extra);
  }

  @override
  int get hashCode {
    return Object.hash(
      path,
      Object.hashAll(pathParameters.entries.map((e) => Object.hash(e.key, e.value))),
      Object.hashAll(queryParameters.entries.map((e) => Object.hash(e.key, e.value))),
      Object.hashAll(extra.entries.map((e) => Object.hash(e.key, e.value))),
    );
  }

  @override
  String toString() {
    return 'RouteContext(path: $path, pathParameters: $pathParameters, '
        'queryParameters: $queryParameters, extra: $extra)';
  }

  /// Creates a copy of this [RouteContext] with the given fields replaced
  RouteContext copyWith({String? path, Map<String, String>? pathParameters, Map<String, String>? queryParameters, Map<String, dynamic>? extra}) {
    return RouteContext(
      path: path ?? this.path,
      pathParameters: pathParameters ?? this.pathParameters,
      queryParameters: queryParameters ?? this.queryParameters,
      extra: extra ?? this.extra,
    );
  }
}
