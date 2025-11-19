/// Debug configuration for Mosaique
library;

/// Debug configuration for Mosaique logging
class MosaiqueDebugConfig {
  /// Whether debug logging is enabled
  final bool enabled;

  /// Whether to log route matching decisions
  final bool logRouteMatching;

  /// Whether to log view resolution steps
  final bool logViewResolution;

  /// Whether to log rebuild information
  final bool logRebuilds;

  /// Custom log handler (defaults to print)
  final void Function(String message) logHandler;

  /// Creates a new [MosaiqueDebugConfig]
  const MosaiqueDebugConfig({
    this.enabled = false,
    this.logRouteMatching = true,
    this.logViewResolution = true,
    this.logRebuilds = true,
    this.logHandler = print,
  });

  /// Creates a debug config with all logging enabled
  const MosaiqueDebugConfig.all({this.logHandler = print}) : enabled = true, logRouteMatching = true, logViewResolution = true, logRebuilds = true;

  /// Creates a debug config with no logging
  const MosaiqueDebugConfig.none() : enabled = false, logRouteMatching = false, logViewResolution = false, logRebuilds = false, logHandler = print;

  /// Log a message if debug logging is enabled
  void log(String message, {required bool condition}) {
    if (enabled && condition) {
      logHandler('[Mosaique] $message');
    }
  }

  /// Log a route matching decision
  void logRouteMatch(String message) {
    log(message, condition: logRouteMatching);
  }

  /// Log a view resolution step
  void logViewResolve(String message) {
    log(message, condition: logViewResolution);
  }

  /// Log a rebuild event
  void logRebuild(String message) {
    log(message, condition: logRebuilds);
  }
}
