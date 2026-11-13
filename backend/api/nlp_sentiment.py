import re

class BanglaSentimentAnalyzer:
    """
    NLP Sentiment Analysis Engine for Bangla & Banglish text
    """
    NEGATIVE_KEYWORDS = [
        'bad', 'poor', 'terrible', 'boring', 'worst', 'waste', 'late', 'noise', 'slow',
        'kharap', 'baje', 'bekar', 'faltu', 'bhalona', 'valona', 'sundorna',
        'খারাপ', 'বাজে', 'বেকার', 'ফালতু', 'ভালো না', 'সুন্দর না', 'দেরি', 'শব্দ'
    ]

    POSITIVE_KEYWORDS = [
        'great', 'awesome', 'good', 'excellent', 'amazing', 'helpful', 'best',
        'sundor', 'valo', 'bhalo', 'darun', 'chomokdar', 'khub bhalo',
        'ভালো', 'সুন্দর', 'চমৎকার', 'দারুণ', 'অসাধারণ', 'উপকারী', 'খুব ভালো'
    ]

    VENUE_KEYWORDS = ['venue', 'room', 'ac', 'heat', 'sound', 'mic', 'microphones', 'volume', 'স্থান', 'ভেন্যু', 'শব্দ', 'এসি']
    SPEAKER_KEYWORDS = ['speaker', 'presentation', 'talk', 'presenter', 'বক্তা', 'স্পিকার', 'প্রেজেন্টেশন']
    CONTENT_KEYWORDS = ['content', 'topic', 'relevance', 'slide', 'বিষয়বস্তু', 'টপিক']

    @classmethod
    def analyze_comment(cls, comment, overall_val=3.0, speaker_val=3.0, content_val=3.0, venue_val=3.0):
        lower_comment = comment.lower().strip()
        issues = set()

        has_negative = any(re.search(r'\b' + re.escape(word) + r'\b', lower_comment) for word in cls.NEGATIVE_KEYWORDS)
        has_positive = any(re.search(r'\b' + re.escape(word) + r'\b', lower_comment) for word in cls.POSITIVE_KEYWORDS)

        avg_rating = (overall_val + speaker_val + content_val + venue_val) / 4.0

        if avg_rating <= 2.5:
            sentiment = 'Negative'
        elif avg_rating <= 3.5:
            sentiment = 'Neutral'
        else:
            sentiment = 'Positive'

        if has_negative:
            sentiment = 'Negative'
            issues.add('Improvement Needed')
        elif has_positive and sentiment == 'Neutral':
            sentiment = 'Positive'

        if venue_val <= 2.5 or any(k in lower_comment for k in cls.VENUE_KEYWORDS):
            issues.add('Venue & Facilities')
        if speaker_val <= 2.5 or any(k in lower_comment for k in cls.SPEAKER_KEYWORDS):
            issues.add('Speaker Quality')
        if content_val <= 2.5 or any(k in lower_comment for k in cls.CONTENT_KEYWORDS):
            issues.add('Content Relevance')

        if has_positive and not issues:
            issues.add('Engaging Content')

        if not issues:
            issues.add('General Satisfaction' if sentiment == 'Positive' else ('Needs Attention' if sentiment == 'Negative' else 'General Feedback'))

        return {
            'sentiment': sentiment,
            'key_issues': list(issues)
        }
