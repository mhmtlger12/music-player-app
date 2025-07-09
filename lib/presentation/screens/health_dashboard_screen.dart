import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/services/health_data_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HealthDashboardScreen extends StatelessWidget {
  const HealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final healthDataService = RepositoryProvider.of<HealthDataService>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Sağlık Paneli'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D2A49), Color(0xFF0D1321)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder(
              // Birden çok future'ı aynı anda beklemek için Future.wait kullanıyoruz.
              future: Future.wait([
                healthDataService.getListeningHistory(days: 7),
                healthDataService.getHealthScore(),
                healthDataService.getHealthRecommendation(),
              ]),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Veri alınamadı: ${snapshot.error}'));
                }

                final history = snapshot.data![0] as Map<DateTime, Duration>;
                final healthScore = snapshot.data![1] as int;
                final recommendation = snapshot.data![2] as String;

                final todayKey = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                final todayDuration = history[todayKey] ?? Duration.zero;
                final hours = todayDuration.inHours;
                final minutes = todayDuration.inMinutes.remainder(60);

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Bugünkü Toplam Dinleme Süreniz',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$hours saat $minutes dakika',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w200,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildHealthScoreCard(context, healthScore, recommendation),
                      const SizedBox(height: 40),
                      const Text(
                        'Haftalık Özet (Dakika)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: WeeklyListeningChart(history: history),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(BuildContext context, int score, String recommendation) {
    Color scoreColor;
    if (score > 90) {
      scoreColor = Colors.greenAccent;
    } else if (score > 70) {
      scoreColor = Colors.lightGreen;
    } else if (score > 40) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Text(
            'Ses Sağlığı Puanınız',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            recommendation,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class WeeklyListeningChart extends StatelessWidget {
  final Map<DateTime, Duration> history;

  const WeeklyListeningChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final sortedEntries = history.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    final barGroups = sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value.key;
      final duration = entry.value.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: duration.inMinutes.toDouble(),
            color: Theme.of(context).colorScheme.secondary,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (history.values.map((d) => d.inMinutes).reduce((a, b) => a > b ? a : b).toDouble() * 1.2) + 10,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final duration = sortedEntries[groupIndex].value;
              return BarTooltipItem(
                '${duration.inMinutes} dk',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedEntries.length) {
                  final date = sortedEntries[index].key;
                  final day = DateFormat.E('tr_TR').format(date);
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(day, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  );
                }
                return const Text('');
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: barGroups,
      ),
    );
  }
}