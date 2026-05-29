import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_header.dart';

/// 画面下部のタブ切り替え（文字起こし / 単語整理）。
class AppFooterNav extends StatelessWidget {
  final AppPage current;
  final ValueChanged<AppPage> onChanged;

  const AppFooterNav({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.line)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _FooterTab(
                  label: '文字起こし',
                  icon: Icons.document_scanner_outlined,
                  selected: current == AppPage.transcription,
                  onTap: () => onChanged(AppPage.transcription),
                ),
              ),
              Expanded(
                child: _FooterTab(
                  label: '単語整理',
                  icon: Icons.sort_by_alpha,
                  selected: current == AppPage.wordOrganize,
                  onTap: () => onChanged(AppPage.wordOrganize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FooterTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.ink : AppTheme.inkSoft;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: AppTheme.minTouchTarget + 8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
