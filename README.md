# 🏋️ W-GYM — Workout Tracker App

> Aplikasi pencatatan aktivitas gym berbasis Flutter dengan desain modern dan sinkronisasi offline-first menggunakan Hive dan Firebase Firestore.

---

## 📱 Tentang Aplikasi

**W-GYM** adalah aplikasi mobile workout tracker yang memungkinkan pengguna mencatat aktivitas latihan harian seperti nama latihan, durasi, kalori yang terbakar, dan jumlah repetisi. Aplikasi ini dirancang dengan pendekatan **offline-first** dan **Modern UI/UX**, memberikan pengalaman pengguna yang intuitif dan visual yang menarik.

---

## ✨ Fitur Utama

- **Modern UI/UX** — Desain premium dengan gradien, bayangan lembut, dan tata letak modern.
- **Visualisasi Data** — Grafik progres kalori mingguan yang interaktif menggunakan `fl_chart`.
- **Autentikasi Pengguna** — Login & Register dengan email/password atau Google Sign-In.
- **Catat Aktivitas** — Input latihan dengan kategori yang mudah digunakan dan kalkulasi kalori otomatis.
- **Dashboard Cerdas** — Ringkasan harian dengan salam dinamis dan statistik yang disinkronkan.
- **Riwayat Aktivitas** — Histori latihan lengkap dengan ikon cerdas berdasarkan jenis latihan.
- **Offline Support** — Data tersimpan lokal menggunakan Hive, tetap berfungsi tanpa internet.
- **Auto Sync** — Sinkronisasi otomatis ke Firestore saat koneksi tersedia.
- **Profil Pengguna** — Manajemen profil lengkap termasuk foto profil (Base64), BMI, dan pengaturan Dark Mode.

---

## 🛠️ Tech Stack

| Kategori | Library / Tool |
|---|---|
| Framework | Flutter (SDK ≥ 3.0.0) |
| UI & Font | Google Fonts, fl_chart |
| Local DB | Hive, Hive Flutter |
| Cloud DB | Firebase Firestore |
| Auth | Firebase Auth, Google Sign-In |
| Connectivity | connectivity_plus |
| Code Gen | build_runner, hive_generator |
| Utils | intl, uuid, image_picker |

---

## 📂 Struktur Proyek

```
wgywm-app/
├── android/                    # Konfigurasi platform Android
├── assets/                     # Aset gambar dan icon
├── lib/
│   ├── main.dart               # Entry point aplikasi
│   ├── firebase_options.dart   # Konfigurasi Firebase (auto-generated)
│   ├── models/
│   │   ├── activity.dart       # Model data Activity
│   │   └── activity.g.dart     # Hive adapter (generated)
│   ├── services/
│   │   ├── auth_service.dart   # Layanan Firebase Auth & Profile
│   │   ├── activity_service.dart # Layanan Hive & Firestore Sync
│   │   └── theme_service.dart  # Layanan manajemen tema & navigasi
│   ├── screens/
│   │   ├── login_screen.dart   # Autentikasi Login
│   │   ├── register_screen.dart # Registrasi Akun Baru
│   │   ├── main_nav.dart       # Navigasi Bottom Bar Modern
│   │   ├── dashboard_screen.dart # Ringkasan Progres & Grafik
│   │   ├── add_screen.dart     # Form Input Aktivitas
│   │   ├── history_screen.dart # Histori Aktivitas Lengkap
│   │   └── profile_screen.dart # Profil & Pengaturan
│   ├── widgets/
│   │   └── activity_card.dart  # Komponen Kartu Aktivitas Ikonik
│   └── theme/
│       └── app_theme.dart      # Definisi Tema Modern (Light/Dark)
├── web/                        # Konfigurasi platform Web
├── windows/                    # Konfigurasi platform Windows
├── pubspec.yaml                # Manajemen Dependency
└── firebase.json               # Konfigurasi Firebase
```

---

## ⚙️ Cara Kerja Offline + Sync

```
Ada internet      → Simpan ke Hive + Langsung sync ke Firestore
Tidak ada internet → Simpan ke Hive saja (flag synced: false)
Internet kembali  → Semua data pending otomatis dikirim ke Firestore via syncPending()
Buka app baru     → Mengunduh data terbaru dari Firestore ke Hive
```

---

## 🚀 Instalasi & Menjalankan

### Prasyarat

- Flutter SDK `>=3.0.0 <4.0.0`
- Dart SDK
- Firebase Account & CLI

### Langkah-langkah

**1. Clone repository**
```bash
git clone https://github.com/nandhitooo/wgywm-app.git
cd wgywm-app
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Konfigurasi Firebase**
Jalankan perintah berikut untuk mengonfigurasi Firebase:
```bash
flutterfire configure
```

**4. Generate Hive adapter**
```bash
dart run build_runner build
```

**5. Jalankan aplikasi**
```bash
flutter run
```

---

## 🎨 Design System

Aplikasi ini menggunakan sistem desain yang konsisten:
- **Primary Color:** Orange (`#F5A623`) dengan gradien ke Dark Orange.
- **Typography:** `DM Sans` untuk keterbacaan tinggi dan `Bebas Neue` untuk aksen judul yang sporty.
- **Components:** Card dengan radius 16-24px, bayangan lembut, dan indikator aktif yang intuitif.

---

## 📄 Lisensi

Proyek ini bersifat privat (`publish_to: none`). Dikembangkan oleh **nandhitooo**.
