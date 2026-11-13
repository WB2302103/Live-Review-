# EventPulse — Real-Time Audience Feedback & AI Analytics Platform

**EventPulse** is a cross-platform Flutter application integrated with a **Django REST Framework (DRF)** backend and **PostgreSQL 18** database. It provides real-time audience feedback, AI sentiment analytics (Bangla & Banglish NLP), automated speaker certificates, and emergency venue/sound alert monitoring.

---

## 🏛️ Architecture & Tech Stack

* **Frontend:** Flutter (Dart) — Cross-platform Android / Web / Desktop UI
* **Backend API:** Django REST Framework (DRF) — Python RESTful API
* **Database:** PostgreSQL 18 (`eventpulse_db`) — Relational Production Database
* **AI / NLP Engine:** Bangla & Banglish Natural Language Processing (NLP) Sentiment Classifier
* **Security:** Anti-Spam Device & Session Token Verification Lock

---

## 🚀 Quick Start Guide

### 1. Run Django REST API Backend & PostgreSQL

```bash
cd backend
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 8000
```

* **Django REST API Base URL:** `http://127.0.0.1:8000/api/`
* **Django Admin Panel:** `http://127.0.0.1:8000/admin/` (User: `admin` | Pass: `admin`)

---

### 2. Run Flutter Frontend Application

```bash
flutter pub get
flutter run -d chrome
```

---

## ✨ Features

1. **High-Tech Neon Laser QR Scanner:** Viewport scanner with flash toggle.
2. **Interactive Feedback Rating Form:** Touch rating rows with toggle/deselect reset.
3. **Anti-Spam Security Lock:** Single submission restriction per device.
4. **Live Audience Feedback Stream Ticker:** Auto-cycling live review feed.
5. **Emergency Sound & Venue Alert Banner:** Real-time audio/AC facility problem alerts.
6. **AI Sentiment Analytics Dashboard:** Positive/Neutral/Negative % & Topic Tag Chips.
7. **Shareable Event Report Card:** Export to PDF & Excel (CSV/XLSX) format.
8. **Automated Speaker Certificate:** Excellence certificate generator for keynote speakers.
9. **Bilingual Localization:** Instant English & Bangla language toggle.
10. **Dynamic Theme Engine:** Slate Obsidian Dark Theme & Emerald Teal Light Theme.
