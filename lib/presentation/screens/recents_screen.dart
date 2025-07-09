import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:music_player/services/recents_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/player_bloc.dart';

class RecentsScreen extends StatefulWidget {
  const RecentsScreen({super.key});

  @override
  State<RecentsScreen> createState() => _RecentsScreenState();
}

class _RecentsScreenState extends State<RecentsScreen> {
  final RecentsService _recentsService = RecentsService();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  late Future<List<SongModel>> _recentsFuture;

  @override
  void initState() {
    super.initState();
    _recentsFuture = _loadRecents();
  }

  Future<List<SongModel>> _loadRecents() async {
    final recentIds = await _recentsService.getRecents();
    if (recentIds.isEmpty) return [];
    
    final allSongs = await _audioQuery.querySongs();
    final recentSongsMap = {for (var song in allSongs) song.id: song};
    
    return recentIds
        .map((id) => recentSongsMap[id])
        .where((song) => song != null)
        .cast<SongModel>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Son Çalınanlar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _recentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }
          final recents = snapshot.data;
          if (recents == null || recents.isEmpty) {
            return const Center(
              child: Text("Henüz hiç şarkı çalmadınız."),
            );
          }
          return ListView.builder(
            itemCount: recents.length,
            itemBuilder: (context, index) {
              final song = recents[index];
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.white),
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
                trailing: FutureBuilder<int>(
                  future: _recentsService.getPlayCount(song.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        '${snapshot.data} kez',
                        style: const TextStyle(color: Colors.white54),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                onTap: () {
                  context.read<PlayerBloc>().add(PlayRequested(
                        songs: recents,
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