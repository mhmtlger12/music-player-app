import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/application/bloc/player_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final List<SongModel> queue;
        if (state.isShuffle && state.shuffleIndices != null) {
          queue = state.shuffleIndices!.map((index) => state.playlist[index]).toList();
        } else {
          queue = state.playlist;
        }

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Sıradakiler'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ReorderableListView.builder(
            itemCount: queue.length,
            itemBuilder: (context, index) {
              final song = queue[index];
              final bool isCurrent = song.id == state.currentSong?.id;
              return ListTile(
                key: ValueKey(song.id),
                leading: Icon(
                  isCurrent ? Icons.play_arrow : Icons.music_note,
                  color: isCurrent ? Colors.blue : Colors.white,
                ),
                title: Text(
                  song.title,
                  style: TextStyle(
                    color: isCurrent ? Colors.blue : Colors.white,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  song.artist ?? "Bilinmeyen Sanatçı",
                  style: TextStyle(color: isCurrent ? Colors.blue.withOpacity(0.7) : Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  final originalIndex = state.playlist.indexWhere((s) => s.id == song.id);
                  if (originalIndex != -1) {
                    context.read<PlayerBloc>().add(SeekToIndexRequested(index: originalIndex));
                  }
                },
              );
            },
            onReorder: (oldIndex, newIndex) {
              // TODO: Reordering logic
            },
          ),
        );
      },
    );
  }
}