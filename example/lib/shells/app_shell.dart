import 'package:flutter/material.dart';
import 'package:mosaique/mosaique.dart';

/// Main application shell with header, sidebar, and content area.
///
/// Reused by: Dashboard, Products, and other main app views.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Region('header'),
          Expanded(
            child: Row(
              children: [
                SizedBox(width: 250, child: Region('sidebar')),
                Expanded(child: Region('content')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
