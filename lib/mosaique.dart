/// A declarative, route-driven region-based view composition package for Flutter.
///
/// Mosaique allows you to define shell layouts with named regions that can be filled
/// with different views based on navigation. It integrates seamlessly with go_router.
///
/// ## Example
///
/// ```dart
/// final router = GoRouter(
///   routes: [
///     MosaiqueShellRoute(
///       shellBuilder: (context) => const MainShell(),
///       regions: const ['header', 'menu', 'content'],
///       fixedRegions: {
///         'header': (context) => const HeaderView(),
///         'menu': (context) => const MainMenuView(),
///       },
///       routes: [
///         MosaiqueViewRoute(
///           path: 'dashboard',
///           region: 'content',
///           builder: (context, state) => const DashboardView(),
///         ),
///       ],
///     ),
///   ],
/// );
/// ```
library;

export 'src/region.dart';
export 'src/mosaique_shell_route.dart';
export 'src/mosaique_view_route.dart';

// Note: mosaique_shell_route_data.dart is internal and not exported
