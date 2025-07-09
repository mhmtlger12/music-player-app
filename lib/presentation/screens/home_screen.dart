import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' as ja;
import '../../application/bloc/player_bloc.dart';
import '../widgets/play_button_painter.dart';
import '../widgets/skip_button_painter.dart';
import '../widgets/library_icon_painter.dart';
import 'library_screen.dart';
import '../widgets/shuffle_icon_painter.dart';
import '../widgets/repeat_icon_painter.dart';
import '../widgets/equalizer_icon_painter.dart';
import '../widgets/favorite_icon_painter.dart';
import '../widgets/sleep_timer_icon_painter.dart';
import 'equalizer_bottom_sheet.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  StreamSubscription? _accelerometerSubscription;
  static const double _shakeThreshold = 15.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (event.x.abs() > _shakeThreshold || event.y.abs() > _shakeThreshold || event.z.abs() > _shakeThreshold) {
        // Cihaz yeterince hızlı sallandı, sonraki şarkıya geç.
        context.read<PlayerBloc>().add(NextRequested());
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _showSleepTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text('Uyku Zamanlayıcısı', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                textColor: Colors.white,
                title: const Text('15 Dakika'),
                onTap: () {
                  context.read<PlayerBloc>().add(const SleepTimerSet(duration: Duration(minutes: 15)));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                textColor: Colors.white,
                title: const Text('30 Dakika'),
                onTap: () {
                  context.read<PlayerBloc>().add(const SleepTimerSet(duration: Duration(minutes: 30)));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                textColor: Colors.white,
                title: const Text('1 Saat'),
                onTap: () {
                  context.read<PlayerBloc>().add(const SleepTimerSet(duration: Duration(hours: 1)));
                  Navigator.pop(context);
                },
              ),
              const Divider(color: Colors.white24),
              ListTile(
                textColor: Colors.orange,
                title: const Text('İptal Et'),
                onTap: () {
                  context.read<PlayerBloc>().add(const SleepTimerSet());
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          return Stack(
            children: [
              // Dinamik Arka Plan
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      state.dominantColor.withOpacity(0.6),
                      Colors.black,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Library butonu
              Positioned(
                top: 50,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LibraryScreen()),
                    );
                  },
                  child: CustomPaint(
                    size: const Size(24, 24),
                    painter: LibraryIconPainter(),
                  ),
                ),
              ),
              // Glassmorphism efekti için ana içerik
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: GestureDetector( // Swipe Detector
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity == null) return;
                        if (details.primaryVelocity! > 100) { // Swipe Right
                          context.read<PlayerBloc>().add(PreviousRequested());
                        } else if (details.primaryVelocity! < -100) { // Swipe Left
                          context.read<PlayerBloc>().add(NextRequested());
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 24), // Placeholder
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          state.currentSong?.title ?? 'No Song',
                                          style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          state.currentSong?.artist ?? 'Select a song',
                                          style: const TextStyle(fontSize: 16, color: Colors.white70),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (state.currentSong != null) {
                                        context.read<PlayerBloc>().add(FavoriteToggled());
                                      }
                                    },
                                    child: CustomPaint(
                                      size: const Size(24, 24),
                                      painter: FavoriteIconPainter(isFavorite: state.isFavorite),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Column(
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 2.0,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                                      activeTrackColor: Colors.white,
                                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                                      thumbColor: Colors.white,
                                    ),
                                    child: Slider(
                                      value: state.position.inSeconds.toDouble(),
                                      max: state.duration.inSeconds.toDouble() + 1.0,
                                      onChanged: (value) {
                                        context.read<PlayerBloc>().add(SeekRequested(position: Duration(seconds: value.toInt())));
                                      },
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        state.position.toString().substring(2, 7),
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      Text(
                                        state.duration.toString().substring(2, 7),
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () => context.read<PlayerBloc>().add(PreviousRequested()),
                                  child: CustomPaint(
                                    size: const Size(40, 40),
                                    painter: SkipButtonPainter(direction: SkipDirection.backward),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final playerBloc = context.read<PlayerBloc>();
                                    if (state.status == PlayerStatus.playing) {
                                      playerBloc.add(PauseRequested());
                                      _animationController.stop();
                                    } else {
                                      if (state.status == PlayerStatus.paused) {
                                        playerBloc.add(ResumeRequested());
                                        _animationController.repeat();
                                      }
                                    }
                                  },
                                  child: CustomPaint(
                                    size: const Size(80, 80),
                                    painter: PlayButtonPainter(isPlaying: state.status == PlayerStatus.playing),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.read<PlayerBloc>().add(NextRequested()),
                                  child: CustomPaint(
                                    size: const Size(40, 40),
                                    painter: SkipButtonPainter(direction: SkipDirection.forward),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => context.read<PlayerBloc>().add(ShuffleModeToggled()),
                                    child: CustomPaint(
                                      size: const Size(24, 24),
                                      painter: ShuffleIconPainter(isActive: state.isShuffle),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (ctx) => const EqualizerBottomSheet(),
                                        backgroundColor: Colors.transparent,
                                      );
                                    },
                                    child: CustomPaint(
                                      size: const Size(24, 24),
                                      painter: EqualizerIconPainter(),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.read<PlayerBloc>().add(LoopModeChanged()),
                                    child: CustomPaint(
                                      size: const Size(24, 24),
                                      painter: RepeatIconPainter(
                                        isActive: state.loopMode != ja.LoopMode.off,
                                        isRepeatOne: state.loopMode == ja.LoopMode.one,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showSleepTimerDialog(context),
                                    child: CustomPaint(
                                      size: const Size(24, 24),
                                      painter: SleepTimerIconPainter(isActive: state.sleepTimerDuration != null),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}