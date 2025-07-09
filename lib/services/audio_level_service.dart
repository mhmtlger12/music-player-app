// Bu servis, uyumsuz paketler nedeniyle geçici olarak devre dışı bırakılmıştır.
// Projenin kararlılığını sağlamak için bu özellik daha sonra
// uyumlu bir paketle yeniden eklenebilir.
class AudioLevelService {
  Stream<double> get levelStream => Stream.value(-100.0);
  void start() {}
  void stop() {}
  void dispose() {}
}