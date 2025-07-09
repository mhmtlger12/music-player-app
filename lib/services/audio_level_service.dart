import 'dart:async';
import 'dart:math';

class AudioLevelService {
  Stream<double>? _levelStream;
  Timer? _timer;

  Stream<double> get levelStream {
    _levelStream ??= _startListening();
    return _levelStream!;
  }

  Stream<double> _startListening() {
    final controller = StreamController<double>();

    // Gerçek mikrofon entegrasyonu yerine sahte bir stream oluşturuyoruz.
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // -100 dB (sessiz) ile 0 dB (maksimum) arasında rastgele bir değer üret
      final randomDB = -100 + Random().nextDouble() * 100;
      controller.add(randomDB);
    });

    return controller.stream;
  }

  void dispose() {
    _timer?.cancel();
  }
}