import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosaique/src/mosaique_shell_route_data.dart';
import 'package:mosaique/src/mosaique_view_route.dart';

/// A route that defines a shell layout with named regions.
///
/// This extends [ShellRoute] to provide region-based view composition.
/// Shell routes create a persistent layout structure where different views
/// can be injected into named regions based on navigation.
class MosaiqueShellRoute extends ShellRoute {
  /// The list of region names this shell defines.
  final List<String> regions;

  /// A map of region names to builders for regions that always show the same content.
  final Map<String, WidgetBuilder> fixedRegions;

  /// The target region in the parent shell where this shell should be injected.
  final String? region;

  /// The builder that creates the shell widget.
  final WidgetBuilder shellBuilder;

  /// The child routes.
  final List<RouteBase> childRoutes;

  /// Creates a shell route with named regions.
  MosaiqueShellRoute({
    required this.shellBuilder,
    required this.regions,
    this.fixedRegions = const {},
    this.region,
    super.routes = const [],
  }) : childRoutes = routes,
       super(
         builder: _createBuilder(shellBuilder, regions, fixedRegions, routes),
       );

  /// Creates the builder function for the ShellRoute.
  static ShellRouteBuilder _createBuilder(
    WidgetBuilder shellBuilder,
    List<String> regions,
    Map<String, WidgetBuilder> fixedRegions,
    List<RouteBase> routes,
  ) {
    return (BuildContext context, GoRouterState state, Widget child) {
      // The 'child' parameter is go_router's navigator with page transitions
      // We need to figure out which region(s) should display content

      // Find ALL active routes and their target regions
      final activeRoutes = <ActiveRouteData>[];
      bool childAssigned = false;

      for (final route in routes) {
        if (route is MosaiqueViewRoute) {
          if (_isViewRouteActive(state, route)) {
            // First matching route gets the go_router navigator (with animations)
            if (!childAssigned) {
              activeRoutes.add(
                ActiveRouteData(
                  targetRegion: route.region,
                  builder: (ctx) => child,
                ),
              );
              childAssigned = true;
            } else {
              // Additional matching routes get their builder called directly
              final builder = route.builder!;
              activeRoutes.add(
                ActiveRouteData(
                  targetRegion: route.region,
                  builder: (ctx) => builder(ctx, state),
                ),
              );
            }
          }
        } else if (route is MosaiqueShellRoute && route.region != null) {
          if (_isShellRouteActive(state, route)) {
            if (!childAssigned) {
              activeRoutes.add(
                ActiveRouteData(
                  targetRegion: route.region!,
                  builder: (ctx) => child,
                ),
              );
              childAssigned = true;
            }
          }
        }
      }

      // Provide the shell data to descendant Region widgets
      return MosaiqueShellRouteData(
        regions: regions,
        fixedRegions: fixedRegions,
        activeRoutes: activeRoutes,
        child: shellBuilder(context),
      );
    };
  }

  /// Checks if a view route is currently active.
  static bool _isViewRouteActive(GoRouterState state, MosaiqueViewRoute route) {
    final location = state.matchedLocation;
    final path = route.path;

    // Handle absolute paths
    if (path.startsWith('/')) {
      return location == path || _matchesWithParams(location, path);
    }

    // Handle relative paths
    return location.endsWith('/$path') ||
        location.endsWith(path) ||
        _matchesWithParams(location, path);
  }

  /// Checks if a shell route is currently active.
  static bool _isShellRouteActive(
    GoRouterState state,
    MosaiqueShellRoute route,
  ) {
    // For now, check if any of the shell's child routes are active
    // This is a simplification
    return true;
  }

  /// Matches paths with parameters like :id.
  static bool _matchesWithParams(String location, String pattern) {
    final locationSegments = location
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();
    final patternSegments = pattern
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();

    if (locationSegments.length != patternSegments.length) {
      return false;
    }

    for (var i = 0; i < patternSegments.length; i++) {
      final patternSeg = patternSegments[i];
      final locationSeg = locationSegments[i];

      // If pattern segment starts with :, it's a parameter - matches anything
      if (patternSeg.startsWith(':')) {
        continue;
      }

      // Otherwise must match exactly
      if (patternSeg != locationSeg) {
        return false;
      }
    }

    return true;
  }
}
