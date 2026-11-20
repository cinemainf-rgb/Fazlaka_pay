import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/colors.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const FazlakaApp());
}

class FazlakaApp extends StatelessWidget {
  const FazlakaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fazlaka Pay Pro',
      theme: ThemeData(
        scaffoldBackgroundColor: bgColor,
        primaryColor: petrol,
        // استخدام خط عربي جميل
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: petrol,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
