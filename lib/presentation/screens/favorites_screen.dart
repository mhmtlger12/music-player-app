import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/application/bloc/player_bloc.dart';
import 'package:music_player/services/favorites_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  late Future<List<SongModel>> _favoriteSongsFuture;

  @override
  void initState() {
    super.initState();
    _favoriteSongsFuture = _loadFavorites();
  }

  Future<List<SongModel>> _loadFavorites() async {
    final favoriteIds = await _favoritesService.getFavorites();
    if (favoriteIds.isEmpty) {
      return [];
    }
    // on_audio_query maalesef ID listesine göre doğrudan bir sorguyu desteklemiyor.
    // Bu yüzden tüm şarkıları alıp filtreleyeceğiz.
    final allSongs = await _audioQuery.querySongs();
    return allSongs.where((song) => favoriteIds.contains(song.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Favoriler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _favoriteSongsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }
          final favoriteSongs = snapshot.data;
          if (favoriteSongs == null || favoriteSongs.isEmpty) {
            return const Center(
              child: Text(
                'Henüz favori şarkınız yok.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView.builder(
            itemCount: favoriteSongs.length,
            itemBuilder: (context, index) {
              final song = favoriteSongs[index];
              return ListTile(
                leading: const Icon(Icons.music_note, color: Colors.white),
                title: Text(
                  song.title,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  song.artist ?? "Bilinmeyen Sanatçı",
                  style: const TextStyle(color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () async {
                    await _favoritesService.removeFavorite(song.id);
                    setState(() {
                      _favoriteSongsFuture = _loadFavorites();
                    });
                  },
                ),
                onTap: () {
                  context.read<PlayerBloc>().add(PlayRequested(
                        songs: favoriteSongs,
                        initialIndex: index,
                      ));
                },
              );
            },
          );
        },
      ),
    );
  }
}