import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/features/care/domain/pi_companion.dart';
import 'package:pi_et_moi/features/care/domain/play_environment.dart';
import 'package:pi_et_moi/features/care/presentation/care_controller.dart';

void main() {
  group('CareController Unit Tests', () {
    late CareController controller;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      controller = CareController(
        initialCompanion: const PiCompanion(
          hunger: 0.50,
          joy: 0.50,
          energy: 0.50,
          croquettes: 3,
          balls: 2,
          bones: 50,
          cleanliness: 0.50,
          dirtCount: 2,
        ),
      );
    });

    test('serveBowl decrements croquettes and fills bowl', () {
      controller.serveBowl(message: 'Servi !');

      expect(controller.state.croquettes, equals(2));
      expect(controller.state.bowlFoodCount, equals(1));
      expect(controller.state.statusMessage, equals('Servi !'));
    });

    test('startEating and finishEating completes feeding sequence', () {
      controller.serveBowl();
      controller.startEating(-0.68, 0.48, 'Miam miam...');

      expect(controller.state.isEating, isTrue);
      expect(controller.state.piX, equals(-0.68));

      controller.finishEating('Repas terminé !');

      expect(controller.state.isEating, isFalse);
      expect(controller.state.bowlFoodCount, equals(0));
      expect(controller.state.hunger, greaterThan(0.50));
      expect(controller.state.piX, equals(0.0));
      expect(controller.state.piY, equals(0.2)); // Retour au centre
      expect(controller.state.statusMessage, equals('Repas terminé !'));
    });

    test('cleanPi restores cleanliness and resets dirt', () {
      controller.cleanPi('Tout propre !');

      expect(controller.state.dirtCount, equals(0));
      expect(controller.state.cleanliness, equals(1.0));
      expect(controller.state.isDirty, isFalse);
      expect(controller.state.statusMessage, equals('Tout propre !'));
    });

    test('throwBall places ball on field without decrementing balls count', () {
      controller.throwBall(-0.4, 0.2, 'Cherche !');

      expect(controller.state.balls, equals(2));
      expect(controller.state.isBallActive, isTrue);
      expect(controller.state.activeBallX, equals(-0.4));
      expect(controller.state.activeBallY, equals(0.2));
    });

    test('collectAndReturnBall collects ball, rewards joy, consumes ball and soils Pi', () {
      controller.throwBall(-0.4, 0.2, 'Cherche !');
      controller.collectAndReturnBall('Bravo !');

      expect(controller.state.balls, equals(1));
      expect(controller.state.isBallActive, isFalse);
      expect(controller.state.joy, closeTo(0.75, 0.01));
      // Jouer salit Pi pour donner envie de lui faire prendre un bain
      expect(controller.state.dirtCount, equals(4));
      expect(controller.state.cleanliness, closeTo(0.15, 0.01));
    });

    test('sleepPi sets isSleeping true and wakeUpPi resets it', () {
      controller.sleepPi('Bonne nuit');
      expect(controller.state.isSleeping, isTrue);
      expect(controller.state.energy, equals(1.0));
      expect(controller.state.statusMessage, equals('Bonne nuit'));

      controller.wakeUpPi();
      expect(controller.state.isSleeping, isFalse);
    });

    test('clearMessage removes statusMessage', () {
      controller.moveTo(0.1, 0.1, message: 'Coucou');
      expect(controller.state.statusMessage, isNotNull);

      controller.clearMessage();
      expect(controller.state.statusMessage, isNull);
    });

    test('changeEnvironment updates companion environment and shows welcome only on first visit', () {
      controller.changeEnvironment(PlayEnvironment.beach, isFrench: true);

      expect(controller.state.environment, equals(PlayEnvironment.beach));
      expect(controller.state.statusMessage, equals('Bienvenue à la plage !'));

      // Switch to another environment and back to beach
      controller.changeEnvironment(PlayEnvironment.garden, isFrench: true);
      expect(
        controller.state.statusMessage,
        equals('Bienvenue dans le jardin !'),
      );

      // Re-visit beach: should not show welcome message again
      controller.changeEnvironment(PlayEnvironment.beach, isFrench: true);
      expect(controller.state.environment, equals(PlayEnvironment.beach));
      expect(controller.state.statusMessage, isNull);
    });
  });
}
