import 'package:flutter_test/flutter_test.dart';
import 'package:game_module/main.dart';

void main() {
  testWidgets('Game Module app loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ArcadeHubApp());
    expect(find.byType(ArcadeHubApp), findsOneWidget);
  });
}