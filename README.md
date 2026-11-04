<p align="center">
  <img src="assets/images/logo.webp" alt="KwakTodo Mascot" width="160" style="border-radius: 40px; box-shadow: 0 14px 32px rgba(249, 115, 22, 0.3);" />
</p>

<h1 align="center">🦆 KwakTodo</h1>

<p align="center">
  <strong>Personal Task & Schedule Manager with Multimodal Gemini AI (100% Offline-First SQLite)</strong><br />
  <em>"Biar bebek yang pusing mikir, kamu santai aja."</em>
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.38+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" /></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.10+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" /></a>
  <a href="https://drift.simonbinder.eu/"><img src="https://img.shields.io/badge/SQLite-Drift-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite Drift" /></a>
  <a href="https://ai.google.dev/"><img src="https://img.shields.io/badge/AI-Gemini%20Flash-8E75C2?style=for-the-badge&logo=google&logoColor=white" alt="Gemini AI" /></a>
  <a href="#"><img src="https://img.shields.io/badge/Tests-35%20Passed-059669?style=for-the-badge&logo=checkmarx&logoColor=white" alt="Tests" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-F97316?style=for-the-badge" alt="License" /></a>
</p>

<p align="center">
  <a href="#-kenapa-kwaktodo">Tentang</a> •
  <a href="#-fitur-utama">Fitur Utama</a> •
  <a href="#-arsitektur-sistem">Arsitektur</a> •
  <a href="#-tech-stack">Tech Stack</a> •
  <a href="#-instalasi--menjalankan">Mulai</a> •
  <a href="#-pengujian-testing">Testing</a>
</p>

---

## 💡 Kenapa KwakTodo?

Pernah merasa **cengo** dan bengong karena banyak tugas tapi lupa apa saja dan kapan deadline-nya? Atau saking **mager**-nya, malas mengetik di aplikasi to-do list biasa yang form-nya kaku dan ribet?

**KwakTodo** hadir dengan pendekatan yang santai, intuitif, dan tidak bikin pusing:
* 🗣️ **Tinggal Ngomong**: Rekam suara sambil rebahan, AI akan otomatis mem-parsing judul tugas, deadline, kategori, dan prioritasnya.
* 📸 **Jepret Foto**: Screenshot chat grup tugas, foto whiteboard kelas, atau foto berkas; AI Vision langsung mengekstrak tugasnya.
* ✍️ **Ketik Bebas**: Tulis satu kalimat panjang sembarangan, AI merapikannya menjadi item to-do yang terstruktur.
* 🛡️ **Human-in-the-Loop**: AI tidak pernah langsung menulis ke database secara sembunyi-sembunyi. Hasil parsing selalu melalui layar review & edit agar Anda yang memegang kendali penuh.
* 🔒 **Privasi 100% Aman (Offline-First)**: Semua data tugas tersimpan di ponsel lokal Anda menggunakan SQLite (Drift). Tanpa backend, tanpa sinkronisasi server asing, tanpa analitik pelacak.

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|---|---|
| 🎙️ **Smart Voice AI** | Pengenalan suara *on-device* Bahasa Indonesia. Bicara santai mendiktekan tugas, Gemini AI mengekstraknya secara instan. |
| 📸 **Vision Task Extractor** | Mengambil foto langsung dari kamera atau galeri, dikompresi otomatis, lalu diproses AI Vision menjadi to-do. |
| 📝 **Free Text Parser** | Prompt bahasa bebas (Indonesia/Inggris). AI otomatis memetakan tingkat urgensi (*Tinggi/Sedang/Santai*) & kategori. |
| ⏰ **Smart Local Reminder** | Notifikasi terjadwal lokal otomatis (H-N hari jam 08:00) yang hemat baterai dan bertahan meski ponsel di-restart. |
| 📅 **Kalender Jadwal Bulanan** | Tampilan kalender interaktif dengan sistem *dot status* (krem = ada tugas, ungu = deadline aktif, garis merah = overdue). |
| 📊 **Statistik Visual** | Ring progres persentase selesai, distribusi 4 kategori pastel, dan grafik beban deadline 7 hari. |
| 🦆 **Animasi Launcher Lucu** | Animasi pembuka maskot bebek cengo dengan *elastic bounce* dan tagline jenaka yang tidak alay. |
| ⚡ **Cross-Device Responsive** | Tahan di semua resolusi HP (320px compact hingga tablet/foldable) tanpa *RenderFlex overflow* dan bebas jank. |

---

## 🎨 Palet Desain & Kategori

KwakTodo mengadopsi estetika *warm & playful* yang nyaman di mata:

