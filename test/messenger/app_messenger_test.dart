import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

void main() {
  group('AppMessenger', () {
    late GlobalKey<ScaffoldMessengerState> key;
    late AppMessenger messenger;

    Widget buildApp() {
      key = GlobalKey<ScaffoldMessengerState>();
      messenger = AppMessenger(key);
      return MaterialApp(
        scaffoldMessengerKey: key,
        home: const Scaffold(body: SizedBox.expand()),
      );
    }

    testWidgets('showError shows a SnackBar', (tester) async {
      await tester.pumpWidget(buildApp());
      messenger.showError('Oops!');
      await tester.pump();
      expect(find.text('Oops!'), findsOneWidget);
    });

    testWidgets('showSuccess shows a SnackBar', (tester) async {
      await tester.pumpWidget(buildApp());
      messenger.showSuccess('Done!');
      await tester.pump();
      expect(find.text('Done!'), findsOneWidget);
    });

    testWidgets('showInfo shows a SnackBar', (tester) async {
      await tester.pumpWidget(buildApp());
      messenger.showInfo('FYI');
      await tester.pump();
      expect(find.text('FYI'), findsOneWidget);
    });

    testWidgets('showWarning shows a SnackBar', (tester) async {
      await tester.pumpWidget(buildApp());
      messenger.showWarning('Careful');
      await tester.pump();
      expect(find.text('Careful'), findsOneWidget);
    });

    testWidgets('hideCurrentSnackBar hides it', (tester) async {
      await tester.pumpWidget(buildApp());
      messenger.showError('Error');
      await tester.pump();
      messenger.hideCurrentSnackBar();
      await tester.pump();
      expect(find.text('Error'), findsNothing);
    });
  });
}
