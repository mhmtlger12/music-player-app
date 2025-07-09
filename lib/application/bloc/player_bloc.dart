import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/services/audio_player_service.dart';
import 'package:music_player/services/favorites_service.dart';
import 'package:music_player/services/headphone_detection_service.dart';
import 'package:on_audio_query/on_audio_query.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayerService _audioPlayerService;
  final HeadphoneDetectionService _headphoneDetectionService;
  final FavoritesService _favoritesService;
  StreamSubscription? _playingSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _headphoneSubscription;
  StreamSubscription? _colorSubscription;
  Timer? _sleepTimer;

  PlayerBloc({
    required AudioPlayerService audioPlayerService,
    required HeadphoneDetectionService headphoneDetectionService,
    required FavoritesService favoritesService,
  })  : _audioPlayerService = audioPlayerService,
        _headphoneDetectionService = headphoneDetectionService,
        _favoritesService = favoritesService,
        super(const PlayerState()) {
    on<PlayRequested>(_onPlayRequested);
    on<PauseRequested>(_onPauseRequested);
    on<ResumeRequested>(_onResumeRequested);
    on<SeekRequested>(_onSeekRequested);
    on<NextRequested>(_onNextRequested);
    on<PreviousRequested>(_onPreviousRequested);
    on<ShuffleModeToggled>(_onShuffleModeToggled);
    on<LoopModeChanged>(_onLoopModeChanged);
    on<FavoriteToggled>(_onFavoriteToggled);
    on<SleepTimerSet>(_onSleepTimerSet);

    _playingSubscription = _audioPlayerService.playingStream.listen((isPlaying) {
      if (isPlaying) {
        emit(state.copyWith(status: PlayerStatus.playing));
      } else {
        // Bu durum, şarkı bittiğinde veya duraklatıldığında tetiklenir.
        // Duraklatma durumu zaten `_onPauseRequested` içinde yönetiliyor.
        if (state.status == PlayerStatus.playing) {
          emit(state.copyWith(status: PlayerStatus.stopped));
        }
      }
    });

    _positionSubscription = _audioPlayerService.positionStream.listen((position) {
      emit(state.copyWith(position: position));
    });

    _durationSubscription = _audioPlayerService.durationStream.listen((duration) {
      emit(state.copyWith(duration: duration));
    });

    _headphoneSubscription = _headphoneDetectionService.headphoneStatusStream.listen((isConnected) {
      if (!isConnected && state.status == PlayerStatus.playing) {
        add(PauseRequested());
      }
    });

    _colorSubscription = _audioPlayerService.dominantColorStream.listen((color) {
      emit(state.copyWith(dominantColor: color));
    });
  }

  @override
  Future<void> close() {
    _playingSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _headphoneSubscription?.cancel();
    _colorSubscription?.cancel();
    _sleepTimer?.cancel();
    return super.close();
  }

  Future<void> _onPlayRequested(PlayRequested event, Emitter<PlayerState> emit) async {
    final currentSong = event.songs[event.initialIndex];
    final isFavorite = await _favoritesService.isFavorite(currentSong.id);
    emit(state.copyWith(
      status: PlayerStatus.loading,
      currentSong: currentSong,
      isFavorite: isFavorite,
    ));
    try {
      await _audioPlayerService.setPlaylist(event.songs, event.initialIndex);
      await _audioPlayerService.play();
      // `playingStream` dinleyicisi durumu `playing` olarak güncelleyecektir.
    } catch (e) {
      emit(state.copyWith(status: PlayerStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onPauseRequested(PauseRequested event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.pause();
    emit(state.copyWith(status: PlayerStatus.paused));
  }

  Future<void> _onResumeRequested(ResumeRequested event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.play();
    emit(state.copyWith(status: PlayerStatus.playing));
  }

  Future<void> _onSeekRequested(SeekRequested event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.seek(event.position);
  }

  Future<void> _onNextRequested(NextRequested event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.next();
  }

  Future<void> _onPreviousRequested(PreviousRequested event, Emitter<PlayerState> emit) async {
    await _audioPlayerService.previous();
  }

  Future<void> _onShuffleModeToggled(ShuffleModeToggled event, Emitter<PlayerState> emit) async {
    final newShuffleState = !state.isShuffle;
    await _audioPlayerService.setShuffleModeEnabled(newShuffleState);
    emit(state.copyWith(isShuffle: newShuffleState));
  }

  Future<void> _onLoopModeChanged(LoopModeChanged event, Emitter<PlayerState> emit) async {
    final currentMode = state.loopMode;
    final nextMode = LoopMode.values[(currentMode.index + 1) % LoopMode.values.length];
    await _audioPlayerService.setLoopMode(nextMode);
    emit(state.copyWith(loopMode: nextMode));
  }

  Future<void> _onFavoriteToggled(FavoriteToggled event, Emitter<PlayerState> emit) async {
    final song = state.currentSong;
    if (song == null) return;

    final isCurrentlyFavorite = state.isFavorite;
    if (isCurrentlyFavorite) {
      await _favoritesService.removeFavorite(song.id);
    } else {
      await _favoritesService.addFavorite(song.id);
    }
    emit(state.copyWith(isFavorite: !isCurrentlyFavorite));
  }

  void _onSleepTimerSet(SleepTimerSet event, Emitter<PlayerState> emit) {
    _sleepTimer?.cancel();
    if (event.duration != null) {
      _sleepTimer = Timer(event.duration!, () {
        add(PauseRequested());
      });
    }
    emit(state.copyWith(sleepTimerDuration: event.duration));
  }
}