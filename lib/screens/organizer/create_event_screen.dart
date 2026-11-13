import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/mock_data_service.dart';
import '../../services/api_service.dart';
import '../../utils/page_transitions.dart';
import 'qr_display_screen.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _venueController = TextEditingController();
  final _timeController = TextEditingController(text: 'Today, 3:00 PM');
  final _organizerController = TextEditingController(text: 'DevDynamos');
  DateTime? _pickedEventDateTime;
  String _selectedStatus = 'upcoming'; // Default: Upcoming
  final MockDataService _dataService = MockDataService();
  bool _isLoading = false;

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F766E),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF0F766E),
                onPrimary: Colors.white,
                onSurface: Color(0xFF0F172A),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        final fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        final now = DateTime.now();
        final isToday = pickedDate.year == now.year && pickedDate.month == now.month && pickedDate.day == now.day;
        final dayStr = isToday ? 'Today' : '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
        final timeStr = pickedTime.format(context);

        setState(() {
          _pickedEventDateTime = fullDateTime;
          _timeController.text = '$dayStr, $timeStr';
        });
      }
    }
  }

  void _createEvent() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an event title'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final newEvent = Event(
      id: 'e_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? 'No description provided.' : _descController.text.trim(),
      venue: _venueController.text.trim().isEmpty ? 'Main Auditorium' : _venueController.text.trim(),
      dateTime: _timeController.text.trim(),
      eventDateTime: _pickedEventDateTime,
      organizerName: _organizerController.text.trim().isEmpty ? 'Youth Club & Organizers' : _organizerController.text.trim(),
      qrCodeToken: 'EVT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      status: _selectedStatus,
    );

    _dataService.addEvent(newEvent);
    ApiService().createEvent(newEvent);

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      FadeSlidePageRoute(widget: QrDisplayScreen(event: newEvent)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Create New Event'),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
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
                  const Text(
                    'Event Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 18),
                  _buildTextField(
                    controller: _titleController,
                    label: 'Event Title',
                    icon: Icons.title_rounded,
                    hint: 'e.g. AI & Robotics Symposium 2026',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _organizerController,
                    label: 'Organizer Name / Club',
                    icon: Icons.groups_rounded,
                    hint: 'e.g. DevDynamos, IEEE Student Branch, Youth Marketing Club...',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descController,
                    label: 'Description',
                    icon: Icons.description_rounded,
                    hint: 'Short details about speakers, topics, agenda...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _venueController,
                    label: 'Venue / Location',
                    icon: Icons.location_on_rounded,
                    hint: 'e.g. Auditorium 701, Academic Building',
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _selectDateTime,
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: _timeController,
                        label: 'Date & Time',
                        icon: Icons.calendar_month_rounded,
                        hint: 'Tap to pick Date & Time',
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Initial Event Status:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 10),

                  // Initial Status Selector Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.tune_rounded, color: Color(0xFF0F766E)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    items: const [
                      DropdownMenuItem(
                        value: 'upcoming',
                        child: Row(
                          children: [
                            Icon(Icons.schedule_rounded, color: Color(0xFFD97706), size: 18),
                            SizedBox(width: 8),
                            Text('Upcoming (Scheduled)', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'live',
                        child: Row(
                          children: [
                            Icon(Icons.sensors_rounded, color: Color(0xFF059669), size: 18),
                            SizedBox(width: 8),
                            Text('Live Now (Active)', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'closed',
                        child: Row(
                          children: [
                            Icon(Icons.lock_clock_rounded, color: Colors.grey, size: 18),
                            SizedBox(width: 8),
                            Text('Closed (Finished)', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedStatus = val;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _createEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Generating QR Code...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_rounded, size: 22),
                        SizedBox(width: 10),
                        Text('Generate QR & Publish Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF0F766E)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }
}
