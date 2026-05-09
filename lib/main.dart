import 'package:flutter/material.dart';
import 'package:round_timer_app/screens/home/home_screen.dart';
import 'package:round_timer_app/theme/app_theme.dart';

void main() {
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoundFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
