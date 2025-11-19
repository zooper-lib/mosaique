import 'package:flutter/widgets.dart';
import '../models/route_context.dart';
import '../utils/circular_nesting_detector.dart';

/// InheritedWidget for accessing route context and navigation throughout the widget tree.
///
/// [MosaiqueScope] provides access to the current [RouteContext] to all descendant widgets
/// without requiring prop drilling. It automatically notifies dependents when the route
/// context changes.
///
/// Example usage:
/// ```dart
/// // Access route context
/// final context = MosaiqueScope.of(context).routeContext;
///
/// // Or use the extension
/// final path = context.routeContext.path;
/// ```
class MosaiqueScope extends InheritedWidget {
  /// The current route context
  final RouteContext routeContext;

  /// The circular nesting detector shared across nested shells
  final CircularNestingDetector? nestingDetector;

  /// Creates a [MosaiqueScope] widget
  const MosaiqueScope({required this.routeContext, required super.child, this.nestingDetector, super.key});

  /// Returns the nearest [MosaiqueScope] ancestor, or null if none exists.
  ///
  /// This method does not create a dependency, so the calling widget will not
  /// rebuild when the [MosaiqueScope] changes.
  static MosaiqueScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MosaiqueScope>();
  }

  /// Returns the nearest [MosaiqueScope] ancestor.
  ///
  /// Throws an assertion error if no [MosaiqueScope] is found in the widget tree.
  /// This method creates a dependency, so the calling widget will rebuild when
  /// the [MosaiqueScope]'s route context changes.
  static MosaiqueScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(
      scope != null,
      'No MosaiqueScope found in context. '
      'Make sure your widget is wrapped with a MosaiqueScope.',
    );
    return scope!;
  }

  @override
  bool updateShouldNotify(MosaiqueScope oldWidget) {
    // Notify dependents when the route context changes
    return routeContext != oldWidget.routeContext;
  }
}

/// Extension on [BuildContext] for convenient access to [MosaiqueScope] data.
///
/// This extension provides a more ergonomic way to access the route context
/// from any [BuildContext].
///
/// Example:
/// ```dart
/// final path = context.routeContext.path;
/// final userId = context.routeContext.pathParameters['userId'];
/// ```
extension MosaiqueContextExtension on BuildContext {
  /// Returns the current [RouteContext] from the nearest [MosaiqueScope].
  ///
  /// Throws an assertion error if no [MosaiqueScope] is found in the widget tree.
  RouteContext get routeContext => MosaiqueScope.of(this).routeContext;

  /// Returns the current [RouteContext] from the nearest [MosaiqueScope],
  /// or null if none exists.
  RouteContext? get routeContextOrNull => MosaiqueScope.maybeOf(this)?.routeContext;

  /// Returns the circular nesting detector from the nearest [MosaiqueScope],
  /// or null if none exists.
  CircularNestingDetector? get nestingDetector => MosaiqueScope.maybeOf(this)?.nestingDetector;
}
