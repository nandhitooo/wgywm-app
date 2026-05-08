# 🏋️ W-GYM — Workout Tracker App

> Aplikasi pencatatan aktivitas gym berbasis Flutter dengan sinkronisasi offline-first menggunakan Hive dan Firebase Firestore.

---

## 📱 Tentang Aplikasi

**W-GYM** adalah aplikasi mobile workout tracker yang memungkinkan pengguna mencatat aktivitas latihan harian seperti nama latihan, durasi, kalori yang terbakar, dan jumlah repetisi. Aplikasi ini dirancang dengan pendekatan **offline-first**, sehingga tetap bisa digunakan tanpa koneksi internet dan akan otomatis menyinkronkan data ke cloud saat koneksi tersedia.

---

## ✨ Fitur Utama

- **Autentikasi Pengguna** — Login & Register dengan email/password atau Google Sign-In
- **Catat Aktivitas** — Input nama latihan, durasi, kalori, dan reps
- **Dashboard Harian** — Ringkasan total kalori, durasi, dan reps hari ini
- **Riwayat Aktivitas** — Lihat seluruh histori latihan
- **Offline Support** — Data tersimpan lokal menggunakan Hive, tetap berfungsi tanpa internet
- **Auto Sync** — Data otomatis tersinkronisasi ke Firestore saat koneksi tersedia
- **Profil Pengguna** — Data pribadi seperti nama, berat badan, tinggi badan, dan tanggal lahir

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

---

## 📂 Struktur Proyek

```
wgywm-app/
├── android/                    # Konfigurasi Android
├── assets/
│   └── icon.png                # App icon
├── lib/
│   ├── main.dart               # Entry point — init Hive + Firebase, cek status login
│   ├── firebase_options.dart   # Auto-generated oleh flutterfire configure
│   ├── models/
│   │   ├── activity.dart       # Model data Hive (Activity)
│   │   └── activity.g.dart     # Hive adapter (generated)
│   ├── services/
│   │   ├── auth_service.dart   # Firebase Auth (register, login, Google Sign-In)
│   │   └── activity_service.dart # Hive + Firestore sync service
│   ├── screens/
│   │   ├── login_screen.dart   # Halaman login
│   │   ├── register_screen.dart # Halaman registrasi
│   │   ├── main_nav.dart       # Bottom navigation utama
│   │   ├── dashboard_screen.dart # Dashboard ringkasan harian
│   │   ├── add_screen.dart     # Form tambah aktivitas
│   │   ├── history_screen.dart # Riwayat aktivitas
│   │   └── profile_screen.dart # Profil pengguna
│   ├── widgets/
│   │   └── activity_card.dart  # Widget kartu aktivitas
│   └── theme/
│       └── app_theme.dart      # Konfigurasi tema aplikasi
├── web/                        # Konfigurasi Web (PWA)
├── windows/                    # Konfigurasi Windows desktop
├── pubspec.yaml                # Dependency management
└── firebase.json               # Konfigurasi Firebase
```

---

## ⚙️ Cara Kerja Offline + Sync

```
Ada internet      → simpan ke Hive + langsung sync ke Firestore
Tidak ada internet → simpan ke Hive saja (flag synced: false)
Internet kembali  → semua data pending otomatis dikirim ke Firestore
Buka app baru     → fetch data terbaru dari Firestore ke Hive
```

---

## 🚀 Instalasi & Menjalankan

### Prasyarat

- Flutter SDK `>=3.0.0 <4.0.0`
- Dart SDK
- Android Studio / VS Code
- Akun Firebase (untuk konfigurasi backend)

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

Pastikan file `lib/firebase_options.dart` sudah ada. Jika belum, jalankan:
```bash
flutterfire configure
```
> Ikuti panduan untuk menghubungkan project ke Firebase Console.

**4. Generate Hive adapter** *(jika diperlukan)*
```bash
dart run build_runner build
```

**5. Jalankan aplikasi**
```bash
flutter run
```

---

## 🗃️ Model Data

### Activity

| Field | Tipe | Keterangan |
|---|---|---|
| `id` | String | UUID unik per aktivitas |
| `name` | String | Nama latihan |
| `durationMinutes` | int | Durasi dalam menit |
| `calories` | int | Kalori yang terbakar |
| `reps` | int | Jumlah repetisi |
| `date` | DateTime | Tanggal dan waktu aktivitas |
| `userId` | String | UID pengguna dari Firebase Auth |
| `synced` | bool | Status sinkronisasi ke Firestore |

---

## 🔐 Autentikasi

Aplikasi mendukung dua metode autentikasi via Firebase Auth:

- **Email & Password** — Register dan login dengan email
- **Google Sign-In** — Login satu klik menggunakan akun Google

Data profil pengguna (nama, email, tanggal lahir, berat, tinggi) disimpan di koleksi `users` pada Firestore.

---

## 📄 Lisensi

Proyek ini bersifat privat (`publish_to: none`). Hak cipta milik **nandhitooo**.
