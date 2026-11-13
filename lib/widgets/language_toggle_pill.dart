import 'package:flutter/material.dart';
import '../utils/language_manager.dart';

class LanguageTogglePill extends StatelessWidget {
  final Color? textColor;

  const LanguageTogglePill({super.key, this.textColor});

  @override
  Widget build(BuildContext context) {
    final languageManager = LanguageManager();

    return ValueListenableBuilder<String>(
      valueListenable: languageManager.languageNotifier,
      builder: (context, currentLang, child) {
        final isBn = currentLang == 'bn';

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            languageManager.toggleLanguage();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isBn ? FontWeight.normal : FontWeight.bold,
                    color: isBn ? Colors.white70 : Colors.white,
                  ),
                ),
                const Text(' | ', style: TextStyle(fontSize: 11, color: Colors.white54)),
                Text(
                  'বাংলা',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isBn ? FontWeight.bold : FontWeight.normal,
                    color: isBn ? const Color(0xFF34D399) : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
