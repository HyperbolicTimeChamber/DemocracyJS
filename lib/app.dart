import 'package:flutter/material.dart';
import 'package:democracy_js/core/theme/app_theme.dart';
import 'package:democracy_js/features/poll/presentation/screens/home_screen.dart';

class DemocracyJSApp extends StatelessWidget {
  const DemocracyJSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DemocracyJS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
