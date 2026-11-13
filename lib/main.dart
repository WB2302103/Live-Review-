import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/welcome_screen.dart';
import 'utils/theme_manager.dart';
import 'utils/language_manager.dart';

void main() {
  runApp(const LiveReviewApp());
}

class LiveReviewApp extends StatelessWidget {
  const LiveReviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();
    final langManager = LanguageManager();

    return AnimatedBuilder(
      animation: Listenable.merge([
        themeManager.themeModeNotifier,
        langManager.languageNotifier,
      ]),
      builder: (context, child) {
        return MaterialApp(
          title: langManager.getText('app_title'),
          debugShowCheckedModeBanner: false,
          themeMode: themeManager.themeModeNotifier.value,

          // --- LIGHT THEME (Rich Emerald Teal) ---
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F766E),
              primary: const Color(0xFF0F766E),
              secondary: const Color(0xFF34D399),
              surface: Colors.white,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            textTheme: GoogleFonts.poppinsTextTheme(
              ThemeData.light().textTheme,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              color: Colors.white,
            ),
            appBarTheme: AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              titleTextStyle: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ),

          // --- DARK THEME (Slate Obsidian) ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF0F766E),
              primary: const Color(0xFF34D399),
              secondary: const Color(0xFF38BDF8),
              surface: const Color(0xFF1E293B),
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            textTheme: GoogleFonts.poppinsTextTheme(
              ThemeData.dark().textTheme,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF334155), width: 1),
              ),
              color: const Color(0xFF1E293B),
            ),
            appBarTheme: AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              titleTextStyle: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ),

          home: const WelcomeScreen(),
        );
      },
    );
  }
}

// Backward-compatibility alias
typedef EventPulseApp = LiveReviewApp;
