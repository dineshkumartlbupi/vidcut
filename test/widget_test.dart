import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:novacut/main.dart';
import 'package:novacut/state/editor_provider.dart';

void main() {
  testWidgets('NovaCut app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => EditorProvider()),
        ],
        child: const NovaCutApp(),
      ),
    );

    expect(find.text('NovaCut'), findsOneWidget);
  });
}
