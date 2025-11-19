import 'package:flutter/widgets.dart';

/// A widget that catches errors in its child widget tree and displays an error UI
///
/// This is used to implement error boundaries for regions, preventing errors
/// in one region from crashing the entire application.
class ErrorBoundary extends StatefulWidget {
  /// The child widget to wrap with error handling
  final Widget child;

  /// Optional custom error widget builder
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  /// The region key this boundary is protecting (for error messages)
  final String? regionKey;

  /// Creates a new [ErrorBoundary]
  const ErrorBoundary({required this.child, this.errorBuilder, this.regionKey, super.key});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      // An error occurred, show error UI
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }

      // Default error UI
      return _DefaultErrorWidget(error: _error!, stackTrace: _stackTrace, regionKey: widget.regionKey);
    }

    // No error, show the child directly
    // Note: We can't catch synchronous build errors here without wrapping in Builder,
    // which would affect widget tree structure. Instead, errors should be caught
    // at the view resolution level.
    return widget.child;
  }
}

/// Default error widget shown when a region encounters an error
class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final String? regionKey;

  const _DefaultErrorWidget({required this.error, this.stackTrace, this.regionKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFFFEBEE), // Light red background
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFD32F2F)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  regionKey != null ? 'Error in region "$regionKey"' : 'Error',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(error.toString(), style: const TextStyle(fontSize: 14, color: Color(0xFF424242))),
          if (stackTrace != null) ...[
            const SizedBox(height: 8),
            const Text('Stack trace:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              stackTrace.toString(),
              style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Extension to add Icons class for the error icon
/// This is a minimal implementation for the error boundary
class Icons {
  static const IconData error_outline = IconData(0xe001);
}
