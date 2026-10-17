import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/audio/audio_service.dart';
import 'package:pi_et_moi/core/audio/sound_mode_controller.dart';

class FakeAudioClient implements AudioPlayerClient {
  final List<String> playedAssets = [];

  @override
  Future<void> playAsset(String assetPath) async {
    playedAssets.add(assetPath);
  }

  @override
  void dispose() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SoundModeNotifier Tests', () {
    test('Defaults to enabled (true) and persists changes', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final notifier = SoundModeNotifier(prefsInstance: prefs);

      expect(notifier.state, isTrue);

      await notifier.setSoundEnabled(false);
      expect(notifier.state, isFalse);
      expect(prefs.getBool('mathpup_sound_enabled_v1'), isFalse);

      await notifier.toggle();
      expect(notifier.state, isTrue);
      expect(prefs.getBool('mathpup_sound_enabled_v1'), isTrue);
    });
  });

  group('AudioService Tests', () {
    late FakeAudioClient fakeClient;

    setUp(() {
      fakeClient = FakeAudioClient();
    });

    test('Plays sounds when sound is enabled', () async {
      final service = AudioService(client: fakeClient, isSoundEnabled: true);

      await service.playPop();
      await service.playSuccess();
      await service.playError();
      await service.playBark();
      await service.playBall();
      await service.playFeed();
      await service.playWater();
      await service.playBone();
      await service.playCelebration();

      expect(fakeClient.playedAssets, [
        'audio/sfx_pop.wav',
        'audio/sfx_success.wav',
        'audio/sfx_error.wav',
        'audio/sfx_bark.wav',
        'audio/sfx_ball.wav',
        'audio/sfx_feed.wav',
        'audio/sfx_water.wav',
        'audio/sfx_bone.wav',
        'audio/sfx_celebration.wav',
      ]);
    });

    test('Does not play sounds when sound is disabled', () async {
      final service = AudioService(client: fakeClient, isSoundEnabled: false);

      await service.playPop();
      await service.playSuccess();
      await service.playBark();

      expect(fakeClient.playedAssets, isEmpty);
    });
  });
}
