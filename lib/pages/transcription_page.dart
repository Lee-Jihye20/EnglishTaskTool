import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';
import '../services/ocr_service.dart';
import '../widgets/app_header.dart';

/// 文字起こしページ。
/// "画像選択" / "写真を撮影" ボタンから画像を取得し、OCRで文字を抽出して
/// テキストボックスに表示する。コピーボタンも配置する。
class TranscriptionPage extends StatefulWidget {
  const TranscriptionPage({super.key});

  @override
  State<TranscriptionPage> createState() => _TranscriptionPageState();
}

class _TranscriptionPageState extends State<TranscriptionPage> {
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocr = OcrService();
  final TextEditingController _textController = TextEditingController();

  File? _image;
  bool _processing = false;

  @override
  void dispose() {
    _ocr.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 95,
      );
      if (picked == null) return;

      setState(() {
        _image = File(picked.path);
        _processing = true;
        _textController.clear();
      });

      final text = await _ocr.recognizeFromPath(picked.path);
      if (!mounted) return;
      setState(() {
        _textController.text = text;
        _processing = false;
      });

      if (text.trim().isEmpty) {
        _showSnack('文字を検出できませんでした。別の画像をお試しください。');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _processing = false);
      _showSnack('画像の処理に失敗しました: $e');
    }
  }

  void _copy() {
    final text = _textController.text;
    if (text.trim().isEmpty) {
      _showSnack('コピーする文字がありません。');
      return;
    }
    Clipboard.setData(ClipboardData(text: text));
    _showSnack('コピーしました。');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: const AppHeader(current: AppPage.transcription),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionTitle(
                title: '画像から文字起こし',
                subtitle: '画像を選ぶか写真を撮ると、英文を自動で読み取ります。',
              ),
              const SizedBox(height: 20),
              // 画面中央のColumn：画像選択 / 写真を撮影
              ElevatedButton.icon(
                onPressed: _processing ? null : () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('画像選択'),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _processing ? null : () => _pick(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('写真を撮影'),
              ),
              const SizedBox(height: 24),
              if (_image != null) _ImagePreview(image: _image!),
              if (_image != null) const SizedBox(height: 20),
              _ResultBox(
                controller: _textController,
                processing: _processing,
                onCopy: _copy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File image;
  const _ImagePreview({required this.image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.line),
          borderRadius: BorderRadius.circular(14),
        ),
        constraints: const BoxConstraints(maxHeight: 240),
        width: double.infinity,
        child: Image.file(image, fit: BoxFit.contain),
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  final TextEditingController controller;
  final bool processing;
  final VoidCallback onCopy;

  const _ResultBox({
    required this.controller,
    required this.processing,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text(
              '読み取り結果',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
              ),
            ),
            const Spacer(),
            if (processing)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              TextButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('コピー'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.ink),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: null,
          minLines: 6,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: processing
                ? '読み取り中…'
                : '画像を選択すると、ここに読み取った文字が表示されます。',
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: AppTheme.inkSoft),
        ),
      ],
    );
  }
}
