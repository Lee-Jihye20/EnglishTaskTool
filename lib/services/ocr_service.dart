import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// 画像から文字を取得するOCRサービス。
///
/// 要件では PaddleOCR / OpenAI API などが例示されているが、いずれも
/// 外部サーバー or APIキーが必要になる。ここでは端末内で完結し、
/// APIキー不要・オフライン動作する Google ML Kit のテキスト認識を採用する。
class OcrService {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  /// 画像ファイルのパスを受け取り、認識したテキストを返す。
  Future<String> recognizeFromPath(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(inputImage);
    return result.text;
  }

  void dispose() {
    _recognizer.close();
  }
}
