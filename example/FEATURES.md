# Example Application Features

This document provides a quick reference for the features demonstrated in the Mosaique example application.

## Shell Layouts

### 1. Main Layout (`main`)
- **Location**: `lib/main.dart`
- **Structure**: Scaffold with AppBar, main content area, and optional drawer
- **Used by**: Home, Products, Settings routes
- **Demonstrates**: Basic single-region layout with navigation drawer

### 2. Two-Column Layout (`two-column`)
- **Location**: `lib/main.dart`
- **Structure**: Scaffold with AppBar, split content (2:1 ratio)
- **Used by**: Users list, User detail routes
- **Demonstrates**: Multi-region layout with main content and sidebar

### 3. Nested Detail Layout (`nested-detail`)
- **Location**: `lib/views/nested_product_view.dart`
- **Structure**: Column with header and content regions
- **Used by**: Product detail (nested within main layout)
- **Demonstrates**: Nested shell layouts and parameter propagation

## Routes and Views

### Home Route (`/`)
- **File**: `lib/views/home_view.dart`
- **Shell**: `main`
- **Features**: Welcome screen with feature overview
- **Demonstrates**: Basic view rendering

### Users List Route (`/users`)
- **File**: `lib/views/users_list_view.dart`
- **Shell**: `two-column`
- **Features**: List of users with sidebar
- **Demonstrates**: 
  - Two-column layout
  - Route context access
  - Navigation to detail pages

### User Detail Route (`/users/:userId`)
- **File**: `lib/views/user_detail_view.dart`
- **Shell**: `two-column`
- **Features**: User details with path parameter
- **Demonstrates**:
  - Path parameter extraction (`:userId`)
  - Route context information display
  - Back navigation

### Product Detail Route (`/products/:productId`)
- **File**: `lib/views/nested_product_view.dart`
- **Shell**: `main` (outer) + `nested-detail` (inner)
- **Features**: Product details with nested layout
- **Demonstrates**:
  - Nested shell layouts
  - Parameter propagation through nesting
  - Multiple regions in nested layout (header + content)

### Settings Route (`/settings`)
- **File**: `lib/views/settings_view.dart`
- **Shell**: `main`
- **Features**: Settings page with tabs controlled by query parameters
- **Demonstrates**:
  - Query parameter extraction (`?tab=general`)
  - Dynamic content based on query parameters
  - Tab navigation with URL updates

## Navigation

### Navigation Drawer
- **File**: `lib/widgets/navigation_drawer.dart`
- **Features**: Side drawer with links to all example routes
- **Demonstrates**: Programmatic navigation using `context.go()`

### Navigation Methods
1. **Drawer Links**: Click items in the navigation drawer
2. **List Items**: Click users in the users list
3. **Back Buttons**: Use back buttons in views
4. **Tab Navigation**: Click tabs in settings page

## go_router Integration

### Adapter Setup
```dart
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/:path(.*)',
      builder: (context, state) {
        return MosaiqueShellBuilder(
          context: _adapter.getCurrentContext(),
          // ...
        );
      },
    ),
  ],
);

final _adapter = GoRouterAdapter(_router);
```

### Route Context Extraction
- **Path**: From `GoRouterState.matchedLocation`
- **Path Parameters**: From `GoRouterState.pathParameters`
- **Query Parameters**: From `GoRouterState.uri.queryParameters`

## Debug Features

The example enables debug logging:
```dart
debugConfig: const MosaiqueDebugConfig(
  enabled: true,
  logRouteMatching: true,
  logViewResolution: true,
  logRebuilds: true,
),
```

Check the console output to see:
- Route matching decisions
- View resolution steps
- Rebuild information

## Testing the Example

### Quick Test Routes
1. `/` - Home page
2. `/users` - Users list
3. `/users/1` - User detail (Alice)
4. `/users/2` - User detail (Bob)
5. `/products/1` - Product with nested layout
6. `/settings` - Settings (general tab)
7. `/settings?tab=account` - Settings (account tab)
8. `/settings?tab=privacy` - Settings (privacy tab)

### What to Observe
- **Shell Layout Changes**: Notice how the layout changes between routes
- **Selective Rebuilding**: Only affected regions rebuild on navigation
- **Parameter Extraction**: Path and query parameters are extracted and displayed
- **Nested Layouts**: Product page shows nested shell layout with propagated parameters
- **Debug Logs**: Console shows detailed information about route resolution

## Code Organization

```
example/
├── lib/
│   ├── main.dart                      # App setup, shell layouts, routes
│   ├── views/                         # View widgets
│   │   ├── home_view.dart
│   │   ├── users_list_view.dart
│   │   ├── user_detail_view.dart
│   │   ├── nested_product_view.dart
│   │   └── settings_view.dart
│   └── widgets/                       # Reusable widgets
│       └── navigation_drawer.dart
├── pubspec.yaml
├── README.md                          # Getting started guide
└── FEATURES.md                        # This file
```
