import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecentsService {
  static const _recentsKey = 'recents_list';
  static const _playCountKey = 'play_count_map';
  static const _maxRecents = 50;

  /// Son dinlenen şarkıların ID listesini döndürür.
  Future<List<int>> getRecents() async {
    final prefs = await SharedPreferences.getInstance();
    final recentIds = prefs.getStringList(_recentsKey) ?? [];
    return recentIds.map(int.parse).toList();
  }

  /// Belirli bir şarkının dinlenme sayısını döndürür.
  Future<int> getPlayCount(int songId) async {
    final playCounts = await getPlayCountMap();
    return playCounts[songId.toString()] ?? 0;
  }

  /// Tüm şarkıların dinlenme sayılarını içeren bir harita döndürür.
  Future<Map<String, int>> getPlayCountMap() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_playCountKey) ?? '{}';
    return Map<String, int>.from(json.decode(jsonString).map((key, value) => MapEntry(key, value as int)));
  }

  /// Bir şarkı dinlendiğinde çağrılır. Hem son dinlenenler listesini günceller hem de dinlenme sayısını artırır.
  Future<void> addPlay(int songId) async {
    await _updateRecentsList(songId);
    await _incrementPlayCount(songId);
  }

  Future<void> _updateRecentsList(int songId) async {
    final prefs = await SharedPreferences.getInstance();
    final recents = (prefs.getStringList(_recentsKey) ?? []).map(int.parse).toList();
    
    recents.remove(songId);
    recents.insert(0, songId);

    if (recents.length > _maxRecents) {
      recents.removeLast();
    }

    await prefs.setStringList(_recentsKey, recents.map((id) => id.toString()).toList());
  }

  Future<void> _incrementPlayCount(int songId) async {
    final prefs = await SharedPreferences.getInstance();
    final playCounts = await getPlayCountMap();
    
    playCounts[songId.toString()] = (playCounts[songId.toString()] ?? 0) + 1;
    
    await prefs.setString(_playCountKey, json.encode(playCounts));
  }
}