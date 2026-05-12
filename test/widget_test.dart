import 'package:flutter_test/flutter_test.dart';
import 'package:apk_mahasiswa/main.dart';

void main() {
  testWidgets('CampusFlow app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusFlowApp());
    await tester.pump();

    // Verify splash screen shows app name
    expect(find.text('CampusFlow'), findsOneWidget);
  });
}
