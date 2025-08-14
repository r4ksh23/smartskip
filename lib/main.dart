import 'package:flutter/material.dart';
import 'screens/input_screen.dart';
import 'screens/timetable_screen.dart';

void main() {
  runApp(const SmartSkipApp());
}

class SmartSkipApp extends StatelessWidget {
  const SmartSkipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartSkip',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Colors.deepPurple,
          onPrimary: Colors.white,
          secondary: Colors.deepPurpleAccent,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Color(0xFF2C2C2C),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
        cardColor: const Color(0xFF2C2C2C),
        canvasColor: const Color(0xFF1E1E1E),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const InputScreen(),
      routes: {'/timetable': (_) => const TimetableScreen()},
    );
  }
}
