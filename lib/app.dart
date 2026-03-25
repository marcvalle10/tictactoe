import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_gate.dart';

class TicTacticApp extends StatelessWidget {
  const TicTacticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TicTacToe',
      theme: AppTheme.darkTheme,
      home: const HomeGate(),
    );
  }
}
