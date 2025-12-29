import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:ai_women_safety/utils/logger_util.dart';

class RingtoneService {
  static final RingtoneService _instance = RingtoneService._internal();
  factory RingtoneService() => _instance;
  RingtoneService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _vibrationTimer;
  Timer? _soundTimer;
  bool _isPlaying = false;

  // Start ringtone and vibration
  Future<void> startRingtone() async {
    if (_isPlaying) {
      AppLogger.debug('Ringtone already playing');
      return;
    }

    AppLogger.debug('Starting ringtone...');
    _isPlaying = true;

    try {
      // Start vibration pattern
      AppLogger.debug('Starting vibration pattern...');
      _startVibrationPattern();

      // Start sound pattern
      AppLogger.debug('Starting sound pattern...');
      await _startSoundPattern();

      AppLogger.info('✅ Ringtone started successfully');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Error starting ringtone', e, stackTrace);

      AppLogger.debug('🔄 Falling back to haptic feedback...');
      _startHapticPattern();
    }
  }

  // Stop ringtone and vibration
  Future<void> stopRingtone() async {
    if (!_isPlaying) return;

    _isPlaying = false;

    try {
      await _audioPlayer.stop();
      _vibrationTimer?.cancel();
      _soundTimer?.cancel();

      AppLogger.debug('Ringtone stopped');
    } catch (e, stackTrace) {
      AppLogger.error('Error stopping ringtone', e, stackTrace);
    }
  }

  // Start sound pattern with actual audio
  Future<void> _startSoundPattern() async {
    try {
      AppLogger.debug('🎵 Starting sound pattern...');

      // First try to play the ringtone from assets
      bool audioPlayed = await _tryPlayRingtone();

      if (!audioPlayed) {
        // If audio file not available or failed to play, use system sounds
        if (Platform.isAndroid) {
          AppLogger.debug('📱 Android detected - using system sounds as fallback');
          await _playSystemSound();
        } else {
          AppLogger.debug('🍎 iOS detected - using haptic feedback as fallback');
          _startHapticPattern();
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Error playing audio', e, stackTrace);
      _startHapticPattern();
    }
  }

  // Try to play ringtone from assets
  Future<bool> _tryPlayRingtone() async {
    try {
      AppLogger.debug('🔊 Attempting to play ringtone.mp3 from assets...');

      // Set volume
      await _audioPlayer.setVolume(1.0);

      // Try to play the ringtone file
      await _audioPlayer.play(
        AssetSource('audio/ringtone.mp3'),
        mode: PlayerMode.lowLatency,
      );

      AppLogger.debug('✅ Ringtone started successfully');

      // Set up looping
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('❌ Failed to play ringtone', e, stackTrace);
      return false;
    }
  }

  // Play system sound (fallback if audio file not available)
  Future<void> _playSystemSound() async {
    try {
      // Create a more realistic ringtone pattern
      _soundTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_isPlaying) {
          // Play a sequence of beeps that sounds more like a phone ringtone
          _playBeepSound();

          // Add a second beep after a delay
          Future.delayed(const Duration(milliseconds: 400), () {
            if (_isPlaying) _playBeepSound();
          });

          // Add a third beep after another delay
          Future.delayed(const Duration(milliseconds: 800), () {
            if (_isPlaying) _playBeepSound();
          });
        } else {
          timer.cancel();
        }
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error playing system sound', e, stackTrace);
      _startHapticPattern();
    }
  }

  // Play beep sound using system sound
  Future<void> _playBeepSound() async {
    try {
      AppLogger.verbose('🔊 Playing beep sound...');
      // Use system sound for beep
      SystemSound.play(SystemSoundType.alert);

      // Add a second beep after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_isPlaying) {
          AppLogger.verbose('🔊 Playing second beep...');
          SystemSound.play(SystemSoundType.alert);
        }
      });
    } catch (e, stackTrace) {
      AppLogger.error('❌ Error playing beep', e, stackTrace);
    }
  }

  // Start haptic pattern as fallback
  void _startHapticPattern() {
    _soundTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isPlaying) {
        // Use different haptic feedback patterns to simulate ringtone
        HapticFeedback.heavyImpact();

        // Add a slight delay and play another sound
        Future.delayed(const Duration(milliseconds: 200), () {
          if (_isPlaying) {
            HapticFeedback.mediumImpact();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  // Start haptic pattern (replaces vibration)
  void _startVibrationPattern() {
    _vibrationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_isPlaying) {
        _vibrate();
      } else {
        timer.cancel();
      }
    });
  }

  // Vibrate with haptic feedback pattern
  Future<void> _vibrate() async {
    try {
      AppLogger.verbose('📳 Using haptic feedback for vibration...');

      // Create a more realistic phone call vibration pattern
      if (_isPlaying) {
        // First vibration
        HapticFeedback.heavyImpact();

        // Second vibration after a short delay
        Future.delayed(const Duration(milliseconds: 200), () {
          if (_isPlaying) HapticFeedback.heavyImpact();
        });

        // Third vibration after another delay
        Future.delayed(const Duration(milliseconds: 400), () {
          if (_isPlaying) HapticFeedback.mediumImpact();
        });

        // Fourth vibration after another delay
        Future.delayed(const Duration(milliseconds: 600), () {
          if (_isPlaying) HapticFeedback.mediumImpact();
        });
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Error with haptic feedback', e, stackTrace);
      // Fallback to light haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  // Check if ringtone is playing
  bool get isPlaying => _isPlaying;

  // Dispose resources
  void dispose() {
    stopRingtone();
    _audioPlayer.dispose();
  }
}
