import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LanguageManager {
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  // 'en' or 'bn'
  final ValueNotifier<String> languageNotifier = ValueNotifier<String>('en');

  bool get isBangla => languageNotifier.value == 'bn';
  String get currentLangCode => languageNotifier.value;

  void toggleLanguage() {
    HapticFeedback.lightImpact();
    if (languageNotifier.value == 'en') {
      languageNotifier.value = 'bn';
    } else {
      languageNotifier.value = 'en';
    }
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Live Review',
      'tagline': 'Real-Time Audience Feedback &\nAI Sentiment Analytics Platform',
      'join_as_participant': 'Join as Participant',
      'organizer_portal': 'Organizer Portal',
      'scan_event_qr': 'Scan Event QR',
      'scan_qr_desc': 'Scan venue QR code for instant anonymous feedback.',
      'open_scan': 'Open Scan',
      'active_upcoming_events': 'Active & Upcoming Events',
      'search_hint': 'Search events, venues, keywords...',
      'no_active_events': 'No Active Events Found',
      'check_back_later': 'Check back later or scan a QR code.',
      'create_new_event': 'Create New Event',
      'event_info': 'Event Information',
      'event_title': 'Event Title',
      'description': 'Description',
      'venue': 'Venue / Location',
      'date_time': 'Date & Time',
      'initial_status': 'Initial Event Status:',
      'generate_qr': 'Generate QR & Publish Event',
      'generating_qr': 'Generating QR Code...',
      'upcoming': 'UPCOMING',
      'live': 'LIVE NOW',
      'closed': 'CLOSED',
      'managed_events': 'Managed Events & Real-Time Analytics',
      'create_event': 'Create Event',
      'create_first_event': 'Create First Event',
      'no_events_created': 'No Events Created Yet',
      'start_event': 'Start Event',
      'end_event': 'End Event',
      'reopen_event': 'Reopen Event',
      'analytics': 'Analytics',
      'view_analytics': 'View Live Analytics & AI Insights',
      'submit_feedback': 'Submit Feedback',
      'give_feedback': 'Give Instant Feedback',
      'anonymous_note': '100% Anonymous Feedback. Your response is analyzed instantly with AI Sentiment Analytics.',
      'about_event': 'About this Event',
      'overall_satisfaction': 'Overall Satisfaction',
      'speaker_quality': 'Speaker / Presenter',
      'content_relevance': 'Content & Relevance',
      'venue_facilities': 'Venue & Facilities',
      'write_comment': 'Write a Comment or Suggestion',
      'comment_hint': 'e.g., The speaker was amazing, but the sound system could be improved...',
      'thank_you': 'Thank You!',
      'feedback_success_desc': 'Your feedback has been successfully submitted and analyzed by AI in real-time.',
      'back_to_home': 'Back to Home',
      'back_to_dashboard': 'Back to Dashboard',
      'copy_token': 'Copy Token / Share',
      'event_published': 'Event Published Successfully!',
      'camera_scanner': 'Live Camera QR Scanner',
      'align_qr': 'Align QR code inside frame or tap button below',
      'scan_event_qr_button': 'Scan Event QR Code',
      'select_event_scan': 'Select Event to Scan QR',
      'no_events_available': 'No events available to scan.',
      'already_submitted': 'Feedback Already Submitted',
      'anti_spam_lock_desc': 'You have already submitted 100% anonymous feedback for this event. To maintain data integrity, duplicate submissions are locked on this device.',
      'feedback_locked': 'FEEDBACK LOCKED',
      'live_audience_mood': 'Live Audience Mood Reaction',
      'select_mood_hint': 'Tap an emoji to quickly rate your event experience',
      'terrible': 'Terrible',
      'poor': 'Poor',
      'neutral_mood': 'Average',
      'good': 'Good',
      'awesome': 'Awesome!',
    },
    'bn': {
      'app_title': 'লাইভ রিভিউ',
      'tagline': 'রিয়েল-টাইম অডিয়েন্স ফিডব্যাক ও\nএআই সেন্টিমেন্ট এনালাইটিক্স প্ল্যাটফর্ম',
      'join_as_participant': 'অংশগ্রহণকারী হিসেবে যোগ দিন',
      'organizer_portal': 'আয়োজক পোর্টাল',
      'scan_event_qr': 'ইভেন্ট QR স্ক্যান করুন',
      'scan_qr_desc': 'ইন্সট্যান্ট অ্যানোনিমাস ফিডব্যাক দিতে ভেন্যুর QR কোড স্ক্যান করুন।',
      'open_scan': 'স্ক্যান ওপেন করুন',
      'active_upcoming_events': 'চলমান ও আসন্ন ইভেন্টসমূহ',
      'search_hint': 'ইভেন্ট, ভেন্যু বা বিষয় খুঁজুন...',
      'no_active_events': 'কোনো ইভেন্ট পাওয়া যায়নি',
      'check_back_later': 'পরে আবার দেখুন অথবা QR কোড স্ক্যান করুন।',
      'create_new_event': 'নতুন ইভেন্ট তৈরি করুন',
      'event_info': 'ইভেন্টের তথ্য প্রদান করুন',
      'event_title': 'ইভেন্টের নাম / টাইটেল',
      'description': 'ইভেন্টের বিবরণ',
      'venue': 'ভেন্যু / লোকেশন',
      'date_time': 'তারিখ ও সময়',
      'initial_status': 'প্রারম্ভিক ইভেন্ট স্ট্যাটাস:',
      'generate_qr': 'QR জেনারেট ও পাবলিশ করুন',
      'generating_qr': 'QR কোড তৈরি করা হচ্ছে...',
      'upcoming': 'আসন্ন',
      'live': 'লাইভ চলমান',
      'closed': 'সমাপ্ত',
      'managed_events': 'পরিচালিত ইভেন্ট ও এআই এনালাইটিক্স',
      'create_event': 'ইভেন্ট তৈরি করুন',
      'create_first_event': 'প্রথম ইভেন্ট তৈরি করুন',
      'no_events_created': 'এখনো কোনো ইভেন্ট তৈরি করা হয়নি',
      'start_event': 'ইভেন্ট শুরু করুন',
      'end_event': 'ইভেন্ট শেষ করুন',
      'reopen_event': 'পুনরায় চালু করুন',
      'analytics': 'এনালাইটিক্স',
      'view_analytics': 'লাইভ এনালাইটিক্স ও এআই রেজাল্ট দেখুন',
      'submit_feedback': 'ফিডব্যাক জমা দিন',
      'give_feedback': 'ইন্সট্যান্ট ফিডব্যাক দিন',
      'anonymous_note': '১০০% বেনামী (Anonymous) ফিডব্যাক। আপনার মন্তব্যটি এআই সেন্টিমেন্ট দিয়ে ইন্সট্যান্ট বিশ্লেষণ করা হয়।',
      'about_event': 'ইভেন্ট বিবরণী',
      'overall_satisfaction': 'সার্বিক সন্তুষ্টির অভিজ্ঞতা',
      'speaker_quality': 'বক্তা / প্রেজেন্টেশন গুণমান',
      'content_relevance': 'বিষয়বস্তু ও উপযোগিতা',
      'venue_facilities': 'ভেন্যু ও সার্বিক সুযোগ-সুবিধা',
      'write_comment': 'মন্তব্য বা পরামর্শ লিখুন',
      'comment_hint': 'যেমন: স্পিকারের প্রেজেন্টেশন অনেক ভালো ছিল, কিন্তু সাউন্ড সিস্টেম আরেকটু ভালো হতে পারতো...',
      'thank_you': 'ধন্যবাদ!',
      'feedback_success_desc': 'আপনার মূল্যবান ফিডব্যাক সফলভাবে জমা হয়েছে এবং এআই দিয়ে লাইভ বিশ্লেষণ করা হয়েছে।',
      'back_to_home': 'হোম পেজে ফিরে যান',
      'back_to_dashboard': 'ড্যাশবোর্ডে ফিরে যান',
      'copy_token': 'টোকেন কপি / শেয়ার করুন',
      'event_published': 'ইভেন্ট সফলভাবে প্রকাশিত হয়েছে!',
      'camera_scanner': 'লাইভ ক্যামেরা QR স্ক্যানার',
      'align_qr': 'ফ্রেমে QR কোড রাখুন অথবা নিচের বাটনে চাপ দিন',
      'scan_event_qr_button': 'ইভেন্ট QR কোড স্ক্যান করুন',
      'select_event_scan': 'স্ক্যান করার ইভেন্টটি নির্বাচন করুন',
      'no_events_available': 'স্ক্যান করার মতো কোনো ইভেন্ট নেই।',
      'already_submitted': 'ফিডব্যাক ইতোমধ্যে প্রদান করা হয়েছে',
      'anti_spam_lock_desc': 'আপনি এই ইভেন্টের জন্য ইতোমধ্যে আপনার বেনামী ফিডব্যাক জমা দিয়েছেন। ফিডব্যাকের নির্ভুলতা ও স্প্যাম সুরক্ষার জন্য এই ডিভাইসে পুনরায় ফিডব্যাক দেওয়া লক করা হয়েছে।',
      'feedback_locked': 'ফিডব্যাক সংরক্ষিত ও লকড',
      'live_audience_mood': 'লাইভ অডিয়েন্স মুড রিয়্যাকশন',
      'select_mood_hint': 'আপনার ইভেন্ট অনুভূতির ইমোজিতে চাপ দিন',
      'terrible': 'খুবই বাজে',
      'poor': 'অসন্তোষজনক',
      'neutral_mood': 'মাঝারি',
      'good': 'ভালো',
      'awesome': 'অসাধারণ!',
    },
  };

  String getText(String key) {
    final lang = languageNotifier.value;
    return _localizedValues[lang]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}
