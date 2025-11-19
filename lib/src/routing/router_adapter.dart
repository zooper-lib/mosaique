import '../models/route_context.dart';

/// Abstract interface for router adapters that integrate Mosaique with
/// different routing libraries.
///
/// Router adapters are responsible for:
/// - Translating routing library events into [RouteContext] updates
/// - Extracting route parameters (both path and query) from the routing library
/// - Providing navigation methods that delegate to the underlying router
///
/// This abstraction allows Mosaique to work with different routing solutions
/// (go_router, custom routers, etc.) without depending on specific implementations.
abstract class MosaiqueRouterAdapter {
  /// Get the current route context from the underlying routing library.
  ///
  /// This method should extract:
  /// - The current URL path
  /// - Path parameters from the routing library's state
  /// - Query parameters from the routing library's state
  /// - Any additional navigation state
  ///
  /// Returns a [RouteContext] representing the current navigation state.
  RouteContext getCurrentContext();

  /// Stream of route context changes.
  ///
  /// This stream should emit a new [RouteContext] whenever the underlying
  /// routing library's navigation state changes. This includes:
  /// - URL changes
  /// - Programmatic navigation
  /// - Browser back/forward navigation
  /// - Deep link activation
  ///
  /// Mosaique listens to this stream to trigger shell layout and view resolution.
  Stream<RouteContext> get onRouteChanged;

  /// Navigate to a new route.
  ///
  /// The [path] parameter specifies the target URL path.
  ///
  /// Optional [pathParameters] can be provided to fill in path parameter
  /// placeholders in the route pattern.
  ///
  /// Optional [queryParameters] can be provided to append query parameters
  /// to the URL.
  ///
  /// The implementation should delegate to the underlying routing library's
  /// navigation method (e.g., GoRouter.go(), Navigator.pushNamed(), etc.).
  void navigate(String path, {Map<String, String>? pathParameters, Map<String, String>? queryParameters});

  /// Navigate back to the previous route.
  ///
  /// The implementation should delegate to the underlying routing library's
  /// back navigation method (e.g., GoRouter.pop(), Navigator.pop(), etc.).
  ///
  /// If there is no previous route in the navigation stack, the behavior
  /// depends on the underlying routing library.
  void goBack();
}
