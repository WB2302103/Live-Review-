import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/event_model.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/animated_counter.dart';
import '../../widgets/live_feedback_ticker.dart';
import '../../widgets/emergency_alert_banner.dart';
import '../../widgets/speaker_certificate_dialog.dart';

class EventAnalyticsScreen extends StatefulWidget {
  final Event event;

  const EventAnalyticsScreen({super.key, required this.event});

  @override
  State<EventAnalyticsScreen> createState() => _EventAnalyticsScreenState();
}

class _EventAnalyticsScreenState extends State<EventAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _downloadPdfReport(BuildContext context) {
    HapticFeedback.mediumImpact();
    final fileName = '${widget.event.title.replaceAll(RegExp(r'\s+'), '_')}_Analytics_Report.pdf';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '📄 PDF Downloaded: $fileName',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _downloadExcelSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    final fileName = '${widget.event.title.replaceAll(RegExp(r'\s+'), '_')}_Feedback_Data.xlsx';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.table_chart_rounded, color: Color(0xFF34D399)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '📊 Excel Sheet Downloaded: $fileName',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showShareableReportCard(BuildContext context, Map<String, dynamic> analytics) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final double avgRating = analytics['avgRating'] as double;
        final double positivePct = analytics['positivePct'] as double;
        final int responseCount = analytics['responseCount'] as int;
        final List<String> keyIssues = analytics['keyIssues'] as List<String>;

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet handle
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: Color(0xFF34D399), size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Event Analytics Report Card',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- Shareable Report Card Canvas Widget ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF34D399).withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34D399).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.bolt_rounded, color: Color(0xFF34D399), size: 16),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'LIVE REVIEW AI REPORT',
                              style: TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'VERIFIED REPORT',
                            style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Event Title & Organizer
                    Text(
                      widget.event.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📍 ${widget.event.venue} • 👤 ${widget.event.organizerName}',
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    const SizedBox(height: 18),

                    // Performance Badge
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '⭐ ${avgRating.toStringAsFixed(1)}',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                              ),
                              const SizedBox(height: 2),
                              const Text('Overall Score', style: TextStyle(fontSize: 11, color: Colors.white70)),
                            ],
                          ),
                          Container(height: 30, width: 1, color: Colors.white24),
                          Column(
                            children: [
                              Text(
                                '${positivePct.toStringAsFixed(0)}%',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF34D399)),
                              ),
                              const SizedBox(height: 2),
                              const Text('Positive Ratio', style: TextStyle(fontSize: 11, color: Colors.white70)),
                            ],
                          ),
                          Container(height: 30, width: 1, color: Colors.white24),
                          Column(
                            children: [
                              Text(
                                '$responseCount',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              const Text('Attendees', style: TextStyle(fontSize: 11, color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Key Topic Chips
                    if (keyIssues.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: keyIssues.map((issue) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF34D399).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '#$issue',
                              style: const TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Footer Brand Note
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Real-Time AI Audience Analytics',
                          style: TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                        Icon(Icons.qr_code_2_rounded, color: Colors.white38, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Row 1: Download Action Buttons (PDF & Excel) ---
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _downloadPdfReport(context);
                      },
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                      label: const Text('Download PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _downloadExcelSheet(context);
                      },
                      icon: const Icon(Icons.table_chart_rounded, size: 18),
                      label: const Text('Download Excel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- Row 2: Secondary Action Buttons (Copy & Share) ---
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Clipboard.setData(
                          ClipboardData(
                            text: '📊 Event Analytics Summary for "${widget.event.title}":\n'
                                '• Overall Score: ⭐ ${avgRating.toStringAsFixed(1)} / 5.0\n'
                                '• Positive Audience Ratio: ${positivePct.toStringAsFixed(0)}%\n'
                                '• Total Responses: $responseCount\n'
                                '• Venue: ${widget.event.venue}\n'
                                'Generated via EventPulse AI Platform.',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Report summary text copied to clipboard!'),
                            backgroundColor: Color(0xFF0F766E),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copy Summary'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Color(0xFF34D399)),
                                SizedBox(width: 8),
                                Text('Report Card exported & ready to share!'),
                              ],
                            ),
                            backgroundColor: Color(0xFF0F172A),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share Card', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34D399),
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final MockDataService dataService = MockDataService();
    final analytics = dataService.getAnalytics(widget.event.id);
    final feedbacks = dataService.getFeedbacksForEvent(widget.event.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('${widget.event.title} - Analytics'),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Report Card',
            onPressed: () => _showShareableReportCard(context, analytics),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Overview Banner
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF111827)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildOverviewStat(
                        'Responses',
                        AnimatedCounterText(
                          value: analytics['responseCount'] as int,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      _buildVerticalDivider(),
                      _buildOverviewStat(
                        'Avg Rating',
                        AnimatedCounterText(
                          value: analytics['avgRating'] as double,
                          prefix: '⭐ ',
                          decimals: 1,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      _buildVerticalDivider(),
                      _buildOverviewStat(
                        'Positive',
                        AnimatedCounterText(
                          value: analytics['positivePct'] as double,
                          suffix: '%',
                          decimals: 0,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showShareableReportCard(context, analytics),
                          icon: const Icon(Icons.workspace_premium_rounded, size: 16),
                          label: const Text('Share Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF34D399),
                            foregroundColor: const Color(0xFF0F172A),
                            minimumSize: const Size.fromHeight(42),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => SpeakerCertificateDialog(
                                event: widget.event,
                                analytics: analytics,
                              ),
                            );
                          },
                          icon: const Icon(Icons.emoji_events_rounded, size: 16),
                          label: const Text('Speaker Certificate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: const Color(0xFF0F172A),
                            minimumSize: const Size.fromHeight(42),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Emergency Venue & Audio Alert Banner ---
            EmergencyAlertBanner(alerts: dataService.getEmergencyAlerts(widget.event.id)),

            // --- Real-Time Live Feedback Stream Ticker ---
            LiveFeedbackTicker(feedbacks: feedbacks),

            const SizedBox(height: 24),

            const Text(
              'Category Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProgressBar('Speaker Quality', analytics['speakerAvg'] as double),
                  const SizedBox(height: 16),
                  _buildProgressBar('Content Relevance', analytics['contentAvg'] as double),
                  const SizedBox(height: 16),
                  _buildProgressBar('Venue & Facilities', analytics['venueAvg'] as double),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // AI Sentiment & Key Issues
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI Sentiment & Issue Tags',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Color(0xFF059669), size: 14),
                      SizedBox(width: 4),
                      Text('LIVE AI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Positive Sentiment Ratio', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                      Text(
                        '${(analytics['positivePct'] as double).toStringAsFixed(0)}% Positive',
                        style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (analytics['positivePct'] as double) / 100,
                      backgroundColor: const Color(0xFFFEE2E2),
                      color: const Color(0xFF10B981),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Detected Tags & Feedback Topics:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  const SizedBox(height: 10),
                  (analytics['keyIssues'] as List<String>).isEmpty
                      ? const Text('No topic tags detected yet.', style: TextStyle(color: Colors.grey, fontSize: 13))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (analytics['keyIssues'] as List<String>).map((issue) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCFBF1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF99F6E4)),
                              ),
                              child: Text(
                                issue,
                                style: const TextStyle(
                                  color: Color(0xFF0F766E),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Live Audience Responses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            // Staggered Entrance Comments or Global Empty State
            feedbacks.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.forum_outlined, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 14),
                        const Text(
                          'No Audience Feedback Yet',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Share the QR code with participants to collect real-time responses.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: feedbacks.length,
                    itemBuilder: (context, index) {
                      final fb = feedbacks[index];

                      // Staggered entrance animation
                      final double start = (index * 0.12).clamp(0.0, 0.8);
                      final double end = (start + 0.4).clamp(0.2, 1.0);

                      final Animation<double> fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(start, end, curve: Curves.easeOut),
                        ),
                      );

                      final Animation<Offset> slideAnim = Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(start, end, curve: Curves.easeOutCubic),
                        ),
                      );

                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: fadeAnim,
                            child: SlideTransition(
                              position: slideAnim,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${fb.overallRating.toStringAsFixed(1)} / 5.0',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: fb.sentiment == 'Positive'
                                          ? const Color(0xFFDCFCE7)
                                          : (fb.sentiment == 'Neutral' ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      fb.sentiment,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: fb.sentiment == 'Positive'
                                            ? const Color(0xFF15803D)
                                            : (fb.sentiment == 'Neutral' ? const Color(0xFFB45309) : const Color(0xFFB91C1C)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                fb.comment,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStat(String label, Widget counterWidget) {
    return Column(
      children: [
        counterWidget,
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 35, width: 1, color: Colors.white30);
  }

  Widget _buildProgressBar(String label, double rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155))),
            Text('⭐ ${rating.toStringAsFixed(1)} / 5.0', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: rating / 5.0,
            backgroundColor: Colors.grey.shade200,
            color: const Color(0xFF0F766E),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
