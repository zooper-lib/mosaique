# Implementation Plan

- [x] 1. Set up core data models
  - Create RouteContext, ShellLayout, RouteDefinition, and ViewInjectionRule classes
  - Define type aliases for ShellLayoutSelector, ConditionFunction, and WidgetBuilder
  - Implement equality and hashCode for immutable data structures
  - _Requirements: 1.1, 1.2, 2.1, 2.2, 2.3, 3.1, 3.2_

- [ ]* 1.1 Write property test for shell layout registration and retrieval
  - **Property 1: Shell layout registration and retrieval**
  - **Validates: Requirements 1.1, 1.4**

- [x] 2. Implement route pattern matching
  - Create RouteMatcher class with pattern parsing logic
  - Implement specificity calculation algorithm
  - Implement path parameter extraction from URLs
  - Support static segments, path parameters, wildcards, and optional segments
  - _Requirements: 2.4, 2.5, 4.1_

- [ ]* 2.1 Write property test for route matching specificity
  - **Property 2: Route matching specificity**
  - **Validates: Requirements 2.5**

- [ ]* 2.2 Write property test for path parameter extraction
  - **Property 4: Path parameter extraction**
  - **Validates: Requirements 4.1**

- [x] 3. Implement configuration registry
  - Create MosaiqueRegistry class
  - Implement shell layout registration and lookup
  - Implement route definition registration
  - Implement default builder registration
  - Add validation logic for configuration
  - _Requirements: 1.1, 1.4, 2.1, 2.2, 2.3, 9.1, 10.1, 10.5_

- [ ]* 3.1 Write property test for shell layout validation
  - **Property 12: Shell layout validation**
  - **Validates: Requirements 10.1, 10.5**

- [x] 4. Implement view resolution logic
  - Create ViewResolver class
  - Implement rule matching based on conditions
  - Implement priority-based rule selection
  - Support default builder fallback
  - _Requirements: 3.3, 3.4, 3.5, 9.2, 9.3, 9.4, 9.5_

- [ ]* 4.1 Write property test for view injection rule priority
  - **Property 3: View injection rule priority**
  - **Validates: Requirements 3.4**

- [ ]* 4.2 Write property test for default builder fallback
  - **Property 11: Default builder fallback**
  - **Validates: Requirements 9.2, 9.5**

- [ ]* 4.3 Write property test for parameter availability in condition functions
  - **Property 6: Parameter availability in condition functions**
  - **Validates: Requirements 4.3, 4.4**

- [x] 5. Implement MosaiqueScope InheritedWidget
  - Create MosaiqueScope class extending InheritedWidget
  - Implement static of() and maybeOf() methods
  - Create BuildContext extension for convenient access
  - Implement updateShouldNotify for route context changes
  - _Requirements: 12.1, 12.2, 12.3, 12.5_

- [ ]* 5.1 Write property test for route context consistency
  - **Property 15: Route context consistency**
  - **Validates: Requirements 12.2, 12.5**

- [x] 6. Implement MosaiqueShellBuilder widget
  - Create StatefulWidget for shell building
  - Implement route matching on context changes
  - Implement shell layout selection
  - Implement view resolution for each region
  - Build final widget tree with shell and views
  - _Requirements: 1.3, 1.5, 2.4, 3.3, 5.2, 5.3, 5.5_

- [x] 7. Implement selective rebuilding optimization
  - Implement didUpdateWidget to detect changes
  - Use keys to identify changed regions
  - Rebuild only affected region widgets
  - Preserve state of unchanged regions
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ]* 7.1 Write property test for selective region rebuilding
  - **Property 8: Selective region rebuilding**
  - **Validates: Requirements 8.1, 8.2, 8.4**

- [ ]* 7.2 Write property test for full rebuild on shell layout change
  - **Property 9: Full rebuild on shell layout change**
  - **Validates: Requirements 8.3**

- [ ]* 7.3 Write property test for state preservation during partial rebuilds
  - **Property 10: State preservation during partial rebuilds**
  - **Validates: Requirements 8.5**

- [x] 8. Implement router adapter interface
  - Create MosaiqueRouterAdapter abstract class
  - Define getCurrentContext() method
  - Define onRouteChanged stream
  - Define navigate() and goBack() methods
  - _Requirements: 6.1, 6.3, 7.1, 7.2, 7.5_

- [ ]* 8.1 Write property test for route context update triggers resolution
  - **Property 7: Route context update triggers resolution**
  - **Validates: Requirements 5.5, 6.5, 7.3**

- [x] 9. Implement go_router adapter
  - Create GoRouterAdapter implementing MosaiqueRouterAdapter
  - Extract RouteContext from GoRouterState (including query parameters from GoRouterState.uri.queryParameters)
  - Convert GoRouter navigation events to RouteContext stream
  - Implement navigate() using GoRouter.go()
  - Implement goBack() using GoRouter.pop()
  - _Requirements: 6.2, 6.4, 6.5, 4.2_

- [ ]* 9.1 Write integration test for go_router adapter
  - Test adapter with real go_router instance
  - Verify route context extraction including query parameters
  - Verify navigation methods work correctly
  - _Requirements: 6.2, 4.2_

- [ ]* 9.2 Write property test for query parameter extraction in adapter
  - **Property 5: Query parameter extraction**
  - **Validates: Requirements 4.2**

- [x] 10. Implement error handling
  - Add error handling for invalid shell layout references
  - Add circular nesting detection
  - Add error handling for missing required parameters
  - Add error handling for route matching failures
  - Add error handling for widget builder exceptions
  - Implement error boundaries for regions
  - _Requirements: 10.3_

- [ ]* 10.1 Write unit tests for error handling
  - Test invalid shell layout reference errors
  - Test circular nesting detection
  - Test widget builder exception handling
  - _Requirements: 10.3_

- [x] 11. Implement nested shell layout support
  - Allow views to contain nested shell layouts
  - Implement parameter propagation through nesting
  - Implement selective rebuilding for nested regions
  - Add circular reference detection
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [ ]* 11.1 Write property test for parameter propagation through nesting
  - **Property 13: Parameter propagation through nesting**
  - **Validates: Requirements 11.3**

- [ ]* 11.2 Write property test for selective nested region rebuilding
  - **Property 14: Selective nested region rebuilding**
  - **Validates: Requirements 11.4**

- [x] 12. Implement route context reactivity
  - Ensure views are notified on route context changes
  - Implement efficient change detection
  - Trigger rebuilds only for affected views
  - _Requirements: 12.4_

- [ ]* 12.1 Write property test for route context reactivity
  - **Property 16: Route context reactivity**
  - **Validates: Requirements 12.4**

- [x] 13. Add validation and debug features
  - Implement strict and lenient validation modes
  - Add debug logging for route matching decisions
  - Add debug logging for view resolution steps
  - Add debug logging for rebuild information
  - _Requirements: 10.4_

- [x] 14. Create example application
  - Create example app demonstrating basic usage
  - Show shell layout definition
  - Show route definition with view injection rules
  - Show navigation between routes
  - Show nested shell layouts
  - Demonstrate go_router integration

- [ ] 15. Write documentation
  - Write API documentation for all public classes
  - Create getting started guide
  - Create migration guide for existing apps
  - Document route pattern syntax
  - Document region key conventions
  - Document priority system
  - Add code examples for common use cases

- [ ] 16. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
