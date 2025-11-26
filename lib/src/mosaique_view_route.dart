import 'package:go_router/go_router.dart';

/// A route that injects a view widget into a specific region of the parent shell.
///
/// View routes are children of [MosaiqueShellRoute] and specify which region
/// their content should be displayed in.
///
/// Example:
/// ```dart
/// MosaiqueViewRoute(
///   path: 'dashboard',
///   region: 'content',
///   builder: (context) => const DashboardView(),
/// )
/// ```
class MosaiqueViewRoute extends GoRoute {
  /// The target region in the parent shell where this view should be injected.
  final String region;

  /// Creates a view route that injects content into a specific region.
  ///
  /// The [path], [region], and [builder] parameters are required.
  /// The [builder] should return the widget to display in the target region.
  MosaiqueViewRoute({
    required super.path,
    required this.region,
    required GoRouterWidgetBuilder builder,
  }) : super(
          builder: builder,
        );
}
