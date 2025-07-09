part of 'player_bloc.dart';

@immutable
abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object> get props => [];
}

class PlayRequested extends PlayerEvent {
  final List<SongModel> songs;
  final int initialIndex;
  const PlayRequested({required this.songs, required this.initialIndex});

  @override
  List<Object> get props => [songs, initialIndex];
}

class PauseRequested extends PlayerEvent {}

class ResumeRequested extends PlayerEvent {}

class NextRequested extends PlayerEvent {}

class PreviousRequested extends PlayerEvent {}

class ShuffleModeToggled extends PlayerEvent {}

class LoopModeChanged extends PlayerEvent {}

class SmartShuffleToggled extends PlayerEvent {}

class FavoriteToggled extends PlayerEvent {}

class SleepTimerSet extends PlayerEvent {
  final Duration? duration;
  const SleepTimerSet({this.duration});

  @override
  List<Object> get props => []; // Nullable olduğu için props'a eklemiyoruz
}

class _DecibelLevelChanged extends PlayerEvent {
  final double level;
  const _DecibelLevelChanged(this.level);

  @override
  List<Object> get props => [level];
}

class SeekRequested extends PlayerEvent {
  final Duration position;
  const SeekRequested({required this.position});

  @override
  List<Object> get props => [position];
}

class SeekToIndexRequested extends PlayerEvent {
  final int index;
  const SeekToIndexRequested({required this.index});

  @override
  List<Object> get props => [index];
}

class VolumeChanged extends PlayerEvent {
  final double volume;
  const VolumeChanged(this.volume);

  @override
  List<Object> get props => [volume];
}

class SpeedChanged extends PlayerEvent {
  final double speed;
  const SpeedChanged(this.speed);

  @override
  List<Object> get props => [speed];
}