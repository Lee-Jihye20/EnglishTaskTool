// 英文課題攻略APP の基本的なスモークテスト。

import 'package:flutter_test/flutter_test.dart';

import 'package:eng_task_app/main.dart';

void main() {
  testWidgets('起動時に文字起こしタブとフッターが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const EngTaskApp());

    expect(find.text('攻略APP'), findsOneWidget);
    expect(find.text('文字起こし'), findsWidgets);
    expect(find.text('単語整理'), findsWidgets);
    expect(find.text('画像選択'), findsOneWidget);
  });
}
