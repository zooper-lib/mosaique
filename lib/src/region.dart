import 'package:flutter/material.dart';
import 'package:mosaique/src/mosaique_shell_route_data.dart';

/// A placeholder widget that gets replaced with actual content based on the current route.
///
/// Region widgets are used inside shell layouts to mark areas where content should be injected.
/// The content is determined by the current route's [MosaiqueViewRoute] or [MosaiqueShellRoute]
/// configuration.
///
/// Example:
/// ```dart
/// class MainShell extends StatelessWidget {
///   const MainShell({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return Row(
///       children: [
///         SizedBox(width: 250, child: Region('menu')),
///         Expanded(child: Region('content')),
///       ],
///     );
///   }
/// }
/// ```
class Region extends StatelessWidget {
  /// The name of this region. Must match the region names defined in [MosaiqueShellRoute].
  final String name;

  /// Creates a region placeholder widget.
  ///
  /// The [name] parameter identifies this region and must match one of the regions
  /// declared in the parent [MosaiqueShellRoute].
  const Region(
    this.name, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final data = MosaiqueShellRouteData.of(context);
    final content = data.getContentForRegion(name, context);

    // No custom animation - just render the content directly
    // go_router handles page transition animations
    return content ?? const SizedBox.shrink();
  }
}
