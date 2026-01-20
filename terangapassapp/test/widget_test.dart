// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:teranga_pass/main.dart';

void main() {
  testWidgets('Teranga Pass app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TerangaPassApp());

    // Verify that the app name is displayed
    expect(find.text('Teranga Pass'), findsOneWidget);

    // Verify that SOS button is present
    expect(find.text('SOS'), findsOneWidget);

    // Verify that Alerte button is present
    expect(find.text('Alerte'), findsOneWidget);
  });
}
