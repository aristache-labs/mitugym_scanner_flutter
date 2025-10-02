import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';

/// Audio Service
/// Handles audio feedback for scan results
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final Logger _logger = Logger();
  bool _audioEnabled = true;

  AudioService({bool audioEnabled = true}) {
    _audioEnabled = audioEnabled;
  }

  /// Initialize and preload audio files
  Future<void> initialize() async {
    try {
      // Preload audio files into memory for faster playback
      await _player.setSourceAsset('sounds/success.mp3');
      await _player.setSourceAsset('sounds/error.mp3');
      _logger.i('Audio files preloaded');
    } catch (e) {
      _logger.w('Audio preload failed (files may not exist): $e');
    }
  }

  /// Set audio enabled/disabled
  void setAudioEnabled(bool enabled) {
    _audioEnabled = enabled;
    _logger.i('Audio ${enabled ? "enabled" : "disabled"}');
  }

  /// Set audio volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
      _logger.i('Audio volume set to $volume');
    } catch (e) {
      _logger.e('Failed to set volume: $e');
    }
  }

  /// Play success sound
  Future<void> playSuccess() async {
    if (!_audioEnabled) {
      _logger.d('Audio disabled, skipping success sound');
      return;
    }

    try {
      // Try to play from assets
      await _player.play(AssetSource('sounds/success.mp3'));
      _logger.i('Playing success sound');
    } catch (e) {
      // If asset doesn't exist, play system beep (placeholder)
      _logger.w('Success sound file not found: $e');
      // Could use platform-specific beep here if needed
    }
  }

  /// Play error sound
  Future<void> playError() async {
    if (!_audioEnabled) {
      _logger.d('Audio disabled, skipping error sound');
      return;
    }

    try {
      // Try to play from assets
      await _player.play(AssetSource('sounds/error.mp3'));
      _logger.i('Playing error sound');
    } catch (e) {
      // If asset doesn't exist, play system beep (placeholder)
      _logger.w('Error sound file not found: $e');
      // Could use platform-specific beep here if needed
    }
  }

  /// Stop any currently playing sound
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      _logger.e('Failed to stop audio: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _player.dispose();
    _logger.i('Audio Service disposed');
  }
}

