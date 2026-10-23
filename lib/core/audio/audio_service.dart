import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sound_mode_controller.dart';

/// Interface abstraite pour le lecteur audio (permet de simuler facilement dans les tests).
abstract class AudioPlayerClient {
  Future<void> playAsset(String assetPath);
  void dispose();
}

/// Implémentation réelle utilisant `audioplayers` optimisée pour mobile (iOS & Android).
class RealAudioPlayerClient implements AudioPlayerClient {
  final List<AudioPlayer> _activePlayers = [];

  RealAudioPlayerClient() {
    _initAudioContext();
  }

  void _initAudioContext() {
    try {
      AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.defaultToSpeaker,
            },
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
    } catch (e) {
      debugPrint('[Audio] AudioContext init warning: $e');
    }
  }

  @override
  Future<void> playAsset(String assetPath) async {
    try {
      final player = AudioPlayer();
      _activePlayers.add(player);
      await player.setVolume(1.0);
      await player.play(AssetSource(assetPath));

      player.onPlayerComplete.listen((_) {
        _activePlayers.remove(player);
        player.dispose();
      });
    } catch (e) {
      debugPrint('[Audio] Erreur lecture asset $assetPath: $e');
    }
  }

  @override
  void dispose() {
    for (final player in _activePlayers) {
      try {
        player.dispose();
      } catch (_) {}
    }
    _activePlayers.clear();
  }
}

/// Service central gérant la diffusion des bruitages de MathPup.
/// Si les effets sonores sont désactivés par le parent ou l'enfant, aucun son n'est émis.
class AudioService {
  final AudioPlayerClient client;
  final bool isSoundEnabled;

  const AudioService({required this.client, required this.isSoundEnabled});

  /// Clic tactile / sélection d'un bouton ou accessoire
  Future<void> playPop() => _play('audio/sfx_pop.wav');

  /// Réponse mathématique correcte (carillon magique)
  Future<void> playSuccess() => _play('audio/sfx_success.wav');

  /// Réponse incorrecte (son doux d'encouragement)
  Future<void> playError() => _play('audio/sfx_error.wav');

  /// Jappement joyeux « Wouf ! » de Pi
  Future<void> playBark() => _play('audio/sfx_bark.wav');

  /// Rebond de la balle de tennis
  Future<void> playBall() => _play('audio/sfx_ball.wav');

  /// Croquettes versées dans la gamelle
  Future<void> playFeed() => _play('audio/sfx_feed.wav');

  /// Éclaboussures d'eau et bulles pendant le bain
  Future<void> playWater() => _play('audio/sfx_water.wav');

  /// Récolte d'un Os doré ou achat en boutique
  Future<void> playBone() => _play('audio/sfx_bone.wav');

  /// Victoire ou fin de quiz 6/6 (fanfare de célébration)
  Future<void> playCelebration() => _play('audio/sfx_celebration.wav');

  Future<void> _play(String assetPath) async {
    if (!isSoundEnabled) return;
    await client.playAsset(assetPath);
  }
}

/// Provider pour injecter le client audio (remplaçable dans les tests)
final audioPlayerClientProvider = Provider<AudioPlayerClient>((ref) {
  final client = RealAudioPlayerClient();
  ref.onDispose(() => client.dispose());
  return client;
});

/// Provider d'accès au service audio dans toute l'application
final audioServiceProvider = Provider<AudioService>((ref) {
  final isEnabled = ref.watch(soundEnabledProvider);
  final client = ref.watch(audioPlayerClientProvider);
  return AudioService(client: client, isSoundEnabled: isEnabled);
});
