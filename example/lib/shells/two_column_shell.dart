import 'package:flutter/material.dart';
import 'package:mosaique/mosaique.dart';

/// Two-column shell for list/detail layouts.
///
/// Reused by: Users, potentially Products with details, etc.
class TwoColumnShell extends StatelessWidget {
  const TwoColumnShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(width: 300, child: Region('list')),
        VerticalDivider(width: 1),
        Expanded(child: Region('details')),
      ],
    );
  }
}
