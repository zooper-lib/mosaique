# Quick Start Guide

Get the Mosaique example running in 3 steps:

## 1. Install Dependencies

```bash
cd example
flutter pub get
```

## 2. Run the App

```bash
flutter run
```

Choose your target device when prompted (Chrome for web, or a mobile device/emulator).

## 3. Explore the Features

Open the navigation drawer (☰ icon) and try these routes:

### Basic Features
- **Home** - Overview of Mosaique features
- **Users List** - Two-column layout with list and sidebar
- **User Detail** - Path parameter extraction (`:userId`)

### Advanced Features
- **Product Detail** - Nested shell layouts
- **Settings** - Query parameter handling (`?tab=...`)

## What to Look For

### 1. Shell Layout Changes
Notice how the page structure changes between routes:
- Home uses a simple layout with drawer
- Users uses a two-column layout
- Products use nested layouts

### 2. Selective Rebuilding
Watch the debug console - only affected regions rebuild on navigation.

### 3. Parameter Extraction
- User detail shows the `:userId` path parameter
- Settings shows the `?tab=` query parameter

### 4. Nested Layouts
Product detail demonstrates:
- Outer shell (main layout)
- Inner shell (nested-detail layout)
- Parameter propagation through nesting

## Debug Output

The example enables debug logging. Check your console for:
```
=== Route Resolution Started ===
Matched route: /users/1
Shell selector returned: "two-column"
Resolving views for 2 rule(s)
=== Route Resolution Complete ===
```

## Next Steps

1. Read `README.md` for detailed documentation
2. Check `FEATURES.md` for feature breakdown
3. Explore the code in `lib/` directory
4. Try modifying routes and shell layouts

## Common Issues

### Dependencies Not Found
```bash
cd example
flutter pub get
```

### Hot Reload Not Working
Try hot restart (Shift+R in terminal) instead of hot reload.

### Route Not Found
Make sure you're using the correct path format. All routes are defined in `lib/main.dart`.

## Learn More

- [Mosaique Package Documentation](../README.md)
- [Flutter Documentation](https://flutter.dev/docs)
- [go_router Documentation](https://pub.dev/packages/go_router)
