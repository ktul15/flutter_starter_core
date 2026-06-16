import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

void main() {
  String? completed;
  String? changed;

  Widget buildOtp({int length = 4}) {
    completed = null;
    changed = null;
    return MaterialApp(
      home: Scaffold(
        body: OtpField(
          length: length,
          onCompleted: (v) => completed = v,
          onChanged: (v) => changed = v,
        ),
      ),
    );
  }

  testWidgets('renders correct number of cells', (tester) async {
    await tester.pumpWidget(buildOtp(length: 6));
    expect(find.byType(TextField), findsNWidgets(6));
  });

  testWidgets('onCompleted fires when all cells filled', (tester) async {
    await tester.pumpWidget(buildOtp(length: 4));
    final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byWidget(fields[i]));
      await tester.enterText(find.byWidget(fields[i]), (i + 1).toString());
      await tester.pump();
    }

    expect(completed, '1234');
  });

  testWidgets('onChanged fires on each keystroke', (tester) async {
    await tester.pumpWidget(buildOtp(length: 4));
    final first = find.byType(TextField).first;
    await tester.tap(first);
    await tester.enterText(first, '5');
    await tester.pump();
    expect(changed, isNotNull);
  });
}
