import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> initBackgroundMusic() async {
    try {
      AudioCache.instance.prefix = ''; // Remove default 'assets/' prefix
      _player.setReleaseMode(ReleaseMode.loop);
      
      // Fallback manual loop in case standard loop mode breaks on some platforms
      _player.onPlayerComplete.listen((_) {
        _player.seek(Duration.zero);
        _player.resume();
      });

      await _player.play(AssetSource('Assets/Audio/Background.mp3'));
    } catch (e) {
      if (kDebugMode) {
        print('Error playing background music: $e');
      }
    }
  }

  void stop() {
    _player.stop();
  }
}
