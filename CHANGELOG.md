# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-12-02

### Breaking Changes
- Removed unused `regions` parameter from `MosaiqueShellRoute`

## [1.0.1] - 2025-11-26

### Changed
- Updated `go_router` dependency constraint from `^14.6.2` to `">=14.6.2"` to allow compatibility with newer versions including 17.x

## [1.0.0] - 2025-11-26

### Added
- Initial release of Mosaique
- `Region` widget for defining placeholders in shell layouts
- `MosaiqueShellRoute` for creating reusable shell layouts with named regions
- `MosaiqueViewRoute` for injecting views into specific regions based on routes
- Support for fixed regions (persistent UI elements like headers, sidebars)
- Support for nested shells (shells can be injected into parent shell regions)
- Multiple views can be injected into different regions from the same route
- Native go_router page transition animations
- Full integration with go_router (extends ShellRoute and GoRoute)
- Comprehensive example app demonstrating:
  - 3 reusable shell templates
  - Fixed and dynamic regions
  - Nested shell composition
  - List+detail pattern with master-detail layout
  - Navigation patterns (push/pop/go)

### Features
- **Declarative** - Define everything in your route tree
- **Router-native** - Uses go_router's built-in animations and navigation
- **Reusable shells** - Define shell templates once, reuse with different views
- **Type-safe** - Full type safety for route parameters
- **Flexible** - Mix shell routes with regular GoRoutes
- **Simple API** - Only 3 classes to learn: Region, MosaiqueShellRoute, MosaiqueViewRoute
