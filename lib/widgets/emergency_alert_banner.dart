import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmergencyAlertBanner extends StatefulWidget {
  final List<Map<String, dynamic>> alerts;

  const EmergencyAlertBanner({super.key, required this.alerts});

  @override
  State<EmergencyAlertBanner> createState() => _EmergencyAlertBannerState();
}

class _EmergencyAlertBannerState extends State<EmergencyAlertBanner> {
  @override
  void initState() {
    super.initState();
    if (widget.alerts.isNotEmpty) {
      _triggerAlertSound();
    }
  }

  @override
  void didUpdateWidget(covariant EmergencyAlertBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alerts.length > oldWidget.alerts.length) {
      _triggerAlertSound();
    }
  }

  void _triggerAlertSound() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: widget.alerts.map((alert) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7F1D1D), Color(0xFF991B1B)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF87171), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert['desc'] as String,
                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
