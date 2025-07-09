import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/application/bloc/player_bloc.dart';
import 'package:music_player/services/audio_player_service.dart';
import 'package:music_player/services/favorites_service.dart';
import 'package:music_player/services/headphone_detection_service.dart';
import 'package:music_player/services/health_data_service.dart';
import 'package:music_player/services/recents_service.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/presentation/screens/home_screen.dart';
import 'package:music_player/application/settings_bloc/settings_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async { // async yaptık
  // Uygulama başlamadan önce Flutter binding'lerinin hazır olduğundan emin oluyoruz.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Tarih formatlaması için yerel ayarları başlat
  await initializeDateFormatting('tr_TR', null);
  
  // Arkaplan servisini başlat
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.music_player.channel.audio',
    androidNotificationChannelName: 'Müzik Çalar',
    androidNotificationOngoing: true,
    androidNotificationIcon: 'mipmap/ic_launcher',
  );
  
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
        RepositoryProvider(create: (context) => HealthDataService()),
        RepositoryProvider(create: (context) => RecentsService()),
      ],
      child: const MusicPlayerApp(),
    ),
  );
}

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PlayerBloc(
            audioPlayerService: RepositoryProvider.of<AudioPlayerService>(context),
            headphoneDetectionService: RepositoryProvider.of<HeadphoneDetectionService>(context),
            favoritesService: RepositoryProvider.of<FavoritesService>(context),
            healthDataService: RepositoryProvider.of<HealthDataService>(context),
            recentsService: RepositoryProvider.of<RecentsService>(context),
          ),
        ),
        BlocProvider(
          create: (context) => SettingsBloc(),
        ),
      ],
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
        home: const HomeScreen(),
      ),
    );
  }
}