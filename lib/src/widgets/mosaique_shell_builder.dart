import 'package:flutter/widgets.dart';
import '../models/models.dart';
import '../models/type_aliases.dart' as types;
import '../routing/route_matcher.dart';
import '../routing/view_resolver.dart';
import '../errors/mosaique_exceptions.dart';
import '../utils/circular_nesting_detector.dart';
import '../utils/debug_config.dart';
import '../utils/validator.dart';
import 'mosaique_scope.dart';

/// Widget that builds a shell layout with dynamically resolved views based on route context.
///
/// [MosaiqueShellBuilder] is the core widget that:
/// 1. Matches the current route context against registered route definitions
/// 2. Selects the appropriate shell layout
/// 3. Resolves views for each region based on view injection rules
/// 4. Builds the final widget tree
///
/// This widget automatically rebuilds when the route context changes, but only
/// rebuilds affected regions for optimal performance.
class MosaiqueShellBuilder extends StatefulWidget {
  /// The current route context
  final RouteContext context;

  /// Map of shell layout ID to shell layout definition
  final Map<String, ShellLayout> shellLayouts;

  /// List of route definitions to match against
  final List<RouteDefinition> routes;

  /// Optional default widget builders for regions
  final Map<String, types.WidgetBuilder> defaultBuilders;

  /// Optional widget to display when no route matches
  final Widget Function(RouteContext context)? notFoundBuilder;

  /// Optional custom error widget builder for region errors
  final Widget Function(String regionKey, Object error, StackTrace? stackTrace)? errorBuilder;

  /// Validation mode for configuration validation
  final ValidationMode validationMode;

  /// Circular nesting detector (shared across nested shells)
  final CircularNestingDetector? nestingDetector;

  /// Debug configuration for logging
  final MosaiqueDebugConfig? debugConfig;

  /// Creates a [MosaiqueShellBuilder]
  const MosaiqueShellBuilder({
    required this.context,
    required this.shellLayouts,
    required this.routes,
    this.defaultBuilders = const {},
    this.notFoundBuilder,
    this.errorBuilder,
    this.validationMode = ValidationMode.strict,
    this.nestingDetector,
    this.debugConfig,
    super.key,
  });

  @override
  State<MosaiqueShellBuilder> createState() => _MosaiqueShellBuilderState();
}

class _MosaiqueShellBuilderState extends State<MosaiqueShellBuilder> {
  late final RouteMatcher _routeMatcher;
  late final ViewResolver _viewResolver;
  late final MosaiqueValidator _validator;
  late CircularNestingDetector _nestingDetector;

  late RouteDefinition? _currentRoute;
  late ShellLayout? _currentShell;
  late Map<String, Widget> _resolvedViews;
  late RouteContext _enrichedContext;
  Object? _error;
  StackTrace? _errorStackTrace;

  @override
  void initState() {
    super.initState();
    _routeMatcher = RouteMatcher(debugConfig: widget.debugConfig);
    _viewResolver = ViewResolver(debugConfig: widget.debugConfig);
    _validator = MosaiqueValidator(mode: widget.validationMode, logHandler: widget.debugConfig?.logHandler);

    // Use provided nesting detector or create new one
    // We'll check for parent detector in didChangeDependencies
    _nestingDetector = widget.nestingDetector ?? CircularNestingDetector();

    widget.debugConfig?.log('Initializing MosaiqueShellBuilder', condition: true);
    widget.debugConfig?.log('Validation mode: ${widget.validationMode}', condition: true);

    // Validate configuration
    try {
      _validator.validate(shellLayouts: widget.shellLayouts, routes: widget.routes);
      widget.debugConfig?.log('Configuration validation passed', condition: true);
    } catch (e, stackTrace) {
      widget.debugConfig?.log('Configuration validation failed: $e', condition: true);
      _error = e;
      _errorStackTrace = stackTrace;
      return;
    }

    _resolveRoute();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // If no nesting detector was provided, try to get it from parent scope
    if (widget.nestingDetector == null) {
      final parentDetector = context.nestingDetector;
      if (parentDetector != null && parentDetector != _nestingDetector) {
        // Update to use parent detector
        // Exit from the old detector first
        if (_currentShell != null) {
          _nestingDetector.exit(_currentShell!.id);
        }

        // Switch to parent detector
        _nestingDetector = parentDetector;

        // Don't re-enter here - the parent detector already has the parent shell
        // Re-entering would cause circular nesting errors
        // The shell will be properly entered in _resolveRoute when needed
      }
    }
  }

