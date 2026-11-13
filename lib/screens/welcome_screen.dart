import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/live_review_logo.dart';
import '../widgets/language_toggle_pill.dart';
import '../utils/page_transitions.dart';
import '../utils/theme_manager.dart';
import '../utils/language_manager.dart';
import 'participant/participant_home_screen.dart';
import 'organizer/organizer_dashboard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _buttonsSlideAnimation;
  late Animation<double> _buttonsFadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // 1. Logo Scale & Fade
    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    // 2. Title & Subtitle Slide & Fade
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.70, curve: Curves.easeOut),
      ),
    );

    // 3. Action Buttons Slide & Fade
    _buttonsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _buttonsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.55, 0.95, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager().isDarkMode || Theme.of(context).brightness == Brightness.dark;
    final langManager = LanguageManager();

    final bgColors = isDark
        ? const [Color(0xFF0F172A), Color(0xFF020617)] // Deep Obsidian Dark
        : const [Color(0xFF0F766E), Color(0xFF111827)]; // Rich Teal Light

    return ValueListenableBuilder<String>(
      valueListenable: langManager.languageNotifier,
      builder: (context, currentLang, child) {
        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: bgColors,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Action Bar with Language Toggle Pill & Theme Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const LanguageTogglePill(),
                        IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              ThemeManager().toggleTheme();
                            });
                          },
                          tooltip: 'Toggle Dark / Light Theme',
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Animated Logo
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _logoFadeAnimation,
                          child: ScaleTransition(
                            scale: _logoScaleAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(isDark ? 0.08 : 0.15),
                                Colors.white.withOpacity(isDark ? 0.02 : 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                              color: const Color(0xFF34D399).withOpacity(isDark ? 0.5 : 0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF34D399).withOpacity(isDark ? 0.3 : 0.2),
                                blurRadius: 32,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const LiveReviewLogo(size: 110, animated: true),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Animated Text
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _textFadeAnimation,
                          child: SlideTransition(
                            position: _textSlideAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            langManager.getText('app_title'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            langManager.getText('tagline'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                              height: 1.5,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Animated Buttons
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _buttonsFadeAnimation,
                          child: SlideTransition(
                            position: _buttonsSlideAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                FadeSlidePageRoute(widget: const ParticipantHomeScreen()),
                              );
                            },
                            icon: const Icon(Icons.qr_code_scanner_rounded, size: 22),
                            label: Text(
                              langManager.getText('join_as_participant'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF34D399),
                              foregroundColor: const Color(0xFF111827),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                FadeSlidePageRoute(widget: const OrganizerDashboardScreen()),
                              );
                            },
                            icon: const Icon(Icons.admin_panel_settings_rounded, size: 22, color: Colors.white),
                            label: Text(
                              langManager.getText('organizer_portal'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white30, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
