part of 'player_bloc.dart';

enum PlayerStatus { initial, loading, playing, paused, stopped, error }

@immutable
class PlayerState extends Equatable {
  final PlayerStatus status;
  final SongModel? currentSong;
  final Duration position;
  final Duration duration;
  final String? errorMessage;
  final bool isShuffle;
  final bool isSmartShuffle;
  final LoopMode loopMode;
  final Color dominantColor;
  final bool isFavorite;
  final Duration? sleepTimerDuration;
  final double decibelLevel;

  final List<SongModel> playlist;
  final List<int>? shuffleIndices;
  final double volume;
  final double speed;

  const PlayerState({
    this.status = PlayerStatus.initial,
    this.currentSong,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage,
    this.isShuffle = false,
    this.isSmartShuffle = false,
    this.loopMode = LoopMode.off,
    this.dominantColor = Colors.blue, // Default color
    this.isFavorite = false,
    this.sleepTimerDuration,
    this.decibelLevel = -100.0,
    this.playlist = const [],
    this.shuffleIndices,
    this.volume = 1.0,
    this.speed = 1.0,
  });

  PlayerState copyWith({
    PlayerStatus? status,
    SongModel? currentSong,
    Duration? position,
    Duration? duration,
    String? errorMessage,
    bool? isShuffle,
    bool? isSmartShuffle,
    LoopMode? loopMode,
    Color? dominantColor,
    bool? isFavorite,
    Duration? sleepTimerDuration,
    double? decibelLevel,
    List<SongModel>? playlist,
    List<int>? shuffleIndices,
    double? volume,
    double? speed,
  }) {
    return PlayerState(
      status: status ?? this.status,
      currentSong: currentSong ?? this.currentSong,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage: errorMessage ?? this.errorMessage,
      isShuffle: isShuffle ?? this.isShuffle,
      isSmartShuffle: isSmartShuffle ?? this.isSmartShuffle,
      loopMode: loopMode ?? this.loopMode,
      dominantColor: dominantColor ?? this.dominantColor,
      isFavorite: isFavorite ?? this.isFavorite,
      sleepTimerDuration: sleepTimerDuration ?? this.sleepTimerDuration,
      decibelLevel: decibelLevel ?? this.decibelLevel,
      playlist: playlist ?? this.playlist,
      shuffleIndices: shuffleIndices ?? this.shuffleIndices,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
    );
  }

  @override
  List<Object?> get props => [status, currentSong, position, duration, errorMessage, isShuffle, isSmartShuffle, loopMode, dominantColor, isFavorite, sleepTimerDuration, decibelLevel, playlist, shuffleIndices, volume, speed];
}