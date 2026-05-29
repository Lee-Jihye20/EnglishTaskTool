import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../pages/transcription_page.dart';
import '../pages/word_organize_page.dart';

/// TOPページ以外で表示する共通ヘッダー。
/// "文字起こしページ" と "単語整理ページ" へのリダイレクトボタンを配置する。
/// 画面占有率は最大10%に収める。
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  /// 現在表示しているページの種別。自分自身への遷移ボタンは無効化する。
  final AppPage current;

  const AppHeader({super.key, required this.current});

  @override
  Size get preferredSize => const Size.fromHeight(_headerHeight);

  // ヘッダーの基準高さ。build側で画面の10%を上限にクランプする。
  static const double _headerHeight = 64;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // 画面占有率を10%までに制限する（上端のセーフエリアは別途確保）。
    final maxBody = media.size.height * 0.10;
    final bodyHeight =
        _headerHeight.clamp(0.0, maxBody == 0 ? _headerHeight : maxBody);

    return Material(
      color: AppTheme.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: bodyHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppTheme.line),
            ),
          ),
          child: Row(
            children: [
              // ロゴ兼TOPへ戻るボタン
              _BrandButton(
                onTap: () => Navigator.of(context)
                    .popUntil((route) => route.isFirst),
              ),
              const Spacer(),
              _HeaderTab(
                label: '文字起こし',
                icon: Icons.document_scanner_outlined,
                selected: current == AppPage.transcription,
                onTap: () => _go(context, AppPage.transcription),
              ),
              const SizedBox(width: 6),
              _HeaderTab(
                label: '単語整理',
                icon: Icons.sort_by_alpha,
                selected: current == AppPage.wordOrganize,
                onTap: () => _go(context, AppPage.wordOrganize),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _go(BuildContext context, AppPage target) {
    if (target == current) return;
    final Widget page = switch (target) {
      AppPage.transcription => const TranscriptionPage(),
      AppPage.wordOrganize => const WordOrganizePage(),
    };
    // ヘッダー間の移動は置き換え遷移にしてスタックを浅く保つ。
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

/// ヘッダーを持つページの種別。
enum AppPage { transcription, wordOrganize }

class _BrandButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BrandButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(Icons.home_outlined, size: 20, color: AppTheme.ink),
            SizedBox(width: 6),
            Text(
              '攻略APP',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.ink,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _HeaderTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.ink : AppTheme.line,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppTheme.surface : AppTheme.ink,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppTheme.surface : AppTheme.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
