import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/disease_data.dart';

class DiseaseInfoScreen extends StatelessWidget {
  final String diseaseKey;

  const DiseaseInfoScreen({
    super.key,
    required this.diseaseKey,
  });

  @override
  Widget build(BuildContext context) {
    final diseaseInfo = DiseaseData.getDiseaseInfo()[diseaseKey];

    if (diseaseInfo == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Info Penyakit')),
        body: const Center(child: Text('Data penyakit tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(diseaseInfo['nameIndo']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              color: AppConstants.primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diseaseInfo['nameIndo'],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      diseaseKey,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Definition
            _buildSection(
              context,
              icon: Icons.article_outlined,
              title: 'Definisi Medis',
              content: diseaseInfo['definition'],
            ),

            const SizedBox(height: 16),

            // Symptoms
            _buildListSection(
              context,
              icon: Icons.warning_amber_outlined,
              title: 'Gejala',
              items: List<String>.from(diseaseInfo['symptoms']),
              color: Colors.orange,
            ),

            const SizedBox(height: 16),

            // Causes
            _buildListSection(
              context,
              icon: Icons.info_outline,
              title: 'Penyebab',
              items: List<String>.from(diseaseInfo['causes']),
              color: Colors.blue,
            ),

            const SizedBox(height: 16),

            // Treatment
            _buildListSection(
              context,
              icon: Icons.medical_services_outlined,
              title: 'Penanganan Awal',
              items: List<String>.from(diseaseInfo['treatment']),
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            // Warning Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.local_hospital, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Penting!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Informasi ini bersifat edukatif. Untuk diagnosis dan penanganan yang tepat, segera konsultasikan ke dokter atau dermatolog.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade900,
                            height: 1.5,
                          ),
                        ),
                      ],
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

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppConstants.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: AppConstants.textPrimary,
                height: 1.6,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppConstants.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}