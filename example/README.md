# Mosaique Example App

This example demonstrates the core concept of Mosaique: **reusable shell templates with different views injected into regions**.

## Project Structure

```
lib/
├── main.dart                    # Router configuration only
├── shells/                      # Reusable shell templates
│   ├── app_shell.dart          # Main app shell (header + sidebar + content)
│   ├── two_column_shell.dart   # List/detail layout shell
│   └── simple_shell.dart       # Full-screen content shell
└── views/
    ├── fixed/                   # Views injected via fixedRegions
    │   ├── app_header.dart     # Fixed header for AppShell
    │   └── app_sidebar.dart    # Fixed sidebar for AppShell
    └── dynamic/                 # Views injected via routes
        ├── dashboard_view.dart
        ├── products_view.dart
        ├── users_list_view.dart
        ├── user_details_view.dart
        ├── login_view.dart
        └── settings_view.dart
```

## Key Concept: Reusable Shell Templates

The example demonstrates **3 reusable shell templates**:

### 1. AppShell (header + sidebar + content)
**Reused by:** Dashboard, Products

```dart
MosaiqueShellRoute(
  shellBuilder: (context) => const AppShell(),
  fixedRegions: {
    'header': (context) => const AppHeader(),
    'sidebar': (context) => const AppSidebar(),
  },
  routes: [
    // Dashboard injected into 'content'
    // Products injected into 'content'
  ],
)
```

### 2. TwoColumnShell (list + details)
**Reused by:** Users section

```dart
MosaiqueShellRoute(
  shellBuilder: (context) => const TwoColumnShell(),
  region: 'content', // Nested inside AppShell
  routes: [
    // UsersListView injected into 'list'
    // UserDetailsView injected into 'details'
  ],
)
```

### 3. SimpleShell (full-screen content)
**Reused by:** Login page

```dart
MosaiqueShellRoute(
  shellBuilder: (context) => const SimpleShell(),
  routes: [
    // LoginView injected into 'content'
  ],
)
```

## Navigation Flow

- **Dashboard** → Uses AppShell, injects DashboardView into `content`
- **Products** → Uses AppShell, injects ProductsView into `content`
- **Users** → Uses AppShell + nested TwoColumnShell
  - `/users` → Shows list only
  - `/users/:id` → Shows list + details
- **Login** → Uses SimpleShell (no header/sidebar)
- **Settings** → No shell (regular GoRoute)

## Running the Example

```bash
cd example
flutter run
```

## What This Demonstrates

1. **Shell Reusability**: Same shell template used by multiple views
2. **Nested Shells**: TwoColumnShell injected into AppShell's content region
3. **Fixed vs Dynamic Regions**: Header/sidebar are fixed, content changes per route
4. **Multiple Shell Types**: Different layouts for different use cases
5. **Clean Router Config**: Readable, maintainable route definitions
6. **Code Organization**: Shells and views in separate files

The key insight: **You define shell templates once, then inject different views based on navigation**.
