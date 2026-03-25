import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal() {
    AudioCache.instance.prefix = '';
  }

  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isHunting = false;

  Future<void> initBackgroundMusic() async {
    try {
      _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource('Assets/Audio/Background.mp3'));
    } catch (e) {
      if (kDebugMode) print('Error playing background music: $e');
    }
  }

  Future<void> playHuntingMusic() async {
    if (_isHunting) {
      await _bgPlayer.resume();
      return;
    }
    _isHunting = true;
    try {
      await _bgPlayer.stop();
      _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource('Assets/Audio/catch.mp3'));
    } catch (e) {
      if (kDebugMode) print('Error playing hunting music: $e');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    await _bgPlayer.pause();
  }

  Future<void> resumeMainTheme() async {
    if (!_isHunting) return;
    _isHunting = false;
    try {
      await _bgPlayer.stop();
      _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource('Assets/Audio/Background.mp3'));
    } catch (e) {
      if (kDebugMode) print('Error resuming main theme: $e');
    }
  }

  Future<void> playCaptureSfx() async {
    try {
      await _sfxPlayer.play(AssetSource('Assets/Audio/captured.mp3'));
    } catch (e) {
      if (kDebugMode) print('Error playing capture SFX: $e');
    }
  }

  void stop() {
    _bgPlayer.stop();
    _sfxPlayer.stop();
  }
}
