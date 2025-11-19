import 'package:flutter/widgets.dart';
import 'route_context.dart';

/// Determines which shell layout to use based on the current route context
typedef ShellLayoutSelector = String Function(RouteContext context);

/// Condition function that determines if a rule should apply
typedef ConditionFunction = bool Function(RouteContext context);

/// Creates a widget for a region based on the current route context
typedef WidgetBuilder = Widget Function(RouteContext context);
