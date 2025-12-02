import 'package:flutter/material.dart';

/// Internal data structure representing an active route that targets a specific region.
class ActiveRouteData {
  /// The region this route targets.
  final String targetRegion;

  /// The builder function that creates the widget for this route.
  final WidgetBuilder builder;

  const ActiveRouteData({
    required this.targetRegion,
    required this.builder,
  });
}

/// An InheritedWidget that provides shell route data to descendant [Region] widgets.
///
/// This widget is created internally by [MosaiqueShellRoute] and should not be
/// used directly in user code.
class MosaiqueShellRouteData extends InheritedWidget {
  /// A map of region names to builders for regions that always show the same content.
  final Map<String, WidgetBuilder> fixedRegions;

  /// The list of active child routes that inject content into regions.
  final List<ActiveRouteData> activeRoutes;

  const MosaiqueShellRouteData({
    required this.fixedRegions,
    required this.activeRoutes,
    required super.child,
    super.key,
  });

  /// Finds the nearest [MosaiqueShellRouteData] in the widget tree.
  ///
  /// Throws an assertion error if no [MosaiqueShellRouteData] is found.
  static MosaiqueShellRouteData of(BuildContext context) {
    final data = context.dependOnInheritedWidgetOfExactType<MosaiqueShellRouteData>();
    assert(
      data != null,
      'No MosaiqueShellRouteData found in context. '
      'Make sure your Region widget is used inside a MosaiqueShellRoute.',
    );
    return data!;
  }

  /// Gets the content widget for a specific region.
  ///
  /// Resolution order:
  /// 1. Check if any active child route targets this region
  /// 2. Check if this region has a fixed widget defined
  /// 3. Return null (will render as SizedBox.shrink)
  Widget? getContentForRegion(String regionName, BuildContext context) {
    // 1. Check active child routes for this region
    for (final route in activeRoutes) {
      if (route.targetRegion == regionName) {
        return route.builder(context);
      }
    }

    // 2. Check fixed regions
    if (fixedRegions.containsKey(regionName)) {
      return fixedRegions[regionName]!(context);
    }

    // 3. Return null (Region will render SizedBox.shrink)
    return null;
  }

  @override
  bool updateShouldNotify(MosaiqueShellRouteData oldWidget) {
    // Rebuild if active routes change or fixed regions change
    return activeRoutes != oldWidget.activeRoutes ||
        fixedRegions != oldWidget.fixedRegions;
  }
}
