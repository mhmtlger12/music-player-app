import 'dart:async';
import 'package:audio_session/audio_session.dart';

class HeadphoneDetectionService {
  static final HeadphoneDetectionService _instance = HeadphoneDetectionService._internal();
  factory HeadphoneDetectionService() => _instance;
  HeadphoneDetectionService._internal();

  final StreamController<bool> _headphoneStatusController = StreamController.broadcast();
  Stream<bool> get headphoneStatusStream => _headphoneStatusController.stream;

  AudioSession? _session;
  StreamSubscription<void>? _devicesChangedSubscription;

  Future<void> init() async {
    _session = await AudioSession.instance;
    await _session?.configure(const AudioSessionConfiguration.music());

    // Cihaz değişikliklerini dinle (bu stream void event gönderir)
    _devicesChangedSubscription = _session?.devicesChangedEventStream.listen((_) {
      _checkHeadphoneStatus();
    });

    // Başlangıç durumunu kontrol et
    _checkHeadphoneStatus();
  }

  Future<void> _checkHeadphoneStatus() async {
    if (_session == null) return;
    // Cihaz listesini `getDevices` metodu ile al
    final devices = await _session!.getDevices();
    final isConnected = devices.any((d) =>
        d.type == AudioDeviceType.wiredHeadset || // 'headphones' yerine 'wiredHeadset'
        d.type == AudioDeviceType.bluetoothA2dp ||
        d.type == AudioDeviceType.bluetoothSco);
    _headphoneStatusController.add(isConnected);
  }

  void dispose() {
    _devicesChangedSubscription?.cancel();
    _headphoneStatusController.close();
  }
}