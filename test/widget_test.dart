import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/main.dart';
import 'package:music_player/presentation/screens/home_screen.dart';
import 'package:music_player/services/audio_level_service.dart';
import 'package:music_player/services/audio_player_service.dart';
import 'package:music_player/services/favorites_service.dart';
import 'package:music_player/services/health_data_service.dart';
import 'package:music_player/services/headphone_detection_service.dart';
import 'package:music_player/services/recents_service.dart';

// Servislerin sahte (mock) versiyonları. Bu, widget'ları izole bir şekilde test etmemizi sağlar.
class MockAudioPlayerService extends Fake implements AudioPlayerService {}
class MockHeadphoneDetectionService extends Fake implements HeadphoneDetectionService {}
class MockFavoritesService extends Fake implements FavoritesService {}
class MockAudioLevelService extends Fake implements AudioLevelService {}
class MockHealthDataService extends Fake implements HealthDataService {}
class MockRecentsService extends Fake implements RecentsService {}

void main() {
  testWidgets('MusicPlayerApp builds and shows HomeScreen', (WidgetTester tester) async {
    // MusicPlayerApp'in ihtiyaç duyduğu Repository Provider'ları test ortamı için kuruyoruz.
    // Bu, main.dart dosyasındaki yapılandırmayı taklit eder.
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AudioPlayerService>(create: (context) => MockAudioPlayerService()),
          RepositoryProvider<HeadphoneDetectionService>(create: (context) => MockHeadphoneDetectionService()),
          RepositoryProvider<FavoritesService>(create: (context) => MockFavoritesService()),
          RepositoryProvider<AudioLevelService>(create: (context) => MockAudioLevelService()),
          RepositoryProvider<HealthDataService>(create: (context) => MockHealthDataService()),
          RepositoryProvider<RecentsService>(create: (context) => MockRecentsService()),
        ],
        child: const MusicPlayerApp(),
      ),
    );

    // Uygulamanın başlangıçta kimlik doğrulama ekranını gösterdiğini doğruluyoruz.
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
