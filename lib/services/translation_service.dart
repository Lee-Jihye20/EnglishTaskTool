import 'dart:convert';

import 'package:http/http.dart' as http;

/// 翻訳サービス。
///
/// 要件にある LibreTranslate（オープンソース翻訳API）を第一候補として利用する。
/// 公開インスタンスは不安定なことがあるため、失敗時は無料・APIキー不要の
/// MyMemory 翻訳APIにフォールバックする。
class TranslationService {
  /// LibreTranslate の公開エンドポイント。
  /// 自前/別のインスタンスを使う場合はここを差し替える。
  final String libreTranslateUrl;

  TranslationService({
    this.libreTranslateUrl = 'https://libretranslate.com/translate',
  });

  /// 英語(en) -> 日本語(ja) へ翻訳する。
  Future<String> translateEnToJa(String text) {
    return translate(text, source: 'en', target: 'ja');
  }

  /// 任意の言語間で翻訳する。
  Future<String> translate(
    String text, {
    required String source,
    required String target,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';

    try {
      return await _viaLibreTranslate(trimmed, source, target);
    } catch (_) {
      // LibreTranslate が失敗したらフォールバックする。
      return await _viaMyMemory(trimmed, source, target);
    }
  }

  Future<String> _viaLibreTranslate(
    String text,
    String source,
    String target,
  ) async {
    final res = await http
        .post(
          Uri.parse(libreTranslateUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'q': text,
            'source': source,
            'target': target,
            'format': 'text',
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('LibreTranslate error: ${res.statusCode}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    final translated = data['translatedText'];
    if (translated is! String || translated.isEmpty) {
      throw Exception('LibreTranslate empty response');
    }
    return translated;
  }

  /// 無料・APIキー不要のフォールバック。1リクエストあたりの長さ制限があるため
  /// 長文は分割して送信する。
  Future<String> _viaMyMemory(
    String text,
    String source,
    String target,
  ) async {
    const maxLen = 480; // MyMemory の1リクエスト上限に余裕を持たせる
    final chunks = _splitText(text, maxLen);
    final buffer = StringBuffer();

    for (final chunk in chunks) {
      final uri = Uri.https('api.mymemory.translated.net', '/get', {
        'q': chunk,
        'langpair': '$source|$target',
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) {
        throw Exception('MyMemory error: ${res.statusCode}');
      }
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final translated = data['responseData']?['translatedText'];
      if (translated is String) {
        buffer.write(translated);
      }
    }
    return buffer.toString();
  }

  /// 文章を文・空白の境界でできるだけ自然に分割する。
  List<String> _splitText(String text, int maxLen) {
    if (text.length <= maxLen) return [text];

    final result = <String>[];
    final sentences = text.split(RegExp(r'(?<=[.!?。！？])\s+'));
    final current = StringBuffer();

    for (final sentence in sentences) {
      if (current.length + sentence.length + 1 > maxLen &&
          current.isNotEmpty) {
        result.add(current.toString());
        current.clear();
      }
      if (sentence.length > maxLen) {
        // 1文が長すぎる場合は強制的に分割。
        for (var i = 0; i < sentence.length; i += maxLen) {
          result.add(
            sentence.substring(
              i,
              i + maxLen > sentence.length ? sentence.length : i + maxLen,
            ),
          );
        }
      } else {
        if (current.isNotEmpty) current.write(' ');
        current.write(sentence);
      }
    }
    if (current.isNotEmpty) result.add(current.toString());
    return result;
  }
}
