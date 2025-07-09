import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/player_bloc.dart';
import 'playlists_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _allSongs = [];
  List<SongModel> _filteredSongs = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestPermissionAndFetchSongs();
    _searchController.addListener(_filterSongs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSongs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSongs = _allSongs
          .where((song) =>
              song.title.toLowerCase().contains(query) ||
              (song.artist?.toLowerCase() ?? '').contains(query))
          .toList();
    });
  }

  Future<void> _requestPermissionAndFetchSongs() async {
    var status = await Permission.audio.request();
    if (status.isGranted) {
      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      setState(() {
        _allSongs = songs;
        _filteredSongs = songs;
      });
    } else {
      print("Storage permission denied.");
    }
  }

  void _showAddToPlaylistSheet(SongModel song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900.withOpacity(0.8),
      builder: (context) {
        return FutureBuilder<List<PlaylistModel>>(
          future: _audioQuery.queryPlaylists(),
          builder: (context, item) {
            if (!item.hasData) return const Center(child: CircularProgressIndicator());
            if (item.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Önce bir çalma listesi oluşturun.",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return ListView.builder(
              itemCount: item.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  textColor: Colors.white,
                  iconColor: Colors.white,
                  leading: const Icon(Icons.playlist_add),
                  title: Text(item.data![index].playlist),
                  onTap: () {
                    _audioQuery.addToPlaylist(item.data![index].id, song.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("'${song.title}' listeye eklendi."),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Müzik Kütüphanesi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_play),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlaylistsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ara...',
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: _filteredSongs.isEmpty
                ? const Center(
                    child: Text('Şarkı bulunamadı', style: TextStyle(color: Colors.white)),
                  )
                : ListView.builder(
                    itemCount: _filteredSongs.length,
                    itemBuilder: (context, index) {
                      final song = _filteredSongs[index];
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
                        onTap: () {
                          final originalIndex = _allSongs.indexOf(song);
                          context.read<PlayerBloc>().add(PlayRequested(
                                songs: _allSongs,
                                initialIndex: originalIndex,
                              ));
                          Navigator.pop(context);
                        },
                        onLongPress: () {
                          _showAddToPlaylistSheet(song);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}