import 'package:flutter/widgets.dart';
import '../models/models.dart' hide WidgetBuilder;
import '../models/type_aliases.dart' as types;
import '../errors/mosaique_exceptions.dart';
import '../utils/debug_config.dart';

/// Resolves which widget should be rendered for a region based on view injection rules
class ViewResolver {
  /// Debug configuration for logging
  final MosaiqueDebugConfig? debugConfig;

  /// Creates a new [ViewResolver]
  const ViewResolver({this.debugConfig});

  /// Resolve which widget should be rendered for a region
  ///
  /// Evaluates all [rules] for the given [regionKey] against the [context].
  /// Returns the widget from the highest priority matching rule, or uses
  /// [defaultBuilder] if no rules match, or null if no default is provided.
  ///
  /// Throws [WidgetBuilderException] if a widget builder throws an exception.
  Widget? resolveView(String regionKey, List<ViewInjectionRule> rules, RouteContext context, types.WidgetBuilder? defaultBuilder) {
    debugConfig?.logViewResolve('Resolving view for region: "$regionKey"');

    // Find the matching rule with highest priority
    final matchingRule = findMatchingRule(regionKey, rules, context);

    if (matchingRule != null) {
      debugConfig?.logViewResolve('  Using matching rule (priority: ${matchingRule.priority})');
      // Use the matching rule's builder
      try {
        final widget = matchingRule.builder(context);
        debugConfig?.logViewResolve('  ✓ Widget built successfully for region "$regionKey"');
        return widget;
      } catch (e, stackTrace) {
        debugConfig?.logViewResolve('  ✗ Widget builder threw exception: $e');
        throw WidgetBuilderException(regionKey, e, stackTrace: stackTrace);
      }
    }

    // Fall back to default builder if no rules match
    if (defaultBuilder != null) {
      debugConfig?.logViewResolve('  Using default builder for region "$regionKey"');
      try {
        final widget = defaultBuilder(context);
        debugConfig?.logViewResolve('  ✓ Default widget built successfully for region "$regionKey"');
        return widget;
      } catch (e, stackTrace) {
        debugConfig?.logViewResolve('  ✗ Default builder threw exception: $e');
        throw WidgetBuilderException(regionKey, e, stackTrace: stackTrace);
      }
    }

    // No matching rule and no default builder
    debugConfig?.logViewResolve('  No view resolved for region "$regionKey" (no matching rules or default builder)');
    return null;
  }

  /// Find the highest priority matching rule for a region
  ///
  /// Filters [rules] to those matching [regionKey], evaluates their conditions
  /// against [context], and returns the rule with the highest priority.
  /// Returns null if no rules match.
  ViewInjectionRule? findMatchingRule(String regionKey, List<ViewInjectionRule> rules, RouteContext context) {
    // Filter rules for this region
    final regionRules = rules.where((rule) => rule.regionKey == regionKey).toList();

    debugConfig?.logViewResolve('  Evaluating ${regionRules.length} rule(s) for region "$regionKey"');

    // Find all matching rules (where condition returns true)
    final matchingRules = <ViewInjectionRule>[];

    for (final rule in regionRules) {
      try {
        final matches = rule.condition(context);
        if (matches) {
          matchingRules.add(rule);
          debugConfig?.logViewResolve('    ✓ Rule matches (priority: ${rule.priority})');
        } else {
          debugConfig?.logViewResolve('    ✗ Rule condition returned false');
        }
      } catch (e) {
        // If condition throws, treat as non-matching
        debugConfig?.logViewResolve('    ✗ Rule condition threw exception: $e');
      }
    }

    // If no rules match, return null
    if (matchingRules.isEmpty) {
      debugConfig?.logViewResolve('  No matching rules found for region "$regionKey"');
      return null;
    }

    // Sort by priority (highest first), then by original order
    matchingRules.sort((a, b) => b.priority.compareTo(a.priority));

    debugConfig?.logViewResolve('  Selected rule with priority ${matchingRules.first.priority} (${matchingRules.length} rule(s) matched)');

    // Return the highest priority rule
    return matchingRules.first;
  }
}
