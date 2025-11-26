# Mosaique

A declarative, route-driven region-based view composition package for Flutter.

## Overview

Mosaique allows you to define shell layouts with named regions that can be filled with different views based on navigation. It integrates seamlessly with go_router, making it easy to create complex, multi-region layouts without boilerplate code.

## Features

- ✅ **Declarative** - Define everything in your route tree
- ✅ **go_router native** - Works naturally with go_router's API
- ✅ **Nested shells** - Shells can inject other shells infinitely
- ✅ **Type-safe parameters** - Access route parameters via `context.pathParameters`
- ✅ **Automatic animations** - Smooth transitions using AnimatedSwitcher
- ✅ **Simple API** - Only 3 classes to learn

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  mosaique: ^0.1.0
  go_router: ^14.6.2
```

## Quick Start

### 1. Define Your Shell Layouts

Shells are regular StatelessWidgets with `Region` placeholders:

```dart
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: 250, child: Region('sidebar')),
          Expanded(child: Region('content')),
        ],
      ),
    );
  }
}
```

### 2. Configure Your Routes

Use `MosaiqueShellRoute` and `MosaiqueViewRoute` in your go_router configuration:

```dart
final router = GoRouter(
  routes: [
    MosaiqueShellRoute(
      shellBuilder: (context) => const MainShell(),
      regions: const ['sidebar', 'content'],
      fixedRegions: {
        'sidebar': (context) => const NavigationMenu(),
      },
      routes: [
        MosaiqueViewRoute(
          path: '/dashboard',
          region: 'content',
          builder: (context, state) => const DashboardView(),
        ),
        MosaiqueViewRoute(
          path: '/settings',
          region: 'content',
          builder: (context, state) => const SettingsView(),
        ),
      ],
    ),
  ],
);
```

### 3. Use the Router

```dart
void main() {
  runApp(
    MaterialApp.router(
      routerConfig: router,
    ),
  );
}
```

## Core Concepts

### Regions

Regions are named placeholders in your shell layouts. They get filled with content based on the current route.

```dart
Region('content')  // Simple region
Region('sidebar', transitionDuration: Duration(milliseconds: 500))  // With custom animation
```

### Fixed Regions

Fixed regions always show the same content, regardless of the current route. Perfect for persistent UI like headers or navigation menus.

```dart
MosaiqueShellRoute(
  fixedRegions: {
    'header': (context) => const AppHeader(),
    'sidebar': (context) => const NavigationMenu(),
  },
  // ...
)
```

### View Routes

View routes inject a specific widget into a region when the route is active.

```dart
MosaiqueViewRoute(
  path: '/users/:userId',
  region: 'content',
  builder: (context, state) => UserDetailsView(
    userId: state.pathParameters['userId']!,
  ),
)
```

### Nested Shells

Shells can be nested infinitely by specifying a target region:

```dart
MosaiqueShellRoute(
  shellBuilder: (context) => const UsersShell(),
  region: 'content',  // Inject this shell into parent's 'content' region
  regions: const ['list', 'details'],
  routes: [
    MosaiqueViewRoute(
      path: '/users/:userId',
      region: 'details',
      builder: (context, state) => UserDetailsView(
        userId: state.pathParameters['userId']!,
      ),
    ),
  ],
)
```

## Example

See the [example](example/) directory for a complete working app demonstrating:

- Main shell with header, sidebar, and content regions
- Fixed regions for persistent UI
- View injection based on routes
- Nested shells (Users section with list/detail layout)
- Route parameters
- Navigation between routes

## API Reference

### `Region`

A placeholder widget that gets replaced with actual content.

```dart
Region(
  String name,  // Required: region identifier
  {Duration? transitionDuration}  // Optional: animation duration
)
```

### `MosaiqueShellRoute`

Defines a shell layout with named regions.

```dart
MosaiqueShellRoute({
  required WidgetBuilder shellBuilder,
  required List<String> regions,
  Map<String, WidgetBuilder> fixedRegions = const {},
  String? region,  // Target region in parent shell
  List<RouteBase> routes = const [],
})
```

### `MosaiqueViewRoute`

Injects a view into a specific region.

```dart
MosaiqueViewRoute({
  required String path,
  required String region,
  required GoRouterWidgetBuilder builder,
})
```

## How It Works

1. go_router navigates and evaluates the route tree
2. `MosaiqueShellRoute` builds the shell widget
3. Each `Region` widget looks up what to render based on:
   - Active child routes targeting that region
   - Fixed regions defined in the shell
   - Falls back to empty (SizedBox.shrink)
4. Content changes are animated using `AnimatedSwitcher`

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

MIT License - see LICENSE file for details.
