import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/application/bloc/player_bloc.dart';
import 'package:music_player/presentation/screens/home_screen.dart';
import 'package:music_player/services/audio_player_service.dart';
import 'package:music_player/services/favorites_service.dart';
import 'package:music_player/services/headphone_detection_service.dart';
import 'package:music_player/services/audio_level_service.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/presentation/screens/auth_screen.dart';

Future<void> main() async { // async yaptık
  // Arkaplan servisini başlat
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  // Uygulama başlamadan önce Flutter binding'lerinin hazır olduğundan emin oluyoruz.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Servisleri başlat
  await HeadphoneDetectionService().init();

  // Cihazın sadece dikey modda çalışmasını sağlıyoruz.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar'ı transparan yaparak daha modern bir görünüm elde ediyoruz.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light, // iOS için
    statusBarBrightness: Brightness.dark, // Android için
  ));

  runApp(
    MultiRepositoryProvider( // MultiRepositoryProvider kullandık
      providers: [
        RepositoryProvider(create: (context) => AudioPlayerService()),
        RepositoryProvider(create: (context) => HeadphoneDetectionService()),
        RepositoryProvider(create: (context) => FavoritesService()),
        RepositoryProvider(create: (context) => AudioLevelService()),
      ],
      child: const MusicPlayerApp(),
    ),
  );
}

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayerBloc(
        audioPlayerService: RepositoryProvider.of<AudioPlayerService>(context),
        headphoneDetectionService: RepositoryProvider.of<HeadphoneDetectionService>(context),
        favoritesService: RepositoryProvider.of<FavoritesService>(context),
        audioLevelService: RepositoryProvider.of<AudioLevelService>(context),
      ),
      child: MaterialApp(
        title: 'Ultimate Music Player',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.blue.shade800,
          scaffoldBackgroundColor: Colors.black,
          fontFamily: 'Poppins', // Projeye daha sonra bir font ekleyeceğiz.
          colorScheme: ColorScheme.fromSwatch(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
          ).copyWith(
            secondary: Colors.orange.shade600,
          ),
        ),
        home: const AuthScreen(),
      ),
    );
  }
}