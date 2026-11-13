import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/mock_data_service.dart';
import '../../services/api_service.dart';
import '../../utils/page_transitions.dart';
import '../../utils/theme_manager.dart';
import '../../utils/language_manager.dart';
import '../../widgets/animated_counter.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/language_toggle_pill.dart';
import '../../widgets/live_feedback_ticker.dart';
import '../../widgets/emergency_alert_banner.dart';
import 'create_event_screen.dart';
import 'event_analytics_screen.dart';

class OrganizerDashboardScreen extends StatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  State<OrganizerDashboardScreen> createState() => _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen>
    with SingleTickerProviderStateMixin {
  final MockDataService _dataService = MockDataService();
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'All'; // 'All', 'Live', 'Upcoming', 'Closed'
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _syncWithApi();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (_animationController.status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      }
    });
  }

  void _syncWithApi() async {
    final apiEvents = await ApiService().fetchEvents();
    if (apiEvents.isNotEmpty && mounted) {
      setState(() {
        for (var e in apiEvents) {
          if (!_dataService.events.any((existing) => existing.id == e.id)) {
            _dataService.events.insert(0, e);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDeleteEvent(String eventId, String eventTitle) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Event?'),
          ],
        ),
        content: Text('Are you sure you want to delete "$eventTitle"? This will remove all associated feedback.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _dataService.deleteEvent(eventId);
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "$eventTitle"'),
                  backgroundColor: const Color(0xFF1E293B),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleEventStatus(String eventId, String currentStatus) {
    HapticFeedback.lightImpact();
    String newStatus = 'live';
    if (currentStatus == 'live') {
      newStatus = 'closed';
    } else if (currentStatus == 'upcoming') {
      newStatus = 'live';
    } else if (currentStatus == 'closed') {
      newStatus = 'live';
    }

    _dataService.updateEventStatus(eventId, newStatus);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event status updated to: ${newStatus.toUpperCase()}'),
        backgroundColor: const Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langManager = LanguageManager();
    final isDark = ThemeManager().isDarkMode || Theme.of(context).brightness == Brightness.dark;

    var events = _dataService.getEvents();

    // Status Filter
    if (_selectedStatusFilter == 'Live') {
      events = events.where((e) => e.status == 'live').toList();
    } else if (_selectedStatusFilter == 'Upcoming') {
      events = events.where((e) => e.status == 'upcoming').toList();
    } else if (_selectedStatusFilter == 'Closed') {
      events = events.where((e) => e.status == 'closed').toList();
    }

    // Search Query Filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      events = events.where((e) {
        return e.title.toLowerCase().contains(q) ||
            e.venue.toLowerCase().contains(q) ||
            e.description.toLowerCase().contains(q) ||
            e.organizerName.toLowerCase().contains(q);
      }).toList();
    }

    return AnimatedTheme(
      duration: const Duration(milliseconds: 250),
      data: Theme.of(context),
      child: ValueListenableBuilder<String>(
        valueListenable: langManager.languageNotifier,
        builder: (context, currentLang, child) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: CustomScrollView(
              slivers: [
                // Collapsing SliverAppBar with Dynamic Dark Gradient
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      langManager.getText('organizer_portal'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                    ),
                    centerTitle: true,
                    background: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDark
                              ? const [Color(0xFF0F172A), Color(0xFF020617)]
                              : const [Color(0xFF0F766E), Color(0xFF111827)],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: LanguageTogglePill(),
                    ),
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        ThemeManager().toggleTheme();
                      },
                      tooltip: 'Toggle Theme',
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        await Navigator.push(
                          context,
                          FadeSlidePageRoute(widget: const CreateEventScreen()),
                        );
                        setState(() {});
                      },
                      tooltip: 'Create Event',
                    ),
                  ],
                ),

                // Main Body List
                SliverPadding(
                  padding: const EdgeInsets.all(20.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      EmergencyAlertBanner(alerts: _dataService.getEmergencyAlerts(null)),
                      LiveFeedbackTicker(feedbacks: _dataService.feedbacks),
                      const SizedBox(height: 18),
                      Text(
                        langManager.getText('managed_events'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Real-Time Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim();
                          });
                        },
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: langManager.isBangla ? 'ইভেন্ট বা ভেন্যু খুঁজুন...' : 'Search managed events, venues...',
                          hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 13),
                          prefixIcon: Icon(Icons.search_rounded, color: isDark ? const Color(0xFF34D399) : const Color(0xFF0F766E)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: Colors.grey, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Theme.of(context).cardTheme.color,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: isDark ? const Color(0xFF34D399) : const Color(0xFF0F766E), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['All', 'Live', 'Upcoming', 'Closed'].map((statusName) {
                            final isSelected = _selectedStatusFilter == statusName;
                            String labelText = statusName;
                            if (statusName == 'Live') labelText = langManager.getText('live');
                            if (statusName == 'Upcoming') labelText = langManager.getText('upcoming');
                            if (statusName == 'Closed') labelText = langManager.getText('closed');
                            if (statusName == 'All') labelText = langManager.isBangla ? 'সবগুলো' : 'All';

                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                selected: isSelected,
                                label: Text(
                                  labelText,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF0F172A)),
                                  ),
                                ),
                                selectedColor: const Color(0xFF0F766E),
                                backgroundColor: Theme.of(context).cardTheme.color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected
                                        ? const Color(0xFF0F766E)
                                        : (isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                                  ),
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    _selectedStatusFilter = statusName;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_isLoading) ...[
                        const ShimmerSkeletonCard(height: 180, borderRadius: 20),
                        const SizedBox(height: 16),
                        const ShimmerSkeletonCard(height: 180, borderRadius: 20),
                      ] else if (events.isEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.dashboard_customize_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? '${langManager.isBangla ? "কোনো ইভেন্ট পাওয়া যায়নি:" : "No events matching"} "$_searchQuery"'
                                      : langManager.getText('no_events_created'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? (langManager.isBangla ? 'অন্য কোনো বিষয় বা ভেন্যু লিখে খুঁজুন।' : 'Try searching for another venue or keyword.')
                                      : (langManager.isBangla ? 'নিচের বাটনে ট্যাপ করে আপনার প্রথম ইভেন্ট তৈরি করুন।' : 'Tap the button below to publish your first event.'),
                                  style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.grey),
                                ),
                                if (_searchQuery.isEmpty) ...[
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      HapticFeedback.lightImpact();
                                      await Navigator.push(
                                        context,
                                        FadeSlidePageRoute(widget: const CreateEventScreen()),
                                      );
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.add_rounded),
                                    label: Text(langManager.getText('create_first_event'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0F766E),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        for (int index = 0; index < events.length; index++) ...[
                          _buildEventCard(events[index], index, langManager, isDark),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ]),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                HapticFeedback.lightImpact();
                await Navigator.push(
                  context,
                  FadeSlidePageRoute(widget: const CreateEventScreen()),
                );
                setState(() {});
              },
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(langManager.getText('create_event'), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(var event, int index, LanguageManager langManager, bool isDark) {
    final analytics = _dataService.getAnalytics(event.id);

    final isAnimCompleted = _animationController.isCompleted;

    final double start = (index * 0.15).clamp(0.0, 0.8);
    final double end = (start + 0.4).clamp(0.2, 1.0);

    final Animation<double> fadeAnim = isAnimCompleted
        ? const AlwaysStoppedAnimation(1.0)
        : Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(start, end, curve: Curves.easeOut),
            ),
          );

    final Animation<Offset> slideAnim = isAnimCompleted
        ? const AlwaysStoppedAnimation(Offset.zero)
        : Tween<Offset>(
            begin: const Offset(0, 0.25),
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
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
                Expanded(
                  child: Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: event.status == 'live'
                            ? const Color(0xFFECFDF5)
                            : (event.status == 'upcoming' ? const Color(0xFFFFF7ED) : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.status == 'live'
                            ? langManager.getText('live')
                            : (event.status == 'upcoming' ? langManager.getText('upcoming') : langManager.getText('closed')),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: event.status == 'live'
                              ? const Color(0xFF059669)
                              : (event.status == 'upcoming' ? const Color(0xFFD97706) : Colors.grey.shade700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                      onPressed: () => _confirmDeleteEvent(event.id, event.title),
                      tooltip: 'Delete Event',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  event.venue,
                  style: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF64748B), fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAnimatedMetric(
                  langManager.isBangla ? 'রেসপন্স' : 'Responses',
                  AnimatedCounterText(
                    value: analytics['responseCount'] as int,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF34D399) : const Color(0xFF0F766E)),
                  ),
                  isDark,
                ),
                _buildAnimatedMetric(
                  langManager.isBangla ? 'গড় স্কোর' : 'Avg Rating',
                  AnimatedCounterText(
                    value: analytics['avgRating'] as double,
                    prefix: '⭐ ',
                    decimals: 1,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF34D399) : const Color(0xFF0F766E)),
                  ),
                  isDark,
                ),
                _buildAnimatedMetric(
                  langManager.isBangla ? 'সেন্টিমেন্ট' : 'Sentiment',
                  AnimatedCounterText(
                    value: analytics['positivePct'] as double,
                    suffix: '% Pos',
                    decimals: 0,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF34D399) : const Color(0xFF0F766E)),
                  ),
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Control Buttons Row: Status Switcher & Analytics
            Row(
              children: [
                // Toggle Status Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleEventStatus(event.id, event.status),
                    icon: Icon(
                      event.status == 'upcoming'
                          ? Icons.play_arrow_rounded
                          : (event.status == 'live' ? Icons.stop_rounded : Icons.replay_rounded),
                      size: 18,
                    ),
                    label: Text(
                      event.status == 'upcoming'
                          ? langManager.getText('start_event')
                          : (event.status == 'live' ? langManager.getText('end_event') : langManager.getText('reopen_event')),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: event.status == 'upcoming'
                          ? const Color(0xFF059669)
                          : (event.status == 'live' ? const Color(0xFFDC2626) : (isDark ? const Color(0xFF34D399) : const Color(0xFF0F766E))),
                      side: BorderSide(
                        color: event.status == 'upcoming'
                            ? const Color(0xFF059669)
                            : (event.status == 'live' ? const Color(0xFFDC2626) : (isDark ? const Color(0xFF34D399) : const Color(0xFF0F766E))),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // View Analytics Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        FadeSlidePageRoute(widget: EventAnalyticsScreen(event: event)),
                      );
                    },
                    icon: const Icon(Icons.insights_rounded, size: 18),
                    label: Text(langManager.getText('analytics'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
    );
  }

  Widget _buildAnimatedMetric(String label, Widget counterWidget, bool isDark) {
    return Column(
      children: [
        counterWidget,
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey)),
      ],
    );
  }
}