  @override
  void didUpdateWidget(MosaiqueShellBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if route context changed
    if (widget.context != oldWidget.context) {
      widget.debugConfig?.logRebuild('Route context changed: ${oldWidget.context.path} → ${widget.context.path}');

      final oldShell = _currentShell;
      final oldViews = Map<String, Widget>.from(_resolvedViews);

      // Exit the old shell's nesting context before resolving the new route
      if (oldShell != null) {
        _nestingDetector.exit(oldShell.id);
      }

      _resolveRoute();

      // Determine what changed and optimize rebuilding
      final shellChanged = _currentShell?.id != oldShell?.id;

      if (shellChanged) {
        widget.debugConfig?.logRebuild('Shell layout changed: ${oldShell?.id} → ${_currentShell?.id}');
        widget.debugConfig?.logRebuild('Performing full rebuild');
        // Shell layout changed - full rebuild will happen automatically
        // No optimization needed, the entire widget tree will be rebuilt
        return;
      }

      // Shell layout is the same, check which regions changed
      if (!shellChanged && _currentShell != null) {
        widget.debugConfig?.logRebuild('Shell layout unchanged (${_currentShell!.id}), checking for region changes');
        // Perform selective rebuilding by only updating changed regions
        _performSelectiveRebuild(oldViews);
      }
    }
  }

  /// Resolves the current route, shell layout, and views
  void _resolveRoute() {
    try {
      widget.debugConfig?.log('=== Route Resolution Started ===', condition: true);

      // Match the route
      _currentRoute = _routeMatcher.match(widget.routes, widget.context);

      if (_currentRoute == null) {
        widget.debugConfig?.log('No matching route found', condition: true);
        // No matching route - allow not found widget to be shown
        _currentShell = null;
        _resolvedViews = {};
        _enrichedContext = widget.context;
        return;
      }

      // Extract path parameters and enrich the context
      final pathParameters = _routeMatcher.extractPathParameters(_currentRoute!.pattern, widget.context.path);

      _enrichedContext = widget.context.copyWith(pathParameters: {...widget.context.pathParameters, ...pathParameters});

      // Select shell layout
      final shellId = _currentRoute!.shellSelector(_enrichedContext);
      widget.debugConfig?.log('Shell selector returned: "$shellId"', condition: true);

      // Validate shell layout exists
      _validator.validateShellLayoutExists(shellId, widget.shellLayouts, routePattern: _currentRoute!.pattern);

      _currentShell = widget.shellLayouts[shellId];

      // Check for circular nesting
      if (_nestingDetector.contains(shellId)) {
        throw CircularNestingException([..._nestingDetector.chain, shellId]);
      }

      // Enter nesting context
      _nestingDetector.enter(shellId);
      widget.debugConfig?.log('Entered shell layout: "$shellId"', condition: true);

      // Resolve views for each region
      widget.debugConfig?.log('Resolving views for ${_currentRoute!.viewRules.length} rule(s)', condition: true);
      _resolvedViews = _resolveViews(_currentRoute!.viewRules, _enrichedContext);
      widget.debugConfig?.log('Resolved ${_resolvedViews.length} view(s)', condition: true);
      widget.debugConfig?.log('=== Route Resolution Complete ===', condition: true);

      // Clear any previous errors
      _error = null;
      _errorStackTrace = null;
    } catch (e, stackTrace) {
      widget.debugConfig?.log('Route resolution failed: $e', condition: true);
      // Capture error for display
      _error = e;
      _errorStackTrace = stackTrace;
      _currentShell = null;
      _resolvedViews = {};
    }
  }

  /// Performs selective rebuilding by only updating changed regions
  ///
  /// This method compares the old and new resolved views and only rebuilds
  /// regions that have actually changed, preserving the state of unchanged regions.
  void _performSelectiveRebuild(Map<String, Widget> oldViews) {
    final newViews = <String, Widget>{};
    final changedRegions = <String>[];
    final unchangedRegions = <String>[];
    final addedRegions = <String>[];
    final removedRegions = <String>[];

    // Get all region keys from both old and new views
    final allRegionKeys = <String>{...oldViews.keys, ..._resolvedViews.keys};

    for (final regionKey in allRegionKeys) {
      final oldView = oldViews[regionKey];
      final newView = _resolvedViews[regionKey];

      // Check if the region changed
      if (oldView == null && newView != null) {
        // Region was added
        addedRegions.add(regionKey);
        newViews[regionKey] = newView;
      } else if (oldView != null && newView == null) {
        // Region was removed - don't include it
        removedRegions.add(regionKey);
        continue;
      } else if (oldView != null && newView != null) {
        // Region exists in both - check if the key changed
        // If the key is the same, use the new view (to pass updated props)
        // If the key changed, use the new view (to trigger rebuild)
        if (oldView.key == newView.key) {
          unchangedRegions.add(regionKey);
          // Use new view to ensure updated props are passed to child widgets
          newViews[regionKey] = newView;
        } else {
          // Key changed - use the new view
          changedRegions.add(regionKey);
          newViews[regionKey] = newView;
        }
      }
    }

    // Log rebuild information
    if (widget.debugConfig?.enabled == true && widget.debugConfig?.logRebuilds == true) {
      if (changedRegions.isNotEmpty) {
        widget.debugConfig?.logRebuild('Rebuilding ${changedRegions.length} changed region(s): ${changedRegions.join(", ")}');
      }
      if (unchangedRegions.isNotEmpty) {
        widget.debugConfig?.logRebuild('Preserving ${unchangedRegions.length} unchanged region(s): ${unchangedRegions.join(", ")}');
      }
      if (addedRegions.isNotEmpty) {
        widget.debugConfig?.logRebuild('Adding ${addedRegions.length} new region(s): ${addedRegions.join(", ")}');
      }
      if (removedRegions.isNotEmpty) {
        widget.debugConfig?.logRebuild('Removing ${removedRegions.length} region(s): ${removedRegions.join(", ")}');
      }
    }

    _resolvedViews = newViews;
  }

