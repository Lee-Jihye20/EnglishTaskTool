import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../services/translation_service.dart';
import '../widgets/app_header.dart';
import 'word_list_page.dart';

/// 単語整理ページの本文。
/// 1. 英文入力ボックス（値の受け渡し元）
/// 2. 英文出力ボックス（disabled・翻訳結果などの出力先）
/// 3. 完全翻訳ボタン（入力全文を翻訳して出力ボックスへ）
/// 4. 単語整理ボタン（単語一覧のCanvasを開く）
class WordOrganizePage extends StatefulWidget {
  const WordOrganizePage({super.key});

  @override
  State<WordOrganizePage> createState() => _WordOrganizePageState();
}

class _WordOrganizePageState extends State<WordOrganizePage> {
  final TextEditingController _input = TextEditingController();
  final TextEditingController _output = TextEditingController();
  final TranslationService _translator = TranslationService();

  bool _translating = false;

  @override
  void dispose() {
    _input.dispose();
    _output.dispose();
    super.dispose();
  }

  Future<void> _translateAll() async {
    final text = _input.text.trim();
    if (text.isEmpty) {
      _showSnack('英文を入力してください。');
      return;
    }
    setState(() {
      _translating = true;
      _output.text = '翻訳中…';
    });
    try {
      final translated = await _translator.translateEnToJa(text);
      if (!mounted) return;
      setState(() => _output.text = translated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _output.text = '');
      _showSnack('翻訳に失敗しました: $e');
    } finally {
      if (mounted) setState(() => _translating = false);
    }
  }

  void _openWordList() {
    final text = _input.text.trim();
    if (text.isEmpty) {
      _showSnack('英文を入力してください。');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WordListPage(
          sourceText: text,
          translator: _translator,
        ),
      ),
    );
  }

  void _copyInput() {
    if (_input.text.trim().isEmpty) {
      _showSnack('コピーする文字がありません。');
      return;
    }
    Clipboard.setData(ClipboardData(text: _input.text));
    _showSnack('入力をコピーしました。');
  }

  void _copyOutput() {
    if (_output.text.trim().isEmpty) {
      _showSnack('コピーする文字がありません。');
      return;
    }
    Clipboard.setData(ClipboardData(text: _output.text));
    _showSnack('出力をコピーしました。');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BoxLabel(
            label: '英文入力ボックス',
            onCopy: _copyInput,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _input,
            minLines: 5,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: 'ここに英文を貼り付け・入力してください。',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _translating ? null : _translateAll,
            icon: _translating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.surface,
                    ),
                  )
                : const Icon(Icons.translate),
            label: const Text('完全翻訳'),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _openWordList,
            icon: const Icon(Icons.sort_by_alpha),
            label: const Text('単語整理'),
          ),
          const SizedBox(height: 24),
          _BoxLabel(
            label: '英文出力ボックス',
            onCopy: _copyOutput,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _output,
            enabled: false,
            readOnly: true,
            minLines: 5,
            maxLines: null,
            style: const TextStyle(color: AppTheme.ink),
            decoration: const InputDecoration(
              filled: true,
              fillColor: AppTheme.disabledFill,
              hintText: '翻訳などの結果がここに表示されます。',
            ),
          ),
        ],
      ),
    );
  }
}

class _BoxLabel extends StatelessWidget {
  final String label;
  final VoidCallback onCopy;
  const _BoxLabel({required this.label, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.ink,
          ),
        ),
        const Spacer(),
        AppIconTextButton(
          onPressed: onCopy,
          icon: Icons.copy,
          label: 'コピー',
        ),
      ],
    );
  }
}
