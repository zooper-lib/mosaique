import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaique/src/region.dart';
import 'package:mosaique/src/mosaique_shell_route_data.dart';

void main() {
  group('Region Widget Tests', () {
    testWidgets('Region renders content from MosaiqueShellRouteData',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MosaiqueShellRouteData(
            fixedRegions: {
              'test-region': _buildTestContent,
            },
            activeRoutes: [],
            child: Region('test-region'),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('Region returns SizedBox.shrink() when no content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MosaiqueShellRouteData(
            fixedRegions: {},
            activeRoutes: [],
            child: Region('test-region'),
          ),
        ),
      );

      // SizedBox.shrink creates a widget with zero size
      final widget = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(widget.width, 0.0);
      expect(widget.height, 0.0);
    });

    testWidgets('Region looks up correct region name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MosaiqueShellRouteData(
            fixedRegions: {
              'region-1': _buildTestContent1,
              'region-2': _buildTestContent2,
            },
            activeRoutes: [],
            child: Column(
              children: [
                Region('region-1'),
                Region('region-2'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Content 1'), findsOneWidget);
      expect(find.text('Content 2'), findsOneWidget);
    });

    testWidgets('Region prioritizes active routes over fixed regions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MosaiqueShellRouteData(
            fixedRegions: {
              'test-region': _buildFixedContent,
            },
            activeRoutes: [
              ActiveRouteData(
                targetRegion: 'test-region',
                builder: _buildActiveContent,
              ),
            ],
            child: Region('test-region'),
          ),
        ),
      );

      // Should show active content, not fixed content
      expect(find.text('Active Content'), findsOneWidget);
      expect(find.text('Fixed Content'), findsNothing);
    });
  });
}

Widget _buildTestContent(BuildContext context) {
  return const Text('Test Content');
}

Widget _buildTestContent1(BuildContext context) {
  return const Text('Content 1');
}

Widget _buildTestContent2(BuildContext context) {
  return const Text('Content 2');
}

Widget _buildFixedContent(BuildContext context) {
  return const Text('Fixed Content');
}

Widget _buildActiveContent(BuildContext context) {
  return const Text('Active Content');
}