* 🟠 **Primary Brand**: `#F97316` (Warm Orange) & `#FFEDD5` (Primary Soft)
* 🍦 **Background**: `#FDF1E3` (Warm Cream) & `#FFFFFF` (Surface Card)
* 🔵 **Akademik**: `#BFD7FE` (Soft Blue) • Teks `#1E3A8A`
* 🌸 **Personal**: `#F9C9D4` (Soft Pink) • Teks `#9D174D`
* 🟣 **Organisasi**: `#DDD1FC` (Soft Purple) • Teks `#5B21B6`
* 🍋 **Lainnya**: `#FDE9A8` (Soft Lemon) • Teks `#854D0E`

---

## 🏗️ Arsitektur Sistem

KwakTodo dibangun dengan prinsip **Separation of Concerns** dan **Offline-First Reactive Architecture**:

```
[ Input: Suara / Teks / Foto ]
             │
             ▼
   ┌───────────────────┐
   │   GeminiService   │ ──► Multi-Key Fallback (Auto-rotation on HTTP 429)
   │  (gemini-flash)   │ ──► Structured Output JSON Schema
   └───────────────────┘
             │
             ▼
   ┌───────────────────┐
   │   TaskFormSheet   │ ──► Review & Edit Mode (Human-in-the-loop)
   └───────────────────┘
             │ (Acc & Tambahkan)
             ▼
   ┌───────────────────┐
   │   TaskProvider    │ ◄── Reactive Stream Subscription
   └───────────────────┘
             │
      ┌──────┴──────┐
      ▼             ▼
┌───────────┐ ┌───────────────────┐
│  TaskDao  │ │ ReminderScheduler │ ──► Scheduled Alarm (H-N Jam 08:00)
│  (Drift)  │ └───────────────────┘
└───────────┘
      │
      ▼
┌───────────────────┐
│   SQLite on HP    │ (100% Lokal & Terenkripsi)
└───────────────────┘
```

---

## 🛠️ Tech Stack

* **Mobile Framework**: [Flutter 3.38+](https://flutter.dev) & [Dart 3.10+](https://dart.dev)
* **Local Persistence**: [Drift](https://drift.simonbinder.eu/) (Type-safe SQLite ORM)
* **State Management**: [Provider](https://pub.dev/packages/provider)
* **AI & LLM**: Google Gemini REST API (`gemini-3.5-flash-lite`) via direct HTTPS
* **Speech to Text**: [speech_to_text](https://pub.dev/packages/speech_to_text) (On-device native STT)
* **Image Processing**: [image_picker](https://pub.dev/packages/image_picker) & [flutter_image_compress](https://pub.dev/packages/flutter_image_compress)
* **Scheduled Alarm**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) & [timezone](https://pub.dev/packages/timezone)
* **Secure Storage**: [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) (Android Keystore / iOS Keychain)
* **E2E Testing**: [tester-army/e2e](https://github.com/tester-army/e2e) & Flutter Integration Test

---

## 🏁 Memulai (Getting Started)

### Prasyarat
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi 3.38 atau lebih baru)
* Android SDK / Android Studio
* Perangkat Android fisik atau Emulator

### Langkah Menjalankan

1. **Clone repository**:
   ```bash
   git clone https://github.com/StevBeq/KwakTodo.git
   cd KwakTodo
   ```

2. **Unduh dependencies**:
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**:
   ```bash
   flutter run
   ```

4. **Kompilasi APK Release**:
   ```bash
   flutter build apk --release
   ```
   *File APK siap pakai akan berada di `build/app/outputs/flutter-apk/app-release.apk`.*

---

## 🧪 Pengujian (Testing)

Proyek ini telah lulus seluruh rangkaian pengujian fungsional dan keamanan (**35/35 passing**):

```bash
# Jalankan seluruh unit & widget tests
flutter test

# Jalankan pengujian E2E headless
flutter test test/e2e_flow_test.dart

# Jalankan analisis kualitas kode
flutter analyze
```

Untuk pengujian otomatis menggunakan agen AI (`tester-army/e2e`):
```bash
cd e2e
npm install
npm run test:e2e:android
```

---

## 🔒 Keamanan & Privasi

* **Tanpa Pelacakan**: Tidak ada analitik pihak ketiga atau tracker perilaku pengguna.
* **Enkripsi API Key**: Kunci API Google Gemini disimpan di Android Keystore terenkripsi, tidak pernah tersimpan di database SQLite biasa atau terekspos di log.
* **Jaringan Aman**: Seluruh koneksi ke Google Gemini menggunakan HTTPS dengan `android:usesCleartextTraffic="false"`.

---

## 📄 Lisensi

Didistribusikan di bawah lisensi **MIT**. Lihat berkas [LICENSE](LICENSE) untuk informasi lebih lanjut.

<p align="center">
  Dibuat dengan ❤️ dan rasa mager oleh <strong>StevBeq</strong>
</p>
