import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HealthDataService {
  static const _listeningHistoryKey = 'listening_history';
  static const _updateInterval = Duration(seconds: 15);

  StreamSubscription? _playingSubscription;
  Timer? _updateTimer;
  bool _isPlaying = false;

  String _getTodayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void startTracking(Stream<bool> playingStream) {
    _playingSubscription?.cancel();
    _playingSubscription = playingStream.listen((isPlaying) {
      _isPlaying = isPlaying;
      if (_isPlaying) {
        // Eğer çalıyorsa ve timer çalışmıyorsa, yeni bir timer başlat.
        _updateTimer ??= Timer.periodic(_updateInterval, (timer) {
          if (_isPlaying) {
            _incrementListeningTime(seconds: _updateInterval.inSeconds);
          } else {
            // Eğer çalma durduysa, timer'ı iptal et.
            _updateTimer?.cancel();
            _updateTimer = null;
          }
        });
      } else {
        // Eğer çalma durduysa, timer'ı iptal et.
        _updateTimer?.cancel();
        _updateTimer = null;
      }
    });
  }

  Future<void> _incrementListeningTime({required int seconds}) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _getTodayKey();
    
    final historyJson = prefs.getString(_listeningHistoryKey) ?? '{}';
    final Map<String, dynamic> history = json.decode(historyJson);
    
    final currentMillis = history[todayKey] ?? 0;
    history[todayKey] = currentMillis + (seconds * 1000);
    
    await prefs.setString(_listeningHistoryKey, json.encode(history));
  }

  Future<Duration> getDailyListeningTime() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _getTodayKey();
    
    final historyJson = prefs.getString(_listeningHistoryKey) ?? '{}';
    final Map<String, dynamic> history = json.decode(historyJson);

    final millis = history[todayKey] ?? 0;
    return Duration(milliseconds: millis);
  }

  Future<Map<DateTime, Duration>> getListeningHistory({int days = 7}) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_listeningHistoryKey) ?? '{}';
    final Map<String, dynamic> history = json.decode(historyJson);
    
    final Map<DateTime, Duration> result = {};
    final today = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final millis = history[dateKey] ?? 0;
      final cleanDate = DateTime(date.year, date.month, date.day);
      result[cleanDate] = Duration(milliseconds: millis);
    }
    
    return result;
  }

  Future<int> getHealthScore() async {
    final dailyTime = await getDailyListeningTime();
    final hours = dailyTime.inHours;

    if (hours < 2) return 95;
    if (hours < 4) return 75;
    if (hours < 6) return 50;
    return 25;
  }

  Future<String> getHealthRecommendation() async {
    final score = await getHealthScore();
    if (score > 90) return "Harika! Dinleme alışkanlıklarınız kulak sağlığınız için ideal görünüyor.";
    if (score > 70) return "İyi gidiyorsunuz. Kulağınıza dinlenmesi için ara sıra mola vermeyi unutmayın.";
    if (score > 40) return "Dinleme süreniz biraz yüksek. Kulaklarınızı korumak için daha sık mola vermeyi düşünün.";
    return "Dinleme süreniz önerilen seviyelerin üzerinde. İşitme sağlığınızı korumak için dinleme sürenizi azaltmanız önemlidir.";
  }

  void dispose() {
    _playingSubscription?.cancel();
    _updateTimer?.cancel();
  }
}