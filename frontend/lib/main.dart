import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const GroundInkApp());
}

class GroundInkApp extends StatelessWidget {
  const GroundInkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GroundInk',
      theme: AppTheme.light,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
