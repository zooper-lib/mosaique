# Mosaique Example Application

This example application demonstrates the key features of the Mosaique package, a declarative, route-driven multi-region shell layout system for Flutter.

## Features Demonstrated

### 1. Shell Layout Definition

The example defines three different shell layouts:

- **`main`**: A simple layout with an app bar, main content area, and optional drawer
- **`two-column`**: A layout with a main content area and a sidebar
- **`nested-detail`**: A nested layout with header and content regions

See `lib/main.dart` for the shell layout definitions.

### 2. Route Definitions with View Injection Rules

Routes are defined declaratively with patterns and view injection rules:

```dart
RouteDefinition(
  pattern: '/users/:userId',
  shellSelector: (context) => 'two-column',
  viewRules: [
    ViewInjectionRule(
      regionKey: 'main',
      condition: (context) => true,
      builder: (context) => UserDetailView(
        userId: context.pathParameters['userId'] ?? '',
      ),
    ),
    // ... more rules
  ],
)
```

### 3. Navigation Between Routes

The example demonstrates:

- **Programmatic navigation**: Using `context.go()` from go_router
- **Deep linking**: Direct navigation to any route via URL
- **Back navigation**: Using the back button

### 4. Nested Shell Layouts

The product detail page (`/products/:productId`) demonstrates nested shell layouts:

- The outer shell uses the `main` layout
- The product view contains a nested `MosaiqueShellBuilder` with its own `nested-detail` layout
- Parameters are propagated through the nesting hierarchy

See `lib/views/nested_product_view.dart` for the implementation.

### 5. go_router Integration

The example uses the `GoRouterAdapter` to integrate Mosaique with go_router:

```dart
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/:path(.*)',
      builder: (context, state) {
        return MosaiqueShellBuilder(
          context: _adapter.getCurrentContext(),
          shellLayouts: _shellLayouts,
          routes: _routeDefinitions,
          // ...
        );
      },
    ),
  ],
);

final _adapter = GoRouterAdapter(_router);
```

## Running the Example

1. Ensure you have Flutter installed and configured
2. Navigate to the example directory:
   ```bash
   cd example
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Example Routes

Try navigating to these routes to see different features:

- `/` - Home page with feature overview
- `/users` - Users list with two-column layout
- `/users/1` - User detail page with path parameter extraction
- `/products/1` - Product detail with nested shell layout
- `/settings` - Settings page with query parameters
- `/settings?tab=account` - Settings page with specific tab via query parameter

## Code Structure

```
example/
├── lib/
│   ├── main.dart                      # App entry point and configuration
│   ├── views/
│   │   ├── home_view.dart            # Home page
│   │   ├── users_list_view.dart      # Users list and sidebar
│   │   ├── user_detail_view.dart     # User detail with parameters
│   │   ├── nested_product_view.dart  # Nested layout demo
│   │   └── settings_view.dart        # Query parameters demo
│   └── widgets/
│       └── navigation_drawer.dart    # Navigation drawer
├── pubspec.yaml
└── README.md
```

## Key Concepts

### Shell Layouts

Shell layouts define the structure of your pages with named region placeholders. They are reusable templates that can be applied to different routes.

### Route Definitions

Route definitions map URL patterns to shell layouts and specify which views should be injected into which regions based on conditions.

### View Injection Rules

View injection rules determine which widgets appear in which regions. They support:
- Condition functions to evaluate route context
- Priority-based selection when multiple rules match
- Access to path and query parameters

### Route Context

The route context contains:
- Current path
- Path parameters (extracted from URL patterns like `:userId`)
- Query parameters (from URL query strings like `?tab=account`)
- Extra data passed during navigation

### Nested Layouts

Mosaique supports composing complex layouts by nesting shell builders. Nested layouts:
- Can have their own shell layouts and routes
- Receive the parent route context
- Support parameter propagation through the hierarchy

## Learn More

For more information about Mosaique, see the main package documentation.
