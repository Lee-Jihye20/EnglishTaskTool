// 英文課題攻略APP の基本的なスモークテスト。

import 'package:flutter_test/flutter_test.dart';

import 'package:eng_task_app/main.dart';

void main() {
  testWidgets('TOPページのタイトルとメニューが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const EngTaskApp());

    // タイトル
    expect(find.text('英文課題攻略APP'), findsOneWidget);
    // 各ページへのリダイレクトボタン
    expect(find.text('文字起こしページ'), findsOneWidget);
    expect(find.text('単語整理ページ'), findsOneWidget);
  });
}
