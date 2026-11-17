import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/event_model.dart';
import '../../services/mock_data_service.dart';
import '../../utils/page_transitions.dart';
import '../../utils/language_manager.dart';
import 'event_details_screen.dart';

class CameraScannerScreen extends StatefulWidget {
  const CameraScannerScreen({super.key});

  @override
  State<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late MobileScannerController _scannerController;
  final MockDataService _dataService = MockDataService();
  bool _isScanning = true;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _scannerController = MobileScannerController(
      torchEnabled: false,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onQrDetected(Event event) {
    if (!_isScanning) return;
    setState(() {
      _isScanning = false;
    });

    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399)),
            const SizedBox(width: 10),
            Expanded(child: Text('Scanned QR for: ${event.title}')),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1000),
      ),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          FadeSlidePageRoute(widget: EventDetailsScreen(event: event)),
        );
      }
    });
  }

  void _showEventSelector() {
    HapticFeedback.lightImpact();
    final events = _dataService.getEvents();
    final lang = LanguageManager();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF0F766E), size: 24),
                      const SizedBox(width: 10),
                      Text(
                        lang.getText('select_event_scan'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (events.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text(lang.getText('no_events_available'))),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: events.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCFBF1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF0F766E)),
                            ),
                            title: Text(
                              event.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle: Text('${lang.getText("venue")}: ${event.venue}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34D399).withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'SCAN',
                                style: TextStyle(
                                  color: Color(0xFF0F766E),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _onQrDetected(event);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageManager();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(lang.getText('camera_scanner')),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _isFlashOn ? const Color(0xFFF59E0B) : Colors.white70,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isFlashOn = !_isFlashOn;
                _scannerController.toggleTorch();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFlashOn ? 'Flashlight Enabled' : 'Flashlight Disabled'),
                  duration: const Duration(milliseconds: 800),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Real Mobile Camera Feed (MobileScanner)
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final code = barcode.rawValue;
                if (code != null) {
                  final event = _dataService.getEventByCode(code);
                  if (event != null) {
                    _onQrDetected(event);
                    break;
                  } else {
                    // Fallback for testing: if any QR is scanned, pick the first available event
                    final events = _dataService.getEvents();
                    if (events.isNotEmpty) {
                      _onQrDetected(events.first);
                      break;
                    }
                  }
                }
              }
            },
          ),

          // 2. Dark Overlay Vignette
          Container(
            color: Colors.black.withOpacity(0.35),
          ),

          // 3. High-Tech Viewfinder & Overlay UI
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // HUD Scanner Active Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF34D399).withOpacity(0.6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF34D399),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF34D399).withOpacity(0.8),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'REAL CAMERA SCANNER ACTIVE',
                          style: TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // High-Tech Scanner Viewfinder with Custom Laser Overlay
                  GestureDetector(
                    onTap: _showEventSelector,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Container(
                          width: 270,
                          height: 270,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF34D399), width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF34D399).withOpacity(0.15 + (_animationController.value * 0.25)),
                                blurRadius: 20 + (_animationController.value * 15),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            painter: LaserScannerOverlayPainter(
                              animationValue: _animationController.value,
                              laserColor: const Color(0xFF34D399),
                              isScanning: _isScanning,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_scanner_rounded,
                                    size: 80,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'TAP TO SELECT EVENT',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    lang.getText('align_qr'),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: _showEventSelector,
                    icon: const Icon(Icons.qr_code_rounded),
                    label: Text(
                      lang.getText('scan_event_qr_button'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34D399),
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter for High-Tech Laser Beam & Corner Brackets Overlay
class LaserScannerOverlayPainter extends CustomPainter {
  final double animationValue;
  final Color laserColor;
  final bool isScanning;

  LaserScannerOverlayPainter({
    required this.animationValue,
    required this.laserColor,
    required this.isScanning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    const cornerLength = 32.0;
    const strokeWidth = 4.0;
    const radius = 16.0;

    // 1. Draw High-Tech Corner Brackets
    final cornerPaint = Paint()
      ..color = laserColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = laserColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 6);

    final path = Path();

    // Top Left Corner
    path.moveTo(0, cornerLength);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.lineTo(cornerLength, 0);

    // Top Right Corner
    path.moveTo(width - cornerLength, 0);
    path.lineTo(width - radius, 0);
    path.quadraticBezierTo(width, 0, width, radius);
    path.lineTo(width, cornerLength);

    // Bottom Right Corner
    path.moveTo(width, height - cornerLength);
    path.lineTo(width, height - radius);
    path.quadraticBezierTo(width, height, width - radius, height);
    path.lineTo(width - cornerLength, height);

    // Bottom Left Corner
    path.moveTo(cornerLength, height);
    path.lineTo(radius, height);
    path.quadraticBezierTo(0, height, 0, height - radius);
    path.lineTo(0, height - cornerLength);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, cornerPaint);

    if (!isScanning) return;

    // 2. Draw Laser Beam Line & Gradient Trail Effect
    final laserY = animationValue * (height - 16) + 8;
    const trailHeight = 45.0;

    // Gradient Trail fading upward/downward
    final trailPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          laserColor.withOpacity(0.0),
          laserColor.withOpacity(0.28),
        ],
      ).createShader(Rect.fromLTRB(0, laserY - trailHeight, width, laserY));

    canvas.drawRect(
      Rect.fromLTRB(0, (laserY - trailHeight).clamp(0, height), width, laserY),
      trailPaint,
    );

    // Glowing Laser Line
    final lineGlowPaint = Paint()
      ..color = laserColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(10, laserY), Offset(width - 10, laserY), lineGlowPaint);
    canvas.drawLine(Offset(10, laserY), Offset(width - 10, laserY), linePaint);

    // Center Laser Core Pulse Dot
    final centerDotGlow = Paint()
      ..color = laserColor
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final centerDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(width / 2, laserY), 6, centerDotGlow);
    canvas.drawCircle(Offset(width / 2, laserY), 3.5, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant LaserScannerOverlayPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.laserColor != laserColor ||
        oldDelegate.isScanning != isScanning;
  }
}
