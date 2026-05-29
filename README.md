# 英文課題攻略APP (eng_task_app)

英文課題を効率的に進めるための補助アプリ。

- **文字起こしページ**: 画像を選択 / 撮影して、端末内OCR（Google ML Kit）で英文を読み取り
- **単語整理ページ**: 英文の全文翻訳、単語の一意化・並べ替え・検索・タップ翻訳

---

## 必要なもの

| 項目 | バージョン / 内容 |
|------|------------------|
| Flutter | **3.44.0**（`.fvmrc` で固定。FVM 推奨） |
| Dart | 3.12.0（Flutter 3.44.0 同梱） |
| Xcode | iOSビルドする場合（Xcode 26.x で動作確認） |
| Android SDK | minSdk 21 以上（ML Kit の要件） |
| CocoaPods | iOSビルドする場合（`sudo gem install cocoapods`） |

> APIキーは不要です。OCRは端末内（ML Kit）、翻訳は LibreTranslate / MyMemory の無料APIを使用します。

---

## 初期セットアップ

### 1. clone

```bash
git clone https://github.com/Lee-Jihye20/EnglishTaskTool.git
cd EnglishTaskTool
```

### 2. Flutter を用意する（FVM 推奨）

このプロジェクトは Flutter **3.44.0** に固定されています（`.fvmrc`）。

**FVM を使う場合:**
```bash
dart pub global activate fvm   # 未インストールなら
fvm install                    # .fvmrc の 3.44.0 を取得
fvm flutter pub get
```
以降、コマンドは `fvm flutter ...` の形で実行します。

**FVM を使わない場合:**
Flutter 3.44.0 を入れて（または近いバージョンで）、
```bash
flutter pub get
```

### 3. 依存パッケージ取得

```bash
flutter pub get        # FVMなら fvm flutter pub get
```

### 4. 動作確認

```bash
flutter devices        # 接続中の端末/エミュレータを確認
flutter run            # 端末を選んで起動
```

---

## プラットフォーム別の注意

### Android（一番手軽）
- 追加設定なしで動きます。エミュレータでも実機でもOK。
- カメラ・写真の権限はマニフェストに設定済み。

### iOS

1. **CocoaPods の取得**（Pods はリポジトリに含めていないため必須）:
   ```bash
   cd ios
   pod install
   cd ..
   ```

2. **署名設定を自分のものに変更**（必須）:
   `ios/Runner.xcodeproj` には開発元の Apple ID チーム・Bundle ID が入っています。**自分の環境用に変更してください。**
   ```bash
   open ios/Runner.xcworkspace
   ```
   Xcode の **Runner → Signing & Capabilities** で:
   - **Team**: 自分の Apple ID を選択
   - **Bundle Identifier**: 世界で一意な値に変更（例 `com.自分の名前.engTaskApp`）

3. 実機で実行:
   ```bash
   flutter run
   ```
   無料 Apple ID の場合、実機アプリの署名は **7日間** で切れます。切れたら再度 `flutter run` で入れ直してください。

> ⚠️ **Apple Silicon Mac の iOSシミュレータでは動きません。**
> Google ML Kit が arm64シミュレータ用のバイナリを提供していないためです。iOSで試す場合は **実機** を使ってください。

---

## プロジェクト構成

```
lib/
├── main.dart                       アプリ起動・ルーティング
├── theme/app_theme.dart            白黒基調のテーマ
├── widgets/app_header.dart         共通ヘッダー（各ページ遷移）
├── pages/
│   ├── top_page.dart               TOPページ
│   ├── transcription_page.dart     文字起こしページ
│   ├── word_organize_page.dart     単語整理ページ
│   └── word_list_page.dart         単語一覧（並べ替え/検索/タップ翻訳）
└── services/
    ├── ocr_service.dart            画像→文字（ML Kit）
    └── translation_service.dart    翻訳（LibreTranslate + MyMemory）
```

---

## よくあるトラブル

| 症状 | 対処 |
|------|------|
| `pod install` でエラー | `cd ios && pod repo update && pod install` |
| iOSビルドで署名エラー | 上記「署名設定を自分のものに変更」を実施 |
| シミュレータでビルド失敗（ML Kit / arm64） | iOS実機を使う（Apple Silicon の制限） |
| `flutter run` のバージョン不一致 | `.fvmrc` の 3.44.0 を使う（`fvm use`） |
| 翻訳が失敗する | 通信環境を確認（LibreTranslate公開サーバが不安定な場合あり。自動でMyMemoryにフォールバック） |
