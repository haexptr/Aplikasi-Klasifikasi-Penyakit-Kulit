import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_picker_service.dart';
import '../services/classifier_service.dart';
import '../utils/constants.dart';
import 'result_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ClassifierService _classifierService = ClassifierService();
  bool _isProcessing = false;

  Future<void> _pickAndClassifyImage(bool fromCamera) async {
    try {
      // Check if classifier is initialized
      if (!_classifierService.isInitialized) {
        _showErrorDialog('Model belum siap. Silakan restart aplikasi.');
        return;
      }

      setState(() => _isProcessing = true);

      // Pick image
      File? imageFile;
      if (fromCamera) {
        imageFile = await _imagePickerService.pickImageFromCamera();
      } else {
        imageFile = await _imagePickerService.pickImageFromGallery();
      }

      if (imageFile == null) {
        setState(() => _isProcessing = false);
        return;
      }

      // Classify image
      final results = await _classifierService.classifyImage(imageFile.path);

      setState(() => _isProcessing = false);

      // Navigate to result screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              imagePath: imageFile!.path,
              predictions: results,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showErrorDialog('Error: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
            tooltip: 'Riwayat',
          ),
        ],
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memproses gambar...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.medical_information_outlined,
                            size: 80,
                            color: AppConstants.primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Selamat Datang',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppConstants.welcomeMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppConstants.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Instructions
                  Text(
                    'Pilih Sumber Gambar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Camera Button
                  _buildImageSourceButton(
                    icon: Icons.camera_alt,
                    label: 'Ambil Foto',
                    subtitle: 'Gunakan kamera untuk mengambil foto',
                    onPressed: () => _pickAndClassifyImage(true),
                  ),

                  const SizedBox(height: 16),

                  // Gallery Button
                  _buildImageSourceButton(
                    icon: Icons.photo_library,
                    label: 'Pilih dari Galeri',
                    subtitle: 'Pilih gambar dari galeri',
                    onPressed: () => _pickAndClassifyImage(false),
                  ),

                  const SizedBox(height: 32),

                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppConstants.disclaimer,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: AppConstants.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}