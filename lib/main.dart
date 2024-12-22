import 'package:flutter/material.dart';
import 'package:cook_book_frontend/pages/splash.dart';

void main() => runApp(const CookBookApp());

class CookBookApp extends StatelessWidget {
  const CookBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
