import '../errors/mosaique_exceptions.dart';

/// Detects circular nesting in shell layouts
///
/// This class maintains a stack of shell layout IDs being processed
/// and throws a [CircularNestingException] if a circular reference is detected.
class CircularNestingDetector {
  final List<String> _nestingStack = [];

  /// Enter a shell layout context
  ///
  /// Throws [CircularNestingException] if the shell layout is already in the stack.
  void enter(String shellLayoutId) {
    if (_nestingStack.contains(shellLayoutId)) {
      // Circular reference detected
      throw CircularNestingException([..._nestingStack, shellLayoutId]);
    }
    _nestingStack.add(shellLayoutId);
  }

  /// Exit a shell layout context
  void exit(String shellLayoutId) {
    if (_nestingStack.isNotEmpty && _nestingStack.last == shellLayoutId) {
      _nestingStack.removeLast();
    }
  }

  /// Get the current nesting depth
  int get depth => _nestingStack.length;

  /// Get the current nesting chain
  List<String> get chain => List.unmodifiable(_nestingStack);

  /// Check if a shell layout is currently in the nesting stack
  bool contains(String shellLayoutId) => _nestingStack.contains(shellLayoutId);

  /// Clear the nesting stack
  void clear() => _nestingStack.clear();
}
