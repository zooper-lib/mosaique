import 'package:flutter/material.dart';
import 'package:mosaique/mosaique.dart';

/// Simple full-screen content shell.
///
/// Reused by: Login, public pages, etc.
class SimpleShell extends StatelessWidget {
  const SimpleShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Region('content'),
    );
  }
}
