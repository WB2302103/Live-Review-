import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/event_model.dart';
import '../../models/feedback_model.dart';
import '../../services/mock_data_service.dart';
import '../../services/api_service.dart';
import '../../utils/page_transitions.dart';
import '../../utils/language_manager.dart';
import 'success_screen.dart';

class FeedbackFormScreen extends StatefulWidget {
  final Event event;

  const FeedbackFormScreen({super.key, required this.event});

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  double _overallRating = 0.0;
  double _speakerRating = 0.0;
  double _contentRating = 0.0;
  double _venueRating = 0.0;

  final TextEditingController _commentController = TextEditingController();
  final MockDataService _dataService = MockDataService();

  void _submitFeedback() {
    // 1. Validation: Require at least one rating category to be selected
    if (_overallRating == 0 && _speakerRating == 0 && _contentRating == 0 && _venueRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please rate at least one category before submitting.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final comment = _commentController.text.trim();

    // 2. Value resolution
    final overallVal = _overallRating == 0 ? 3.0 : _overallRating;
    final speakerVal = _speakerRating == 0 ? overallVal : _speakerRating;
    final contentVal = _contentRating == 0 ? overallVal : _contentRating;
    final venueVal = _venueRating == 0 ? overallVal : _venueRating;

    // Calculate Average Rating
    final avgRating = (overallVal + speakerVal + contentVal + venueVal) / 4.0;

    // 3. Primary Sentiment Determination based on Star Ratings
    String sentiment;
    if (avgRating <= 2.5) {
      sentiment = 'Negative';
    } else if (avgRating <= 3.5) {
      sentiment = 'Neutral';
    } else {
      sentiment = 'Positive';
    }

    final lowerComment = comment.toLowerCase();
    Set<String> issues = {};

    // 4. Keyword NLP Sentiment & Tag Detection (English + Banglish)
    final negativeKeywords = ['bad', 'poor', 'terrible', 'boring', 'worst', 'waste', 'late', 'noise', 'kharap', 'baje', 'bekar', 'faltu', 'slow'];
    final positiveKeywords = ['great', 'awesome', 'good', 'excellent', 'amazing', 'helpful', 'sundor', 'valo', 'bhalo', 'darun', 'chomokdar', 'best'];

    bool hasNegativeWord = false;
    bool hasPositiveWord = false;

    for (var word in negativeKeywords) {
      if (RegExp(r'\b' + word + r'\b').hasMatch(lowerComment)) {
        hasNegativeWord = true;
        break;
      }
    }

    for (var word in positiveKeywords) {
      if (RegExp(r'\b' + word + r'\b').hasMatch(lowerComment)) {
        hasPositiveWord = true;
        break;
      }
    }

    // Override sentiment if comment text strongly indicates negative
    if (hasNegativeWord) {
      sentiment = 'Negative';
      issues.add('Improvement Needed');
    } else if (hasPositiveWord && sentiment == 'Neutral') {
      sentiment = 'Positive';
    }

    // Category Low Rating & Topic Tag Generation
    if (venueVal <= 2.5 || lowerComment.contains('venue') || lowerComment.contains('room') || lowerComment.contains('ac') || lowerComment.contains('heat') || lowerComment.contains('sound') || lowerComment.contains('mic')) {
      issues.add('Venue & Facilities');
    }
    if (speakerVal <= 2.5 || lowerComment.contains('speaker') || lowerComment.contains('presentation') || lowerComment.contains('talk')) {
      issues.add('Speaker Quality');
    }
    if (contentVal <= 2.5 || lowerComment.contains('content') || lowerComment.contains('topic') || lowerComment.contains('relevance')) {
      issues.add('Content Relevance');
    }

    if (hasPositiveWord && issues.isEmpty) {
      issues.add('Engaging Content');
    }

    if (issues.isEmpty) {
      issues.add(sentiment == 'Positive' ? 'General Satisfaction' : (sentiment == 'Negative' ? 'Needs Attention' : 'General Feedback'));
    }

    final feedback = FeedbackItem(
      id: 'f_${DateTime.now().millisecondsSinceEpoch}',
      eventId: widget.event.id,
      overallRating: overallVal,
      speakerRating: speakerVal,
      contentRating: contentVal,
      venueRating: venueVal,
      comment: comment.isEmpty ? 'No written comment provided.' : comment,
      submittedAt: DateTime.now(),
      sentiment: sentiment,
      keyIssues: issues.toList(),
    );

    _dataService.addFeedback(feedback);
    _dataService.markEventSubmitted(widget.event.id);

    // Send Feedback to Django Backend & PostgreSQL Database
    ApiService().submitFeedback(feedback, 'client_token_${widget.event.id}');

    Navigator.pushReplacement(
      context,
      FadeSlidePageRoute(widget: const SuccessScreen()),
    );
  }

  Widget _buildRatingRow(String label, double rating, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 320;

          final starList = Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final isSelected = index < rating;
              return TweenAnimationBuilder<double>(
                key: ValueKey('${label}_$index$isSelected'),
                tween: Tween<double>(begin: 0.7, end: 1.0),
                duration: const Duration(milliseconds: 350),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        final selectedValue = (index + 1).toDouble();
                        if (rating == selectedValue) {
                          onChanged(0.0);
                        } else {
                          onChanged(selectedValue);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Icon(
                          isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                          color: const Color(0xFFF59E0B),
                          size: 28,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Align(alignment: Alignment.centerRight, child: starList),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              starList,
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageManager();
    final isAlreadySubmitted = _dataService.isEventSubmitted(widget.event.id);

    if (isAlreadySubmitted) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          title: Text(lang.getText('give_feedback')),
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFF34D399).withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF34D399).withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: Color(0xFF34D399),
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF34D399).withOpacity(0.4)),
                    ),
                    child: Text(
                      lang.getText('feedback_locked'),
                      style: const TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    lang.getText('already_submitted'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    lang.getText('anti_spam_lock_desc'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '📍 ${widget.event.venue}',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back to Event Details', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34D399),
                      foregroundColor: const Color(0xFF0F172A),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _dataService.unlockEventSubmission(widget.event.id);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unlocked for testing! You can now submit another review.'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.lock_open_rounded, size: 16, color: Color(0xFF34D399)),
                    label: const Text(
                      'Unlock to Submit Another Review (Demo Mode)',
                      style: TextStyle(color: Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(lang.getText('give_feedback')),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.event.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    widget.event.venue,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // --- Detailed Category Star Ratings Card ---
              Container(
                padding: const EdgeInsets.all(16),
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
                    _buildRatingRow(lang.getText('overall_satisfaction'), _overallRating, (val) => setState(() => _overallRating = val)),
                    const Divider(height: 12),
                    _buildRatingRow(lang.getText('speaker_quality'), _speakerRating, (val) => setState(() => _speakerRating = val)),
                    const Divider(height: 12),
                    _buildRatingRow(lang.getText('content_relevance'), _contentRating, (val) => setState(() => _contentRating = val)),
                    const Divider(height: 12),
                    _buildRatingRow(lang.getText('venue_facilities'), _venueRating, (val) => setState(() => _venueRating = val)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Text Comment Box ---
              Text(
                lang.getText('write_comment'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: lang.getText('comment_hint'),
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF0F766E), width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // --- Submit Action Button ---
              ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  lang.getText('submit_feedback'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
