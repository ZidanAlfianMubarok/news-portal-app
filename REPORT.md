# Laporan Pembuatan Aplikasi Portal Berita Mobile

**AI Assistant:** Google DeepMind Antigravity (Gemini)

## 1. Persiapan Lingkungan & Koneksi (PENTING)

Sebelum menjalankan aplikasi, sangat penting untuk memastikan koneksi antara perangkat Mobile (HP Asli) dan Backend (Laptop) terhubung dengan benar dalam satu jaringan.

### A. Koneksi Jaringan
1.  Pastikan **Laptop** dan **HP Android** terhubung ke **WiFi yang sama**.
2.  Cek IP Address Laptop:
    *   Buka CMD (Command Prompt).
    *   Ketik `ipconfig`.
    *   Catat **IPv4 Address** (Contoh: `192.168.1.10`).

### B. Menjalankan Backend (Laravel)
Agar backend bisa diakses oleh HP, jangan gunakan `php artisan serve` biasa. Gunakan perintah berikut di terminal project Laravel:

```bash
php artisan serve --host=0.0.0.0
```

### C. Konfigurasi Frontend (Flutter)
Agar aplikasi Flutter bisa berkomunikasi dengan backend, kita perlu mengatur URL API di file `lib/config.dart`.

**Kode `lib/config.dart`:**
```dart
class Config {
  // Ganti 192.168.1.10 dengan IP Laptop Anda yang didapat dari ipconfig
  static const String baseUrl = 'http://192.168.1.10:8000/api';
}
```
*Penjelasan:* Dengan konfigurasi ini, aplikasi baik yang berjalan di Chrome (Laptop) maupun di HP Asli akan mengakses backend melalui IP jaringan lokal, bukan `localhost` (yang tidak dikenali oleh HP).

---

## 2. Langkah-Langkah Pembuatan Project

Berikut adalah langkah-langkah sistematis dalam membangun aplikasi Portal Berita ini dari awal hingga selesai.

### Langkah 1: Pembuatan Project Baru
Membuat project Flutter baru melalui terminal atau VS Code.

*Perintah:*
```bash
flutter create app_news_portal
```
*[Screenshot: Tampilan terminal saat menjalankan flutter create]*

### Langkah 2: Menambahkan Library (Dependencies)
Menambahkan library yang dibutuhkan ke dalam file `pubspec.yaml` untuk menangani HTTP request, state management, penyimpanan lokal, dan upload gambar.

**Dependencies yang digunakan:**
*   `http`: Untuk melakukan request API ke backend Laravel.
*   `provider`: Untuk manajemen state aplikasi (login user, data berita).
*   `shared_preferences`: Untuk menyimpan token login agar user tetap login saat aplikasi ditutup.
*   `image_picker`: Untuk mengambil gambar dari galeri saat membuat berita.
*   `intl`: Untuk formatting tanggal.

*[Screenshot: Tampilan file pubspec.yaml bagian dependencies]*

### Langkah 3: Struktur Folder Project
Mengatur struktur folder di dalam `lib/` agar kode rapi dan mudah dikelola:
*   `config.dart`: Konfigurasi global (URL API).
*   `models/`: Representasi data (User, News).
*   `services/`: Logika komunikasi ke API (AuthService, NewsService).
*   `providers/`: State management.
*   `screens/`: Tampilan antarmuka (UI) aplikasi.
*   `widgets/`: Komponen UI yang bisa digunakan kembali.

*[Screenshot: Tampilan struktur folder di sidebar VS Code]*

### Langkah 4: Implementasi Kode Utama

#### A. Model Data (`lib/models/news.dart`)
Membuat class untuk memetakan data JSON dari API menjadi objek Dart.

```dart
class News {
  final int id;
  final String title;
  final String content;
  final String? image;
  final int authorId;
  // ... constructor & factory method
}
```

#### B. Service API (`lib/services/api_service.dart`)
Membuat fungsi-fungsi untuk Login, Register, Get News, Create News, dll. Menggunakan library `http` untuk mengirim request POST/GET ke server Laravel.

#### C. State Management (`lib/providers/`)
Menggunakan `ChangeNotifier` untuk memisahkan logic dari UI. Contohnya `AuthProvider` untuk menyimpan status login user.

#### D. Tampilan (Screens)
*   **Login Screen**: Form untuk input email dan password.
*   **Home Screen**: Menampilkan daftar berita dalam bentuk list.
*   **News Detail**: Menampilkan detail berita dan komentar.
*   **News Form**: Form untuk menambah atau mengedit berita, termasuk upload gambar.

*[Screenshot: Tampilan Halaman Login]*
*[Screenshot: Tampilan Halaman Home dengan daftar berita]*

---

## 3. Cara Menjalankan Aplikasi

### A. Menjalankan di Google Chrome (Laptop)
1.  Pastikan Laravel sudah berjalan (`php artisan serve --host=0.0.0.0`).
2.  Pilih device "Chrome (Web)" di Flutter.
3.  Tekan F5 atau Run.

*[Screenshot: Tampilan aplikasi berjalan di Browser Chrome]*

### B. Menjalankan di HP Asli (Android)
1.  Aktifkan **USB Debugging** di HP (Masuk ke Developer Options).
2.  Hubungkan HP ke Laptop menggunakan kabel USB.
3.  Pastikan Laptop dan HP di **WiFi yang sama**.
4.  Pilih device HP Anda di Flutter.
5.  Tekan F5 atau Run.

*[Screenshot: Tampilan aplikasi berjalan di HP Asli]*

---
*Laporan ini dibuat dengan bantuan AI Google DeepMind Antigravity untuk mempercepat proses pengembangan dan debugging.*
