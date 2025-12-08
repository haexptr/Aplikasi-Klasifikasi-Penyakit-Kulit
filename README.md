# DiagnosisKulit - Aplikasi Klasifikasi Penyakit Kulit

Aplikasi Android untuk mendiagnosis penyakit kulit menggunakan Deep Learning (EfficientNetB0) dengan TensorFlow Lite.

## 📋 Fitur Lengkap

### Fitur Utama
- ✅ Klasifikasi 22 jenis penyakit kulit
- ✅ Ambil foto dari kamera atau galeri
- ✅ Prediksi real-time dengan TFLite
- ✅ Confidence score dengan color coding (hijau/oranye/merah)
- ✅ Top-3 predictions alternatif
- ✅ Database SQLite untuk history
- ✅ Info detail setiap penyakit (gejala, penyebab, penanganan)
- ✅ Warning untuk hasil confidence rendah (<50%)
- ✅ Disclaimer medis di setiap hasil

### 22 Kategori Penyakit
1. Acne (Jerawat)
2. Actinic Keratosis
3. Benign Tumors (Tumor Jinak)
4. Bullous (Penyakit Melepuh)
5. Candidiasis
6. Drug Eruption (Erupsi Obat)
7. Eczema (Eksim)
8. Infestations & Bites
9. Lichen
10. Lupus
11. Moles (Tahi Lalat)
12. Psoriasis
13. Rosacea
14. Seborrheic Keratoses
15. Skin Cancer (Kanker Kulit)
16. Sun Damage
17. Tinea (Kurap)
18. Unknown/Normal
19. Vascular Tumors
20. Vasculitis
21. Vitiligo
22. Warts (Kutil)

---

## 🚀 Cara Setup Project

### 1. Prerequisites
Pastikan sudah terinstall:
- Flutter SDK (≥3.0.0)
- Android Studio / VS Code
- Android SDK & Emulator / Device fisik

### 2. Clone/Setup Project
```bash
# Jika belum ada project Flutter
flutter create diagnosiskulit
cd diagnosiskulit

# Copy semua file yang sudah digenerate ke folder project
```

### 3. Setup File Structure

Buat struktur folder seperti ini:

```
diagnosiskulit/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── prediction.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── result_screen.dart
│   │   ├── history_screen.dart
│   │   ├── history_detail_screen.dart
│   │   └── disease_info_screen.dart
│   ├── services/
│   │   ├── classifier_service.dart
│   │   ├── database_service.dart
│   │   └── image_picker_service.dart
│   └── utils/
│       ├── constants.dart
│       └── disease_data.dart
├── assets/
│   ├── model_dynamic_quant.tflite  ← PENTING!
│   └── labels.txt
├── android/
│   └── app/
│       └── src/
│           └── main/
│               └── AndroidManifest.xml  ← Update permissions
└── pubspec.yaml
```

### 4. Copy File Model TFLite

**SANGAT PENTING!** Copy file model dari project Python kamu:

```bash
# Buat folder assets
mkdir -p assets

# Copy file model (dari folder saved_model di project Python)
cp /path/to/SkinDisease/saved_model/model_dynamic_quant.tflite assets/

# Buat file labels.txt di folder assets (sudah digenerate)
```

### 5. Update AndroidManifest.xml

Replace file `android/app/src/main/AndroidManifest.xml` dengan yang sudah digenerate (sudah include permissions untuk camera & storage).

### 6. Install Dependencies

```bash
flutter pub get
```

Jika ada error, coba:
```bash
flutter clean
flutter pub get
```

### 7. Setup TFLite Flutter

Untuk Android, tambahkan di `android/app/build.gradle`:

```gradle
android {
    // ... existing config
    
    aaptOptions {
        noCompress 'tflite'
        noCompress 'lite'
    }
}
```

### 8. Build & Run

```bash
# Check devices
flutter devices

# Run di device/emulator
flutter run

# Atau build APK
flutter build apk --release
```

---

## 📱 Testing Aplikasi

