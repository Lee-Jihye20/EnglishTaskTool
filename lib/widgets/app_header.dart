import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// ヘッダーを持つページの種別。
enum AppPage {
  transcription,
  wordOrganize;

  int get tabIndex => switch (this) {
        AppPage.transcription => 0,
        AppPage.wordOrganize => 1,
      };

  String get sectionLabel => switch (this) {
        AppPage.transcription => '文字起こし',
        AppPage.wordOrganize => '単語整理',
      };
}

/// 現在のセクションを「攻略APP | 〇〇」で示すヘッダー。
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final AppPage current;

  const AppHeader({super.key, required this.current});

  static const double _headerHeight = 56;

  @override
  Size get preferredSize => const Size.fromHeight(_headerHeight);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: _headerHeight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.line)),
          ),
          child: _Breadcrumb(current: current),
        ),
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  final AppPage current;

  const _Breadcrumb({required this.current});

  @override
  Widget build(BuildContext context) {
    return AppBreadcrumbText(segments: ['攻略APP', current.sectionLabel]);
  }
}

/// 「攻略APP | 〇〇 | …」形式のパンくず表示。
class AppBreadcrumbText extends StatelessWidget {
  final List<String> segments;

  const AppBreadcrumbText({super.key, required this.segments});

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();

    final children = <Widget>[];
    for (var i = 0; i < segments.length; i++) {
      if (i > 0) {
        children.add(const _Separator());
      }
      final isLast = i == segments.length - 1;
      children.add(
        Text(
          segments[i],
          style: TextStyle(
            fontSize: 16,
            fontWeight: isLast ? FontWeight.w800 : FontWeight.w600,
            color: isLast ? AppTheme.ink : AppTheme.inkSoft,
          ),
        ),
      );
    }

    return Row(children: children);
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '|',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppTheme.line,
        ),
      ),
    );
  }
}

/// サブ画面用のパンくず付き AppBar。
class AppBreadcrumbBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> segments;

  const AppBreadcrumbBar({super.key, required this.segments});

  @override
  Size get preferredSize => const Size.fromHeight(AppHeader._headerHeight);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: AppHeader._headerHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.line)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: AppTheme.minTouchTarget,
                height: AppTheme.minTouchTarget,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back),
                  color: AppTheme.ink,
                ),
              ),
              Expanded(
                child: AppBreadcrumbText(segments: segments),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// コピーなど小さめの操作ボタン用（最小 44×44）。
class AppIconTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  const AppIconTextButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: AppTheme.minTouchTextButton,
    );
  }
}
