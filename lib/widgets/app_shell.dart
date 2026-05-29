import 'package:flutter/material.dart';

import '../pages/transcription_page.dart';
import '../pages/word_organize_page.dart';
import '../theme/app_theme.dart';
import 'app_footer_nav.dart';
import 'app_header.dart';
import 'dismiss_keyboard.dart';

/// 文字起こし / 単語整理の2画面をフッタータブで切り替えるシェル。
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppPage _current = AppPage.transcription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppHeader(current: _current),
      body: DismissKeyboard(
        child: IndexedStack(
          index: _current.tabIndex,
          children: const [
            TranscriptionPage(),
            WordOrganizePage(),
          ],
        ),
      ),
      bottomNavigationBar: AppFooterNav(
        current: _current,
        onChanged: (page) => setState(() => _current = page),
      ),
    );
  }
}
