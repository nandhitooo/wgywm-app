# W-GYM Flutter App — Database Integration Guide

Arsitektur:
- Hive → penyimpanan lokal (offline-first)
- Firebase Auth → autentikasi pengguna
- Cloud Firestore → sinkronisasi data ke cloud saat online

---

## LANGKAH 1 — Buat Project Firebase

1. Buka https://console.firebase.google.com
2. Klik "Add project" → beri nama (misal: wgym-app)
3. Klik Create project

---

## LANGKAH 2 — Aktifkan Firebase Auth

1. Sidebar kiri → Authentication → Get started
2. Tab Sign-in method → Email/Password → Enable → Save

---

## LANGKAH 3 — Aktifkan Firestore

1. Sidebar kiri → Firestore Database → Create database
2. Pilih "Start in test mode" → pilih region asia-southeast1 → Enable

Atur Firestore Rules (tab Rules):

  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /users/{userId}/activities/{activityId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }

---

## LANGKAH 4 — Hubungkan Flutter ke Firebase

  dart pub global activate flutterfire_cli
  flutterfire configure

Pilih project Firebase yang baru dibuat.
Perintah ini akan otomatis generate file lib/firebase_options.dart.

---

## LANGKAH 5 — Install & Jalankan

  flutter pub get
  flutter run

---

## Cara Kerja Offline + Sync

Ada internet     → simpan ke Hive + langsung sync ke Firestore
Tidak ada internet → simpan ke Hive saja (flag synced: false)
Internet kembali → semua data pending otomatis dikirim ke Firestore
Buka app baru   → fetch data terbaru dari Firestore ke Hive

---

## Struktur File

lib/
├── main.dart                    # Init Hive + Firebase, cek status login
├── firebase_options.dart        # AUTO-GENERATED oleh flutterfire configure
├── models/
│   ├── activity.dart            # Model Hive
│   └── activity.g.dart          # Hive adapter
├── services/
│   ├── auth_service.dart        # Firebase Auth
│   └── activity_service.dart   # Hive + Firestore sync
└── screens/ ...
