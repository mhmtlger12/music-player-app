import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:music_player/application/settings_bloc/settings_bloc.dart';
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
import '../widgets/settings_icon_painter.dart';
import 'equalizer_bottom_sheet.dart';
import '../widgets/health_indicator.dart';
import 'parental_dashboard_screen.dart';
import 'health_dashboard_screen.dart';
import '../widgets/custom_icons/health_icon.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import '../widgets/audio_visualizer_painter.dart';
import 'queue_screen.dart';

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

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900.withOpacity(0.8),
      builder: (context) {
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return Wrap(
              children: <Widget>[
                if (state.appMode == AppMode.parent)
                  ListTile(
                    leading: const Icon(Icons.child_care, color: Colors.white),
                    title: const Text('Çocuk Moduna Geç', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      _showSetPinDialog(context);
                    },
                  ),
                if (state.appMode == AppMode.child)
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: Colors.white),
                    title: const Text('Ebeveyn Moduna Geç', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      _showEnterPinDialog(context);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.dashboard, color: Colors.white),
                  title: const Text('Ebeveyn Kontrol Paneli', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ParentalDashboardScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const HealthIcon(color: Colors.white, size: 24),
                  title: const Text('Sağlık Paneli', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HealthDashboardScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.volume_up, color: Colors.white),
                  title: const Text('Ses Seviyesi', style: TextStyle(color: Colors.white)),
                  subtitle: Slider(
                    value: context.watch<PlayerBloc>().state.volume,
                    onChanged: (value) {
                      context.read<PlayerBloc>().add(VolumeChanged(value));
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.speed, color: Colors.white),
                  title: const Text('Hız', style: TextStyle(color: Colors.white)),
                  subtitle: Slider(
                    value: context.watch<PlayerBloc>().state.speed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 6,
                    label: context.watch<PlayerBloc>().state.speed.toStringAsFixed(1),
                    onChanged: (value) {
                      context.read<PlayerBloc>().add(SpeedChanged(value));
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSetPinDialog(BuildContext context) {
    TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('PIN Ayarla (4 Haneli)', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: '****',
            hintStyle: TextStyle(color: Colors.white30),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İPTAL'),
          ),
          TextButton(
            onPressed: () {
              if (pinController.text.length == 4) {
                context.read<SettingsBloc>().add(ChildModeEnabled(pin: pinController.text));
                Navigator.pop(context);
              }
            },
            child: const Text('AYARLA'),
          ),
        ],
      ),
    );
  }

  void _showEnterPinDialog(BuildContext context) {
    TextEditingController pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('PIN Girin', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: '****',
            hintStyle: TextStyle(color: Colors.white30),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İPTAL'),
          ),
          TextButton(
            onPressed: () {
              context.read<SettingsBloc>().add(PinEntered(pin: pinController.text));
              Navigator.pop(context);
            },
            child: const Text('GİRİŞ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final isChildMode = settingsState.appMode == AppMode.child;
          return BlocBuilder<PlayerBloc, PlayerState>(
            builder: (context, playerState) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          playerState.dominantColor.withOpacity(0.6),
                          Colors.black,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 20,
                    child: GestureDetector(
                      onTap: () => _showSettingsMenu(context),
                      child: CustomPaint(
                        size: const Size(24, 24),
                        painter: SettingsIconPainter(),
                      ),
                    ),
                  ),
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
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: GestureDetector(
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity == null) return;
                            if (details.primaryVelocity! > 100) {
                              context.read<PlayerBloc>().add(PreviousRequested());
                            } else if (details.primaryVelocity! < -100) {
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
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              playerState.currentSong?.title ?? 'No Song',
                                              style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              playerState.currentSong?.artist ?? 'Select a song',
                                              style: const TextStyle(fontSize: 16, color: Colors.white70),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (playerState.currentSong != null) {
                                            context.read<PlayerBloc>().add(FavoriteToggled());
                                          }
                                        },
                                        child: CustomPaint(
                                          size: const Size(24, 24),
                                          painter: FavoriteIconPainter(isFavorite: playerState.isFavorite),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                // Ses Dalga Formu Görselleştiricisi
                                SizedBox(
                                  height: 80,
                                  child: CustomPaint(
                                    size: const Size(double.infinity, 80),
                                    painter: AudioVisualizerPainter(
                                      animation: _animationController,
                                      color: playerState.dominantColor,
                                    ),
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
                                          value: playerState.position.inSeconds.toDouble(),
                                          max: playerState.duration.inSeconds.toDouble() + 1.0,
                                          onChanged: (value) {
                                            context.read<PlayerBloc>().add(SeekRequested(position: Duration(seconds: value.toInt())));
                                          },
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            playerState.position.toString().substring(2, 7),
                                            style: const TextStyle(color: Colors.white70),
                                          ),
                                          Text(
                                            playerState.duration.toString().substring(2, 7),
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
                                        if (playerState.status == PlayerStatus.playing) {
                                          playerBloc.add(PauseRequested());
                                          _animationController.stop();
                                        } else {
                                          if (playerState.status == PlayerStatus.paused) {
                                            playerBloc.add(ResumeRequested());
                                            _animationController.repeat();
                                          }
                                        }
                                      },
                                      child: CustomPaint(
                                        size: const Size(80, 80),
                                        painter: PlayButtonPainter(isPlaying: playerState.status == PlayerStatus.playing),
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
                                        onLongPress: () => context.read<PlayerBloc>().add(SmartShuffleToggled()),
                                        child: CustomPaint(
                                          size: const Size(24, 24),
                                          painter: ShuffleIconPainter(
                                            isActive: playerState.isShuffle || playerState.isSmartShuffle,
                                            isSmartShuffle: playerState.isSmartShuffle,
                                          ),
                                        ),
                                      ),
                                      if (!isChildMode)
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
                                            isActive: playerState.loopMode != ja.LoopMode.off,
                                            isRepeatOne: playerState.loopMode == ja.LoopMode.one,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _showSleepTimerDialog(context),
                                        child: CustomPaint(
                                          size: const Size(24, 24),
                                          painter: SleepTimerIconPainter(isActive: playerState.sleepTimerDuration != null),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const QueueScreen()),
                                          );
                                        },
                                        child: const Icon(Icons.queue_music, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                const HealthIndicator(),
                                const SizedBox(height: 10),
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
          );
        },
      ),
    );
  }
}