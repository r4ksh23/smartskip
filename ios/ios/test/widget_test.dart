import 'package:flutter_test/flutter_test.dart';
import 'package:smartskip/screens/input_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('InputScreen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: InputScreen()));
    expect(find.text('Select Subject:'), findsOneWidget);
  });
}
