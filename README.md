## Install & Jalankan

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
