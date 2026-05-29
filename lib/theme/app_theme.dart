import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// アプリ全体のデザイン定義。
/// 白と黒に近い色のみをベースにしたモダンなモノトーン基調。
class AppTheme {
  AppTheme._();

  /// Apple HIG 推奨の最小タップ領域。
  static const double minTouchTarget = 44;

  // ベースカラー（白と黒に近い色のみ）
  static const Color background = Color(0xFFF7F7F8); // ほぼ白
  static const Color surface = Color(0xFFFFFFFF); // 純白
  static const Color ink = Color(0xFF111114); // ほぼ黒
  static const Color inkSoft = Color(0xFF5C5C66); // 落ち着いたグレー
  static const Color line = Color(0xFFE2E2E6); // 罫線用の薄いグレー
  static const Color disabledFill = Color(0xFFEDEDF0);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: ink,
        onPrimary: surface,
        secondary: ink,
        onSecondary: surface,
        surface: surface,
        onSurface: ink,
        outline: line,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: surface,
          elevation: 0,
          minimumSize: const Size(double.infinity, minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(double.infinity, minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: const BorderSide(color: ink, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: minTouchTextButton),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        isDense: false,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ink, width: 1.6),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: line),
        ),
      ),
    );
  }

  static ButtonStyle get minTouchTextButton => TextButton.styleFrom(
        foregroundColor: ink,
        minimumSize: const Size(minTouchTarget, minTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );

  /// iOS / macOS 向け Cupertino テーマ。
  /// iOS 26+ ではシステムのグループ背景・ガラス風バーに寄せる。
  static CupertinoThemeData cupertino(BuildContext context) {
    final groupedBg = CupertinoColors.systemGroupedBackground.resolveFrom(context);
    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: CupertinoColors.activeBlue,
      barBackgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
      scaffoldBackgroundColor: groupedBg,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontSize: 17,
          color: CupertinoColors.label.resolveFrom(context),
          letterSpacing: -0.4,
        ),
        navTitleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.label.resolveFrom(context),
          letterSpacing: -0.4,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: CupertinoColors.label.resolveFrom(context),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
