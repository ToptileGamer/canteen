import 'package:flutter_test/flutter_test.dart';
import 'package:canteen_app/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CanteenApp());
    await tester.pumpAndSettle();

    // Verify the app title is shown
    expect(find.text('CampusCanteen'), findsOneWidget);
    expect(find.text('Skip the Queue, Grab Your Food!'), findsOneWidget);

    // Verify login form elements exist
    expect(find.text('Login'), findsAtLeast(1));
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
