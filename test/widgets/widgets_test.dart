import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('PrimaryButton', () {
    testWidgets('shows label and fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(
        PrimaryButton(label: 'Sign in', onPressed: () => taps++),
      ));

      expect(find.text('Sign in'), findsOneWidget);
      await tester.tap(find.byType(PrimaryButton));
      expect(taps, 1);
    });

    testWidgets('loading shows spinner and blocks taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(
        PrimaryButton(label: 'Sign in', isLoading: true, onPressed: () => taps++),
      ));

      expect(find.text('Sign in'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(PrimaryButton));
      expect(taps, 0);
    });
  });

  testWidgets('PasswordField obscures then reveals on toggle', (tester) async {
    await tester.pumpWidget(_wrap(const PasswordField()));

    TextField field() => tester.widget<TextField>(find.byType(TextField));
    expect(field().obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(field().obscureText, isFalse);
  });

  testWidgets('AppTextField surfaces validator errors', (tester) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(_wrap(Form(
      key: key,
      child: AppTextField(label: 'Email', validator: Validators.required()),
    )));

    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('This field is required'), findsOneWidget);
  });

  testWidgets('EmptyState renders action and fires it', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(EmptyState(
      title: 'Nothing here',
      message: 'Add your first item',
      actionLabel: 'Add',
      onAction: () => tapped = true,
    )));

    expect(find.text('Nothing here'), findsOneWidget);
    await tester.tap(find.text('Add'));
    expect(tapped, isTrue);
  });

  testWidgets('ErrorStateView.fromException shows safe type-based message', (tester) async {
    var retried = false;
    await tester.pumpWidget(_wrap(ErrorStateView.fromException(
      const ApiException(type: ApiErrorType.server, message: 'DB error: connection refused'),
      onRetry: () => retried = true,
    )));

    // Raw error.message must NOT appear — it may contain server internals.
    expect(find.text('DB error: connection refused'), findsNothing);
    // Safe fallback for ApiErrorType.server:
    expect(find.text('Server error. Try again later.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('ErrorStateView.fromException message override shows custom copy', (tester) async {
    await tester.pumpWidget(_wrap(ErrorStateView.fromException(
      const ApiException(type: ApiErrorType.network, message: 'socket hang up'),
      message: 'No internet. Check your Wi-Fi.',
    )));

    expect(find.text('No internet. Check your Wi-Fi.'), findsOneWidget);
    expect(find.text('socket hang up'), findsNothing);
  });

  testWidgets('AppLoader renders message', (tester) async {
    await tester.pumpWidget(_wrap(const AppLoader(message: 'Loading…')));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading…'), findsOneWidget);
  });
}
