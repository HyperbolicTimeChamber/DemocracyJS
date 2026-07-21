import 'package:flutter/material.dart';
import 'package:local_poll/core/theme/app_theme.dart';
import 'package:local_poll/features/poll/presentation/screens/home_screen.dart';

class LocalPollApp extends StatelessWidget {
  const LocalPollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Poll',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
