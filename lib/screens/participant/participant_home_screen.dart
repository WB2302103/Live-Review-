import 'package:flutter/material.dart';
import '../../services/mock_data_service.dart';
import '../../services/api_service.dart';
import '../../utils/page_transitions.dart';
import '../../utils/theme_manager.dart';
import '../../utils/language_manager.dart';
import '../../widgets/language_toggle_pill.dart';
import '../../widgets/live_feedback_ticker.dart';
import 'camera_scanner_screen.dart';
import 'event_details_screen.dart';

class ParticipantHomeScreen extends StatefulWidget {
  const ParticipantHomeScreen({super.key});

  @override
  State<ParticipantHomeScreen> createState() => _ParticipantHomeScreenState();
}

class _ParticipantHomeScreenState extends State<ParticipantHomeScreen>
    with SingleTickerProviderStateMixin {
  final MockDataService _dataService = MockDataService();
  late AnimationController _listAnimationController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Live', 'Upcoming'

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _listAnimationController.forward();
    _syncWithApi();
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
    _listAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langManager = LanguageManager();

    var events = _dataService.getEvents().where((e) => e.status != 'closed').toList();

    // Category Status Filter
    if (_selectedFilter == 'Live') {
      events = events.where((e) => e.status == 'live').toList();
    } else if (_selectedFilter == 'Upcoming') {
      events = events.where((e) => e.status == 'upcoming').toList();
    }

    // Real-Time Search Query Filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      events = events.where((e) {
        return e.title.toLowerCase().contains(q) ||
            e.venue.toLowerCase().contains(q) ||
            e.description.toLowerCase().contains(q) ||
            e.organizerName.toLowerCase().contains(q);
      }).toList();
    }

    return ValueListenableBuilder<String>(
      valueListenable: langManager.languageNotifier,
      builder: (context, currentLang, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(langManager.getText('app_title')),
            actions: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: LanguageTogglePill(),
              ),
              IconButton(
                icon: Icon(
                  ThemeManager().isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                ),
                onPressed: () {
                  setState(() {
                    ThemeManager().toggleTheme();
                  });
                },
                tooltip: 'Toggle Theme',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scan QR Banner Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F766E).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              langManager.getText('scan_event_qr'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              langManager.getText('scan_qr_desc'),
                              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            FadeSlidePageRoute(widget: const CameraScannerScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F766E),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(langManager.getText('open_scan'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --- Live Real-Time Audience Feedback Ticker ---
                LiveFeedbackTicker(feedbacks: _dataService.feedbacks),
                const SizedBox(height: 20),

                // Real-Time Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: langManager.getText('search_hint'),
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0F766E)),
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
                const SizedBox(height: 14),

                // Filter Chips Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Live', 'Upcoming'].map((filterName) {
                      final isSelected = _selectedFilter == filterName;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(
                            filterName == 'Live'
                                ? langManager.getText('live')
                                : (filterName == 'Upcoming' ? langManager.getText('upcoming') : (langManager.isBangla ? 'সবগুলো' : 'All')),
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          selectedColor: const Color(0xFF0F766E),
                          backgroundColor: Theme.of(context).cardTheme.color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF0F766E) : Colors.grey.shade300,
                            ),
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = filterName;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: events.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.event_busy_rounded,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? '${langManager.isBangla ? "কোনো ইভেন্ট পাওয়া যায়নি:" : "No events matching"} "$_searchQuery"'
                                    : langManager.getText('no_active_events'),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? (langManager.isBangla ? 'অন্য কোনো বিষয় বা ভেন্যু লিখে খুঁজুন।' : 'Try searching for another venue or keyword.')
                                    : langManager.getText('check_back_later'),
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];

                            final double start = (index * 0.15).clamp(0.0, 0.8);
                            final double end = (start + 0.4).clamp(0.2, 1.0);

                            final Animation<double> fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _listAnimationController,
                                curve: Interval(start, end, curve: Curves.easeOut),
                              ),
                            );

                            final Animation<Offset> slideAnim = Tween<Offset>(
                              begin: const Offset(0, 0.25),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _listAnimationController,
                                curve: Interval(start, end, curve: Curves.easeOutCubic),
                              ),
                            );

                            return AnimatedBuilder(
                              animation: _listAnimationController,
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
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardTheme.color,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    splashColor: const Color(0xFF34D399).withOpacity(0.15),
                                    highlightColor: const Color(0xFF0F766E).withOpacity(0.05),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        FadeSlidePageRoute(widget: EventDetailsScreen(event: event)),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  event.title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: event.status == 'live' ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  event.status == 'live' ? langManager.getText('live') : langManager.getText('upcoming'),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: event.status == 'live' ? const Color(0xFF059669) : const Color(0xFFD97706),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                              const SizedBox(width: 6),
                                              Text(event.venue, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                                              const SizedBox(width: 6),
                                              Text(event.dateTime, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
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
