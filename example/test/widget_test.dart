import 'package:flutter_test/flutter_test.dart';
import 'package:smart_player_kit_example/main.dart';

void main() {
  testWidgets('SmartPlayerKit example app smoke test', (WidgetTester tester) async {
    // App build karo
    await tester.pumpWidget(const SmartPlayerExampleApp());
    await tester.pump();

    // HomeScreen ka title dikh raha hai
    expect(find.text('SmartPlayerKit Demo'), findsOneWidget);

    // Saare demo tiles present hain
    expect(find.text('🎬 Basic Video Player'), findsOneWidget);
    expect(find.text('📺 HLS Stream'), findsOneWidget);
    expect(find.text('🔄 Auto Resume'), findsOneWidget);
    expect(find.text('📱 Reels Player'), findsOneWidget);
    expect(find.text('🎵 Audio / Podcast'), findsOneWidget);
    expect(find.text('🎨 Netflix Theme'), findsOneWidget);
  });
}