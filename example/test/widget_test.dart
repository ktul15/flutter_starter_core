import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example boots to the login screen', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('No attempt yet'), findsOneWidget);
  });
}
