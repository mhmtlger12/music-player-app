import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _favoritesKey = 'favorites';

  Future<List<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
    return favoriteIds.map(int.parse).toList();
  }

  Future<void> addFavorite(int songId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.contains(songId)) {
      favorites.add(songId);
      await prefs.setStringList(_favoritesKey, favorites.map((id) => id.toString()).toList());
    }
  }

  Future<void> removeFavorite(int songId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (favorites.contains(songId)) {
      favorites.remove(songId);
      await prefs.setStringList(_favoritesKey, favorites.map((id) => id.toString()).toList());
    }
  }

  Future<bool> isFavorite(int songId) async {
    final favorites = await getFavorites();
    return favorites.contains(songId);
  }
}