# Panduan Aset & Icon

Berikut adalah daftar gambar yang digunakan dalam aplikasi ini dan spesifikasi yang direkomendasikan jika Anda ingin menggantinya.

## 1. Icon Aplikasi (Launcher Icon)
Untuk mengganti icon aplikasi yang tampil di menu Android/iOS:

- **Lokasi File**: `assets/icon_launcher.png`
- **Ukuran Rekomendasi**: 1024 x 1024 piksel (PNG tanpa transparansi agar konsisten di iOS).
- **Cara Update**:
  Setelah mengganti file gambar, jalankan perintah berikut di terminal untuk men-generate icon ke folder native Android & iOS:
  ```bash
  flutter pub run flutter_launcher_icons
  ```

## 2. Ilustrasi "Gambar Tidak Dikenali"
Gambar ini muncul jika pengguna mengupload gambar random atau bukan kulit.

- **Lokasi File**: `assets/invalid_image.png`
- **Ukuran Rekomendasi**: 800 x 600 piksel atau ratio 4:3 (Transparent PNG).
- **Fungsi**: Memberikan feedback visual yang ramah saat AI gagal mendeteksi penyakit.

## 3. Catatan Lain
- **Tema Warna**: Warna aplikasi diatur di `lib/utils/constants.dart`. Anda bisa mengubah kode HEX di sana untuk menyesuaikan branding.
- **Labels**: Nama-nama penyakit ada di `assets/labels.txt` dan terjemahannya di `lib/utils/constants.dart`. Jangan ubah `labels.txt` karena harus sesuai dengan model AI (`.tflite`).

---
*Dibuat otomatis oleh AI Assistant.*
