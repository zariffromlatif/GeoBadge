import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geobadge/features/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen shows activation fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('ACTIVATION'), findsOneWidget);
    expect(find.text('EMPLOYEE ID'), findsOneWidget);
  });
}
