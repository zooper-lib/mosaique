import 'package:flutter/widgets.dart';

/// Defines a shell layout with region placeholders
@immutable
class ShellLayout {
  /// Unique identifier for this shell layout
  final String id;

  /// Builder function that creates the shell layout widget
  ///
  /// The builder receives a map of region keys to widgets that should be
  /// injected into the corresponding region placeholders.
  final Widget Function(Map<String, Widget> regions) builder;

  /// Creates a new [ShellLayout]
  const ShellLayout({required this.id, required this.builder});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShellLayout && other.id == id && other.builder == builder;
  }

  @override
  int get hashCode => Object.hash(id, builder);

  @override
  String toString() => 'ShellLayout(id: $id)';
}