### Test Flow:
1. **Home Screen** → Klik "Ambil Foto" atau "Pilih dari Galeri"
2. Izinkan permission kamera/storage
3. Pilih/ambil gambar penyakit kulit
4. Tunggu proses prediksi (~1-3 detik)
5. **Result Screen** → Lihat hasil diagnosis:
   - Nama penyakit (Indonesia & English)
   - Confidence score dengan color indicator
   - Top-3 predictions
   - Warning jika confidence <50%
6. Klik "Lihat Info Penyakit" → Info detail penyakit
7. Klik "Simpan" → Tersimpan di database
8. **History Screen** → Lihat semua riwayat
9. Swipe left untuk delete

---

## 🐛 Troubleshooting

### Error: "Failed to load model"
**Solusi:**
- Pastikan file `model_dynamic_quant.tflite` ada di folder `assets/`
- Cek `pubspec.yaml` sudah list asset dengan benar
- Run `flutter clean && flutter pub get`

### Error: "Permission denied" (Camera/Storage)
**Solusi:**
- Pastikan `AndroidManifest.xml` sudah update dengan permissions
- Uninstall app, lalu install ulang
- Di Android 13+, pastikan izin `READ_MEDIA_IMAGES` diberikan

### Error: "Image picker not working"
**Solusi:**
- Cek apakah device/emulator punya kamera
- Pastikan ada gambar di galeri (untuk test)
- Test di device fisik jika emulator bermasalah

### Error: Database/SQLite
**Solusi:**
- Uninstall app, install ulang (reset database)
- Cek path database di device: `path_provider` harus return path yang valid

### Model prediksi tidak akurat
**Penyebab:**
- Model belum fully trained (1 epoch)
- Dataset tidak seimbang
- Gambar test berbeda dengan training data

**Saran:**
- Training ulang dengan lebih banyak epoch (50-100)
- Data augmentation
- Fine-tuning hyperparameter

---

## 📊 Model Specifications

- **Architecture:** EfficientNetB0
- **Input Size:** 224x224x3
- **Output:** 22 classes (softmax)
- **Format:** TFLite (quantized)
- **Size:** ~16MB (quantized)

---

## 🎓 Untuk Presentasi ke Dosen

### Poin Kunci:
1. **Hybrid System**: Sistem pakar (rules) + Deep Learning (CNN)
2. **Data Valid**: Info penyakit dari sumber medis terpercaya (PERDOSKI, StatPearls, WHO)
3. **User Experience**: 
   - Confidence threshold dengan warning
   - Color coding (hijau/oranye/merah)
   - Disclaimer medis wajib
4. **Full Features**: CRUD database, history, detail info penyakit
5. **Production Ready**: Error handling, permission management, responsive UI

### Demo Scenario:
1. Buka app → Splash screen
2. Home → Jelaskan fitur
3. Ambil foto sample (siapkan gambar test)
4. Tunjukkan hasil prediksi + confidence
5. Masuk ke "Info Penyakit" → Tunjukkan data medis valid
6. Simpan ke history
7. Buka history → Swipe to delete
8. Tunjukkan warning untuk confidence rendah

---

## 📝 Catatan Penting

### Disclaimer
Aplikasi ini **BUKAN** pengganti diagnosis medis profesional. Selalu konsultasikan ke dokter/dermatolog untuk diagnosis dan penanganan yang tepat.

### Data Sources
- PERDOSKI (Perhimpunan Dokter Spesialis Kulit dan Kelamin Indonesia)
- StatPearls - National Library of Medicine
- WHO (World Health Organization)
- DermNet NZ
- American Academy of Dermatology

### Limitations
- Akurasi tergantung kualitas training data
- Model belum di-validate secara klinis
- Hasil bersifat indikatif, bukan diagnosis final

---

## 👨‍💻 Developer

Project ini dibuat untuk tugas akhir mata kuliah Kecerdasan Buatan.

**Tech Stack:**
- Flutter 3.0+
- TensorFlow Lite
- SQLite
- EfficientNetB0

---

## 📄 License

Educational Purpose Only - Not for Medical Use

---

## 🆘 Need Help?

Jika ada error atau pertanyaan:
1. Cek bagian Troubleshooting
2. Pastikan semua file sudah di-copy dengan benar
3. Verify model TFLite ada di folder assets
4. Run `flutter doctor` untuk cek environment

**Good luck! 🚀**