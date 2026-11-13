import 'dart:async';
import 'package:flutter/material.dart';
import '../models/feedback_model.dart';
import '../utils/language_manager.dart';

class LiveFeedbackTicker extends StatefulWidget {
  final List<FeedbackItem> feedbacks;

  const LiveFeedbackTicker({super.key, required this.feedbacks});

  @override
  State<LiveFeedbackTicker> createState() => _LiveFeedbackTickerState();
}

class _LiveFeedbackTickerState extends State<LiveFeedbackTicker> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  @override
  void didUpdateWidget(covariant LiveFeedbackTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.feedbacks.length != oldWidget.feedbacks.length) {
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  void _startTicker() {
    _timer?.cancel();
    if (widget.feedbacks.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (mounted && widget.feedbacks.isNotEmpty) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.feedbacks.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'Positive':
        return const Color(0xFF10B981);
      case 'Negative':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageManager();
    final isBangla = lang.isBangla;

    if (widget.feedbacks.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF0F766E).withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F766E).withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF34D399).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.rss_feed_rounded, color: Color(0xFF34D399), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF34D399),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isBangla ? 'লাইভ ফিডব্যাক স্ট্রিম' : 'LIVE FEEDBACK STREAM',
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isBangla ? 'এখনো কোনো কমেন্ট জমা হয়নি। ফিডব্যাক দিলে এখানে লাইভ দেখাবে।' : 'Waiting for audience responses. Stream updates live!',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final safeIndex = _currentIndex.clamp(0, widget.feedbacks.length - 1);
    final feedback = widget.feedbacks[safeIndex];
    final sentimentColor = _getSentimentColor(feedback.sentiment);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0F766E).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar with Pulsing Dot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.4, end: 1.0),
                    duration: const Duration(milliseconds: 900),
                    builder: (context, opacity, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF34D399).withOpacity(opacity),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF34D399).withOpacity(opacity),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBangla ? 'লাইভ অডিয়েন্স স্ট্রিম' : 'LIVE AUDIENCE STREAM',
                    style: const TextStyle(
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
                child: Text(
                  '${safeIndex + 1} / ${widget.feedbacks.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Animated Switcher for Live Comment Transition
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.08, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<String>(feedback.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Sentiment Badge Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: sentimentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: sentimentColor.withOpacity(0.5)),
                        ),
                        child: Text(
                          feedback.sentiment.toUpperCase(),
                          style: TextStyle(
                            color: sentimentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Rating Stars
                      Row(
                        children: List.generate(5, (index) {
                          final isFilled = index < feedback.overallRating;
                          return Icon(
                            isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 14,
                          );
                        }),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        feedback.overallRating.toStringAsFixed(1),
                        style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),

                      // Time Ago
                      Text(
                        _formatTimeAgo(feedback.submittedAt),
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Comment Text
                  Text(
                    '"${feedback.comment}"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.3,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
