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
  final LoopMode loopMode;
  final Color dominantColor;
  final bool isFavorite;
  final Duration? sleepTimerDuration;

  const PlayerState({
    this.status = PlayerStatus.initial,
    this.currentSong,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage,
    this.isShuffle = false,
    this.loopMode = LoopMode.off,
    this.dominantColor = Colors.blue, // Default color
    this.isFavorite = false,
    this.sleepTimerDuration,
  });

  PlayerState copyWith({
    PlayerStatus? status,
    SongModel? currentSong,
    Duration? position,
    Duration? duration,
    String? errorMessage,
    bool? isShuffle,
    LoopMode? loopMode,
    Color? dominantColor,
    bool? isFavorite,
    Duration? sleepTimerDuration,
  }) {
    return PlayerState(
      status: status ?? this.status,
      currentSong: currentSong ?? this.currentSong,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage: errorMessage ?? this.errorMessage,
      isShuffle: isShuffle ?? this.isShuffle,
      loopMode: loopMode ?? this.loopMode,
      dominantColor: dominantColor ?? this.dominantColor,
      isFavorite: isFavorite ?? this.isFavorite,
      sleepTimerDuration: sleepTimerDuration ?? this.sleepTimerDuration,
    );
  }

  @override
  List<Object?> get props => [status, currentSong, position, duration, errorMessage, isShuffle, loopMode, dominantColor, isFavorite, sleepTimerDuration];
}