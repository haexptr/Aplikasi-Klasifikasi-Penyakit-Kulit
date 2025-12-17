import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  // Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Request storage permission (for gallery) - simplified & robust
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Request storage first (works for many Android versions)
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) return true;
      // fallback try photos/media (Android 13+)
      final photos = await Permission.photos.request();
      return photos.isGranted;
    } else {
      // iOS
      final status = await Permission.photos.request();
      return status.isGranted;
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final hasPermission = await requestCameraPermission();
      if (!hasPermission) {
        debugPrint('Izin kamera ditolak');
        return null;
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (photo != null) return File(photo.path);
      return null;
    } catch (e, st) {
      debugPrint('Error picking image from camera: $e\n$st');
      return null;
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        debugPrint('Izin penyimpanan ditolak');
        return null;
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (photo != null) return File(photo.path);
      return null;
    } catch (e, st) {
      debugPrint('Error picking image from gallery: $e\n$st');
      return null;
    }
  }
}
