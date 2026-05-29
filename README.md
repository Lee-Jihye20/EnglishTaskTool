# 英文課題攻略APP

英文課題を効率的に進めるシンプルなアプリ。

## 機能

**読取タブ** - 画像をタップして選択 → 自動でOCR → 結果を長押しでコピー

**翻訳タブ** - 英文を入力 → 翻訳＋単語一覧表示 → 単語タップで個別翻訳

---

## セットアップ

```bash
# Flutter 3.44.0（FVM推奨）
fvm install
fvm flutter pub get

# iOS の場合
cd ios && pod install && cd ..
open ios/Runner.xcworkspace  # 署名設定を変更
```

---

## 使い方

| 操作 | 動作 |
|------|------|
| 画像エリアをタップ | カメラ/ギャラリーから選択 |
| 結果を長押し | コピー |
| 単語チップをタップ | 翻訳を表示 |

---

## 構成

```
lib/
├── main.dart           アプリ起動
├── pages/home_page.dart    メイン画面（タブ）
├── platform/app_ui.dart    プラットフォーム共通UI
├── theme/app_theme.dart    テーマ
└── services/
    ├── ocr_service.dart        OCR（ML Kit）
    └── translation_service.dart 翻訳API
```

---

## 注意

- **iOS シミュレータ**: ML Kit非対応。実機を使用
- **翻訳**: LibreTranslate / MyMemory（無料API、通信必要）
