import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Çalma Listeleri'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePlaylistDialog(),
          ),
        ],
      ),
      body: FutureBuilder<List<PlaylistModel>>(
        future: _audioQuery.queryPlaylists(),
        builder: (context, item) {
          if (item.hasError) {
            return Text(item.error.toString());
          }
          if (item.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (item.data!.isEmpty) {
            return const Center(child: Text("Hiç çalma listesi bulunamadı."));
          }
          return ListView.builder(
            itemCount: item.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(item.data![index].playlist),
                subtitle: Text("${item.data![index].numOfSongs} şarkı"),
                leading: const Icon(Icons.playlist_play),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showPlaylistOptions(item.data![index]),
                ),
                onTap: () {
                  // TODO: Çalma listesi detay ekranına git
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showCreatePlaylistDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Çalma Listesi"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Liste Adı"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İPTAL"),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await _audioQuery.createPlaylist(controller.text);
                  setState(() {}); // Ekranı yenile
                  Navigator.pop(context);
                }
              },
              child: const Text("OLUŞTUR"),
            ),
          ],
        );
      },
    );
  }

  void _showPlaylistOptions(PlaylistModel playlist) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Yeniden Adlandır'),
              onTap: () {
                Navigator.pop(context);
                _showRenamePlaylistDialog(playlist);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Sil'),
              onTap: () {
                Navigator.pop(context);
                _showDeletePlaylistDialog(playlist);
              },
            ),
          ],
        );
      },
    );
  }

  void _showRenamePlaylistDialog(PlaylistModel playlist) {
    TextEditingController controller = TextEditingController(text: playlist.playlist);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Çalma Listesini Yeniden Adlandır"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Yeni Liste Adı"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İPTAL"),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await _audioQuery.renamePlaylist(playlist.id, controller.text);
                  setState(() {});
                  Navigator.pop(context);
                }
              },
              child: const Text("KAYDET"),
            ),
          ],
        );
      },
    );
  }

  void _showDeletePlaylistDialog(PlaylistModel playlist) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Çalma Listesini Sil"),
          content: Text("'${playlist.playlist}' listesini silmek istediğinizden emin misiniz?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İPTAL"),
            ),
            TextButton(
              onPressed: () async {
                await _audioQuery.removePlaylist(playlist.id);
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text("SİL"),
            ),
          ],
        );
      },
    );
  }
}