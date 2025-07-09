import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/services/recents_service.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;

  late final AudioPlayer _audioPlayer;
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final RecentsService _recentsService = RecentsService();
  final StreamController<Color> _dominantColorController = StreamController.broadcast();
  
  final _equalizer = AndroidEqualizer();

  Stream<Color> get dominantColorStream => _dominantColorController.stream;
  ConcatenatingAudioSource? _playlist;

  List<SongModel> _originalSongs = [];
  List<SongModel> get originalSongs => _originalSongs;

  AudioPlayerService._internal() {
    _audioPlayer = AudioPlayer(
      audioPipeline: AudioPipeline(
        androidAudioEffects: [_equalizer],
      ),
    );
  }

  Future<void> init() async {
    await _equalizer.setEnabled(true);
  }

  Future<void> setPlaylist(
    List<SongModel> songs, 
    int initialIndex, {
    bool smartShuffle = false,
  }) async {
    
    _originalSongs = List.from(songs);
    List<SongModel> songsToPlay = List.from(songs);

    if (smartShuffle) {
      final playCounts = await _recentsService.getPlayCountMap();
      final weightedSongs = <SongModel>[];

      for (var song in songs) {
        final count = playCounts[song.id.toString()] ?? 0;
        // Her şarkıyı (dinlenme sayısı + 1) kadar listeye ekle.
        // +1, hiç dinlenmemiş şarkıların da bir şansı olması için.
        for (int i = 0; i < count + 1; i++) {
          weightedSongs.add(song);
        }
      }
      weightedSongs.shuffle(Random());
      // Tekrarları kaldır, ancak sıralamayı koru.
      songsToPlay = weightedSongs.toSet().toList();
    }

    _playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      shuffleOrder: DefaultShuffleOrder(),
      children: songsToPlay.map((song) => AudioSource.uri(
        Uri.parse(song.uri!),
        tag: MediaItem(
          id: song.id.toString(),
          album: song.album ?? "No Album",
          title: song.title,
          artist: song.artist ?? "No Artist",
          artUri: Uri.parse('content://media/external/audio/albumart/${song.albumId}'),
        ),
      )).toList(),
    );
    try {
      // Akıllı karıştırma yapıldıysa, başlangıç indeksi artık geçerli olmayabilir.
      // Bu yüzden listenin başından başlatıyoruz.
      await _audioPlayer.setAudioSource(_playlist!, initialIndex: smartShuffle ? 0 : initialIndex);
      _updateDominantColor(songsToPlay[smartShuffle ? 0 : initialIndex].id);
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
  Future<void> seek(Duration position, {int? index}) async => await _audioPlayer.seek(position, index: index);
  
  Future<void> setShuffleModeEnabled(bool enabled) async => await _audioPlayer.setShuffleModeEnabled(enabled);
  Future<void> setLoopMode(LoopMode mode) async => await _audioPlayer.setLoopMode(mode);

  Future<void> setVolume(double volume) async => await _audioPlayer.setVolume(volume);
  Future<void> setSpeed(double speed) async => await _audioPlayer.setSpeed(speed);

  Stream<bool> get playingStream => _audioPlayer.playingStream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  Stream<List<int>?> get shuffleIndicesStream => _audioPlayer.shuffleIndicesStream;

  void dispose() {
    _audioPlayer.dispose();
    _dominantColorController.close();
  }
}