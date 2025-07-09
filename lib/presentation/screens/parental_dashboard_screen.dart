import 'package:flutter/material.dart';
import 'package:music_player/services/health_data_service.dart';

class ParentalDashboardScreen extends StatefulWidget {
  const ParentalDashboardScreen({super.key});

  @override
  State<ParentalDashboardScreen> createState() => _ParentalDashboardScreenState();
}

class _ParentalDashboardScreenState extends State<ParentalDashboardScreen> {
  final HealthDataService _healthDataService = HealthDataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Ebeveyn Kontrol Paneli'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Günlük Dinleme Aktiviteleri',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            FutureBuilder<Duration>(
              future: _healthDataService.getDailyListeningTime(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final duration = snapshot.data!;
                final hours = duration.inHours;
                final minutes = duration.inMinutes.remainder(60);
                return Card(
                  color: Colors.grey.shade900,
                  child: ListTile(
                    leading: const Icon(Icons.timer, color: Colors.white),
                    title: const Text('Toplam Dinleme Süresi', style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      '$hours saat $minutes dakika',
                      style: const TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ),
                );
              },
            ),
            // TODO: Diğer sağlık metrikleri buraya eklenecek (Ortalama ses seviyesi, Mola sayısı vb.)
          ],
        ),
      ),
    );
  }
}