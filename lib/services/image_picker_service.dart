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

  // Request storage permission (for gallery)
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+ uses different permissions
      final androidInfo = await Permission.photos.status;
      if (androidInfo.isDenied) {
        final result = await Permission.photos.request();
        return result.isGranted;
      }
      return androidInfo.isGranted;
    } else {
      // iOS
      final status = await Permission.photos.request();
      return status.isGranted;
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      // Request permission
      final hasPermission = await requestCameraPermission();
      if (!hasPermission) {
        debugPrint('Izin kamera ditolak');
        return null;
      }

      // Pick image
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      // Request permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        debugPrint('Izin penyimpanan ditolak');
        return null;
      }

      // Pick image
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }
}