  /// Resolves views for all regions based on view injection rules
  Map<String, Widget> _resolveViews(List<ViewInjectionRule> rules, RouteContext context) {
    final views = <String, Widget>{};

    // Get all unique region keys from rules and default builders
    final regionKeys = <String>{...rules.map((rule) => rule.regionKey), ...widget.defaultBuilders.keys};

    for (final regionKey in regionKeys) {
      try {
        final view = _viewResolver.resolveView(regionKey, rules, context, widget.defaultBuilders[regionKey]);

        if (view != null) {
          // Wrap with a key that identifies the region and the matching rule
          // This allows selective rebuilding when only some regions change
          final matchingRule = _viewResolver.findMatchingRule(regionKey, rules, context);
          final keyValue = _generateViewKey(regionKey, matchingRule, context);
          views[regionKey] = KeyedSubtree(key: ValueKey(keyValue), child: view);
        }
      } catch (e, stackTrace) {
        // Catch errors during view resolution and display error widget
        final errorWidget = widget.errorBuilder != null ? widget.errorBuilder!(regionKey, e, stackTrace) : _buildDefaultErrorWidget(regionKey, e, stackTrace);

        views[regionKey] = KeyedSubtree(key: ValueKey('$regionKey:error'), child: errorWidget);
      }
    }

    return views;
  }

  /// Builds a default error widget for a region
  Widget _buildDefaultErrorWidget(String regionKey, Object error, StackTrace? stackTrace) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFFFEBEE),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Error in region "$regionKey"',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
          ),
          const SizedBox(height: 8),
          Text(error.toString(), style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  /// Generates a stable key for a view based on region, rule, and context
  ///
  /// The key is designed to change only when the view's content would actually change.
  /// This enables selective rebuilding by preserving widgets with unchanged keys.
  String _generateViewKey(String regionKey, ViewInjectionRule? rule, RouteContext context) {
    // Create a key based on:
    // 1. The region key
    // 2. The rule's identity (using hashCode as a proxy)
    // 3. The route path
    // 4. Path and query parameters
    //
    // This ensures the key changes when any of these factors change,
    // triggering a rebuild only for affected regions.
    final ruleId = rule?.hashCode ?? 'default';
    final pathParamsKey = context.pathParameters.entries.map((e) => '${e.key}=${e.value}').join('&');
    final queryParamsKey = context.queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&');

    return '$regionKey:$ruleId:${context.path}:$pathParamsKey:$queryParamsKey';
  }

  @override
  Widget build(BuildContext context) {
    // If there was an error during initialization or resolution, show error
    if (_error != null) {
      return MosaiqueScope(routeContext: widget.context, nestingDetector: _nestingDetector, child: _buildErrorWidget(_error!, _errorStackTrace));
    }

    // If no route matched, show not found widget
    if (_currentRoute == null) {
      if (widget.notFoundBuilder != null) {
        return MosaiqueScope(routeContext: widget.context, nestingDetector: _nestingDetector, child: widget.notFoundBuilder!(widget.context));
      }
      // Default not found widget
      return MosaiqueScope(
        routeContext: widget.context,
        nestingDetector: _nestingDetector,
        child: const Center(child: Text('Route not found')),
      );
    }

    // If shell layout not found, show error
    if (_currentShell == null) {
      return MosaiqueScope(
        routeContext: _enrichedContext,
        nestingDetector: _nestingDetector,
        child: _buildErrorWidget(InvalidShellLayoutException('unknown', routePattern: _currentRoute!.pattern), null),
      );
    }

    // Build the shell with resolved views
    try {
      return MosaiqueScope(routeContext: _enrichedContext, nestingDetector: _nestingDetector, child: _currentShell!.builder(_resolvedViews));
    } catch (e, stackTrace) {
      // Catch errors during shell building
      return MosaiqueScope(routeContext: _enrichedContext, nestingDetector: _nestingDetector, child: _buildErrorWidget(e, stackTrace));
    }
  }

  /// Builds an error widget for display
  Widget _buildErrorWidget(Object error, StackTrace? stackTrace) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFFFEBEE),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mosaique Error',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
          ),
          const SizedBox(height: 12),
          Text(error.toString(), style: const TextStyle(fontSize: 14)),
          if (stackTrace != null) ...[
            const SizedBox(height: 12),
            const Text('Stack trace:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              stackTrace.toString(),
              style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Exit nesting context when widget is disposed
    if (_currentShell != null) {
      _nestingDetector.exit(_currentShell!.id);
    }
    super.dispose();
  }
}
