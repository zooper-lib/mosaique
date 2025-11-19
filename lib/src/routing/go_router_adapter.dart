import 'dart:async';

import 'package:go_router/go_router.dart';

import '../models/route_context.dart';
import 'router_adapter.dart';

/// Adapter that integrates Mosaique with the go_router package.
///
/// This adapter translates go_router's navigation state into Mosaique's
/// [RouteContext] format, enabling Mosaique to work seamlessly with go_router.
///
/// The adapter extracts:
/// - Path from [GoRouterState.matchedLocation]
/// - Path parameters from [GoRouterState.pathParameters]
/// - Query parameters from [GoRouterState.uri.queryParameters]
/// - Extra data from [GoRouterState.extra]
///
/// Example usage:
/// ```dart
/// final goRouter = GoRouter(routes: [...]);
/// final adapter = GoRouterAdapter(goRouter);
/// final mosaiqueScope = MosaiqueScope(
///   routeContext: adapter.getCurrentContext(),
///   router: adapter,
///   child: MosaiqueShellBuilder(...),
/// );
/// ```
class GoRouterAdapter implements MosaiqueRouterAdapter {
  /// The underlying go_router instance
  final GoRouter router;

  /// Stream controller for route changes
  final StreamController<RouteContext> _routeChangeController = StreamController<RouteContext>.broadcast();

  /// Creates a [GoRouterAdapter] that wraps the given [router].
  ///
  /// The adapter will listen to route changes from the router and emit
  /// corresponding [RouteContext] updates through [onRouteChanged].
  GoRouterAdapter(this.router) {
    // Listen to go_router's route information provider to detect changes
    router.routeInformationProvider.addListener(_onRouteChanged);
  }

  /// Handles route changes from go_router
  void _onRouteChanged() {
    final context = getCurrentContext();
    _routeChangeController.add(context);
  }

  @override
  RouteContext getCurrentContext() {
    // Get the current router state
    final routerState = router.routerDelegate.currentConfiguration;

    if (routerState.matches.isEmpty) {
      // Return a default context if no route is matched
      return const RouteContext(path: '/');
    }

    // Get the last match which represents the current route
    final lastMatch = routerState.matches.last;

    // Extract path from matchedLocation
    final path = lastMatch.matchedLocation;

    // Extract path parameters from the route match list
    final pathParameters = Map<String, String>.from(routerState.pathParameters);

    // Extract query parameters from the URI
    final queryParameters = Map<String, String>.from(routerState.uri.queryParameters);

    // Extract extra data if available from the route match list
    final extra = <String, dynamic>{};
    if (routerState.extra != null) {
      if (routerState.extra is Map) {
        extra.addAll(routerState.extra as Map<String, dynamic>);
      } else {
        extra['data'] = routerState.extra;
      }
    }

    return RouteContext(path: path, pathParameters: pathParameters, queryParameters: queryParameters, extra: extra);
  }

  @override
  Stream<RouteContext> get onRouteChanged => _routeChangeController.stream;

  @override
  void navigate(String path, {Map<String, String>? pathParameters, Map<String, String>? queryParameters}) {
    // Build the full path with query parameters if provided
    var fullPath = path;

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final queryString = queryParameters.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
      fullPath = '$path?$queryString';
    }

    // Use go_router's go method for navigation
    router.go(fullPath);
  }

  @override
  void goBack() {
    // Use go_router's pop method to navigate back
    router.pop();
  }

  /// Dispose of resources used by this adapter.
  ///
  /// This should be called when the adapter is no longer needed to prevent
  /// memory leaks.
  void dispose() {
    router.routeInformationProvider.removeListener(_onRouteChanged);
    _routeChangeController.close();
  }
}
