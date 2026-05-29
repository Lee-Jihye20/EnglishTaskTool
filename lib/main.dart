import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';

void main() {
  runApp(const EngTaskApp());
}

class EngTaskApp extends StatelessWidget {
  const EngTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '英文課題攻略APP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppShell(),
    );
  }
}
