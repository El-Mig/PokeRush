import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // We'll handle orientation locking in the GameScreen,
  // but keep the app orientation-aware for the Home and Results screens.
  runApp(
    const ProviderScope(
      child: PokeRushApp(),
    ),
  );
}

class PokeRushApp extends StatelessWidget {
  const PokeRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeRush - Heads Up',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFBC2C2C), // Muted Crimson
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFBC2C2C),
          primary: const Color(0xFFBC2C2C),
          secondary: const Color(0xFFD4A017), // Golden Yellow
          surface: const Color(0xFF1A1A1A),
          background: const Color(0xFF1A1A1A),
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
