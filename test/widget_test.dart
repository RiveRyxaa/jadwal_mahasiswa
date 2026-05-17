import 'package:flutter_test/flutter_test.dart';
import 'package:apk_mahasiswa/main.dart';

void main() {
  testWidgets('SobatKuliah app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SobatKuliahApp());
    await tester.pump();

    // Verify splash screen shows app name
    expect(find.text('SobatKuliah'), findsOneWidget);
  });
}
