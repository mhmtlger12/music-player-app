import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  late final AudioPlayer _audioPlayer;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final StreamController<Color> _dominantColorController = StreamController.broadcast();
  
  // Ekolayzeri burada tanımlıyoruz
  final _equalizer = AndroidEqualizer();

  Stream<Color> get dominantColorStream => _dominantColorController.stream;
  ConcatenatingAudioSource? _playlist;

  AudioPlayerService._internal() {
    _audioPlayer = AudioPlayer(
      audioPipeline: AudioPipeline(
        androidAudioEffects: [_equalizer],
      ),
    );
  }

  Future<void> setPlaylist(List<SongModel> songs, int initialIndex) async {
    _playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      shuffleOrder: DefaultShuffleOrder(),
      children: songs.map((song) => AudioSource.uri(
        Uri.parse(song.uri!),
        tag: MediaItem(
          id: song.id.toString(),
          album: song.album ?? "No Album",
          title: song.title,
          artist: song.artist ?? "No Artist",
        ),
      )).toList(),
    );
    try {
      await _audioPlayer.setAudioSource(_playlist!, initialIndex: initialIndex);
      _updateDominantColor(songs[initialIndex].id);
    } catch (e) {
      print("Error setting playlist: $e");
    }
  }

  Future<void> _updateDominantColor(int songId) async {
    final artwork = await _audioQuery.queryArtwork(songId, ArtworkType.AUDIO, size: 200);
    if (artwork != null) {
      final palette = await PaletteGenerator.fromImageProvider(MemoryImage(artwork));
      _dominantColorController.add(palette.dominantColor?.color ?? Colors.blue);
    } else {
      _dominantColorController.add(Colors.blue); // Default color
    }
  }

  Future<AndroidEqualizerParameters> getEqualizerParameters() => _equalizer.parameters;
  
  Future<void> setBandGain(int bandIndex, double gain) async {
    final parameters = await getEqualizerParameters();
    if (bandIndex < parameters.bands.length) {
      await parameters.bands[bandIndex].setGain(gain);
    }
  }

  Future<void> play() async => await _audioPlayer.play();
  Future<void> pause() async => await _audioPlayer.pause();
  Future<void> next() async => await _audioPlayer.seekToNext();
  Future<void> previous() async => await _audioPlayer.seekToPrevious();
  Future<void> seek(Duration position) async => await _audioPlayer.seek(position);
  
  Future<void> setShuffleModeEnabled(bool enabled) async => await _audioPlayer.setShuffleModeEnabled(enabled);
  Future<void> setLoopMode(LoopMode mode) async => await _audioPlayer.setLoopMode(mode);

  Stream<bool> get playingStream => _audioPlayer.playingStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  void dispose() {
    _audioPlayer.dispose();
    _dominantColorController.close();
  }
}