import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mitugym_scanner_flutter/main.dart';

void main() {
  testWidgets('MituGym Scanner app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MituGymScannerApp()));

    // Verify that the app title appears
    expect(find.text('MituGym Scanner'), findsOneWidget);
  });
}
