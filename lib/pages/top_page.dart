import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'transcription_page.dart';
import 'word_organize_page.dart';

/// TOPページ。
/// 画面中心の上よりに "英文課題攻略APP" をh1サイズで表示し、
/// その下にColumnで各ページへのリダイレクトボタンを配置する。
class TopPage extends StatelessWidget {
  const TopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 画面中心より少し上に配置するため、上側に余白を多めに取る。
              const Spacer(flex: 3),
              const Text(
                '英文課題攻略APP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  // h1相当のサイズ
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '英文課題を、もっと効率的に。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.inkSoft,
                ),
              ),
              const SizedBox(height: 40),
              _MenuButton(
                icon: Icons.document_scanner_outlined,
                label: '文字起こしページ',
                description: '写真から英文を読み取る',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TranscriptionPage(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _MenuButton(
                icon: Icons.sort_by_alpha,
                label: '単語整理ページ',
                description: '翻訳・単語の整理を行う',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WordOrganizePage(),
                  ),
                ),
              ),
              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.line),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.ink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.surface, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}
