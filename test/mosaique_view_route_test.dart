import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mosaique/mosaique.dart';

void main() {
  group('MosaiqueViewRoute Tests', () {
    test('MosaiqueViewRoute extends GoRoute', () {
      final route = MosaiqueViewRoute(
        path: '/test',
        region: 'content',
        builder: (context, state) => const SizedBox(),
      );

      expect(route, isA<GoRoute>());
    });

    test('MosaiqueViewRoute stores region property', () {
      const testRegion = 'test-region';

      final route = MosaiqueViewRoute(
        path: '/test',
        region: testRegion,
        builder: (context, state) => const SizedBox(),
      );

      expect(route.region, equals(testRegion));
    });

    test('MosaiqueViewRoute stores path correctly', () {
      const testPath = '/test/path';

      final route = MosaiqueViewRoute(
        path: testPath,
        region: 'content',
        builder: (context, state) => const SizedBox(),
      );

      expect(route.path, equals(testPath));
    });

    test('MosaiqueViewRoute accepts parameterized paths', () {
      const testPath = '/users/:userId';

      final route = MosaiqueViewRoute(
        path: testPath,
        region: 'details',
        builder: (context, state) => const SizedBox(),
      );

      expect(route.path, equals(testPath));
      expect(route.region, equals('details'));
    });
  });
}
