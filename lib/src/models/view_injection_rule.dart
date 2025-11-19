import 'package:flutter/foundation.dart';
import 'type_aliases.dart';

/// Rule for injecting a view into a specific region
@immutable
class ViewInjectionRule {
  /// The key identifying which region this rule applies to
  final String regionKey;

  /// Condition function that determines if this rule should apply
  final ConditionFunction condition;

  /// Builder function that creates the widget for this region
  final WidgetBuilder builder;

  /// Priority for this rule when multiple rules match
  ///
  /// Higher priority values take precedence. Default is 0.
  /// If priorities are equal, the first registered rule wins.
  final int priority;

  /// Creates a new [ViewInjectionRule]
  const ViewInjectionRule({required this.regionKey, required this.condition, required this.builder, this.priority = 0});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ViewInjectionRule && other.regionKey == regionKey && other.condition == condition && other.builder == builder && other.priority == priority;
  }

  @override
  int get hashCode {
    return Object.hash(regionKey, condition, builder, priority);
  }

  @override
  String toString() {
    return 'ViewInjectionRule(regionKey: $regionKey, priority: $priority)';
  }
}
