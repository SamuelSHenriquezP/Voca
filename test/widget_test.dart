import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voca_app/core/widgets/voca_button.dart';
import 'package:voca_app/core/widgets/voca_card.dart';

void main() {
  testWidgets('VocaButton renders and triggers tactile tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: VocaButton(
              text: 'START LESSON',
              variant: VocaButtonVariant.success,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('START LESSON'), findsOneWidget);
    await tester.tap(find.text('START LESSON'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('VocaCard renders child content cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VocaCard(
            child: Text('Card Content Test'),
          ),
        ),
      ),
    );

    expect(find.text('Card Content Test'), findsOneWidget);
  });
}
