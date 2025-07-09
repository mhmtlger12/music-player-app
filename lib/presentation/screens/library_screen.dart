import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/player_bloc.dart';
import 'playlists_screen.dart';
import 'recents_screen.dart';
import 'favorites_screen.dart';

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
  SongSortType _sortType = SongSortType.TITLE;
  OrderType _orderType = OrderType.ASC_OR_SMALLER;

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
    PermissionStatus status = await Permission.audio.request();

    if (status.isGranted) {
      _fetchSongs();
    } else if (status.isPermanentlyDenied) {
      _showPermissionPermanentlyDeniedDialog();
    } else {
      print("Storage permission denied.");
    }
  }

  void _fetchSongs() async {
    _fetchSongs();
  }

  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('İzin Gerekli'),
        content: const Text(
            'Uygulamanın müziklerinize erişebilmesi için depolama izni vermeniz gerekmektedir. Lütfen uygulama ayarlarından izni etkinleştirin.'),
        actions: <Widget>[
          TextButton(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Ayarları Aç'),
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
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
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptionsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecentsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.playlist_play),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlaylistsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
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
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
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
  
    void _showSortOptionsDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Sırala'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<SongSortType>(
                  title: const Text('Başlık'),
                  value: SongSortType.TITLE,
                  groupValue: _sortType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sortType = value);
                      _fetchSongs();
                      Navigator.pop(context);
                    }
                  },
                ),
                RadioListTile<SongSortType>(
                  title: const Text('Sanatçı'),
                  value: SongSortType.ARTIST,
                  groupValue: _sortType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sortType = value);
                      _fetchSongs();
                      Navigator.pop(context);
                    }
                  },
                ),
                RadioListTile<SongSortType>(
                  title: const Text('Albüm'),
                  value: SongSortType.ALBUM,
                  groupValue: _sortType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sortType = value);
                      _fetchSongs();
                      Navigator.pop(context);
                    }
                  },
                ),
                RadioListTile<SongSortType>(
                  title: const Text('Süre'),
                  value: SongSortType.DURATION,
                  groupValue: _sortType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sortType = value);
                      _fetchSongs();
                      Navigator.pop(context);
                    }
                  },
                ),
                RadioListTile<SongSortType>(
                  title: const Text('Tarih'),
                  value: SongSortType.DATE_ADDED,
                  groupValue: _sortType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sortType = value);
                      _fetchSongs();
                      Navigator.pop(context);
                    }
                  },
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Azalan Sırada'),
                  value: _orderType == OrderType.DESC_OR_GREATER,
                  onChanged: (value) {
                    setState(() {
                      _orderType = value ? OrderType.DESC_OR_GREATER : OrderType.ASC_OR_SMALLER;
                    });
                    _fetchSongs();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }
}