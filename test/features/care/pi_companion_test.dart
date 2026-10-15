import 'package:flutter_test/flutter_test.dart';
import 'package:pi_et_moi/features/care/domain/pi_companion.dart';
import 'package:pi_et_moi/features/care/domain/play_environment.dart';

void main() {
  group('PiCompanion Unit Tests', () {
    test('initial factory sets default values', () {
      final pi = PiCompanion.initial();

      expect(pi.hunger, equals(0.80));
      expect(pi.joy, equals(0.70));
      expect(pi.energy, equals(0.90));
      expect(pi.cleanliness, equals(1.0));
      expect(pi.dirtCount, equals(0));
      expect(pi.isDirty, isFalse);
      expect(pi.croquettes, equals(3));
      expect(pi.balls, equals(2));
      expect(pi.bones, equals(50));
      expect(pi.bowlFoodCount, equals(0));
      expect(pi.isEating, isFalse);
      expect(pi.environment, equals(PlayEnvironment.livingRoom));
      expect(pi.piX, equals(0.0));
      expect(pi.piY, equals(0.2));
      expect(pi.isBallActive, isFalse);
    });

    test('serveBowl decrements croquettes and fills bowl up to 3', () {
      final pi = PiCompanion.initial();
      final s1 = pi.serveBowl();
      expect(s1.croquettes, equals(2));
      expect(s1.bowlFoodCount, equals(1));

      final s2 = s1.serveBowl();
      expect(s2.croquettes, equals(1));
      expect(s2.bowlFoodCount, equals(2));

      final s3 = s2.serveBowl();
      expect(s3.croquettes, equals(0));
      expect(s3.bowlFoodCount, equals(3));

      // Ne peut plus servir si bowlFoodCount == 3
      final s4 = s3.serveBowl();
      expect(s4.bowlFoodCount, equals(3));
    });

    test('startEating moves Pi to bowl and sets isEating', () {
      final pi = const PiCompanion(croquettes: 2, bowlFoodCount: 2);
      final eating = pi.startEating(-0.68, 0.48, 'Miam miam...');

      expect(eating.isEating, isTrue);
      expect(eating.piX, equals(-0.68));
      expect(eating.piY, equals(0.48));
      expect(eating.statusMessage, equals('Miam miam...'));
    });

    test('finishEating restores hunger, empties bowl, and returns Pi to center', () {
      final pi = const PiCompanion(
        hunger: 0.40,
        joy: 0.50,
        bowlFoodCount: 2,
        isEating: true,
        piX: -0.68,
        piY: 0.48,
      );

      final finished = pi.finishEating('Délicieux repas !');

      expect(finished.isEating, isFalse);
      expect(finished.bowlFoodCount, equals(0));
      expect(finished.hunger, greaterThan(0.40));
      expect(finished.joy, greaterThan(0.50));
      expect(finished.piX, equals(0.0));
      expect(finished.piY, equals(0.2));
      expect(finished.statusMessage, equals('Délicieux repas !'));
    });

    test('collectAndReturnBall accumulates dirt on Pi', () {
      final pi = PiCompanion.initial().throwBall(0.6, -0.1, 'Go !');
      expect(pi.dirtCount, equals(0));

      final fetched = pi.collectAndReturnBall('Balle rapportée !');
      expect(fetched.dirtCount, equals(2));
      expect(fetched.cleanliness, closeTo(0.65, 0.01));
      expect(fetched.isDirty, isTrue);
    });

    test('clean restores cleanliness and resets dirtCount', () {
      final dirtyPi = const PiCompanion(dirtCount: 3, cleanliness: 0.25, joy: 0.50);
      final cleaned = dirtyPi.clean('Tout propre !');

      expect(cleaned.dirtCount, equals(0));
      expect(cleaned.cleanliness, equals(1.0));
      expect(cleaned.isDirty, isFalse);
      expect(cleaned.joy, closeTo(0.65, 0.01));
      expect(cleaned.statusMessage, equals('Tout propre !'));
    });

    test('throwBall places ball on field WITHOUT decrementing balls count', () {
      final pi = PiCompanion.initial();
      final thrown = pi.throwBall(0.5, -0.2, 'Cherche la balle !');

      expect(thrown.isBallActive, isTrue);
      expect(thrown.activeBallX, equals(0.5));
      expect(thrown.activeBallY, equals(-0.2));
      expect(thrown.balls, equals(2));
      expect(thrown.statusMessage, equals('Cherche la balle !'));
    });

    test('moveTo guides Pi freely and flips direction', () {
      final pi = PiCompanion.initial();
      final movedLeft = pi.moveTo(-0.5, 0.1);

      expect(movedLeft.piX, equals(-0.5));
      expect(movedLeft.piY, equals(0.1));
      expect(movedLeft.isFacingLeft, isTrue);

      final movedRight = movedLeft.moveTo(0.4, 0.1);
      expect(movedRight.piX, equals(0.4));
      expect(movedRight.isFacingLeft, isFalse);
    });

    test('setEnvironment switches environment and sets correct French grammar', () {
      final pi = PiCompanion.initial();

      final salon = pi.setEnvironment(PlayEnvironment.livingRoom, isFrench: true);
      expect(salon.statusMessage, equals('Bienvenue dans le salon !'));

      final beach = pi.setEnvironment(PlayEnvironment.beach, isFrench: true);
      expect(beach.statusMessage, equals('Bienvenue à la plage !'));
    });

    test('addRewards credits quiz earnings', () {
      final pi = PiCompanion.initial();
      final rewarded = pi.addRewards(addedBones: 30, addedCroquettes: 3, addedBalls: 2);

      expect(rewarded.bones, equals(80));
      expect(rewarded.croquettes, equals(6));
      expect(rewarded.balls, equals(4));
    });

    test('serialization toMap and fromMap preserves data', () {
      final pi = const PiCompanion(
        hunger: 0.65,
        joy: 0.85,
        energy: 0.75,
        cleanliness: 0.75,
        dirtCount: 2,
        croquettes: 5,
        balls: 4,
        bones: 120,
        bowlFoodCount: 2,
        environment: PlayEnvironment.beach,
        piX: -0.3,
        piY: 0.1,
        initialPiX: 0.0,
        initialPiY: 0.2,
        isFacingLeft: true,
      );

      final map = pi.toMap();
      final recreated = PiCompanion.fromMap(map);

      expect(recreated.hunger, equals(pi.hunger));
      expect(recreated.joy, equals(pi.joy));
      expect(recreated.energy, equals(pi.energy));
      expect(recreated.cleanliness, equals(pi.cleanliness));
      expect(recreated.dirtCount, equals(pi.dirtCount));
      expect(recreated.croquettes, equals(pi.croquettes));
      expect(recreated.balls, equals(pi.balls));
      expect(recreated.bones, equals(pi.bones));
      expect(recreated.bowlFoodCount, equals(pi.bowlFoodCount));
      expect(recreated.environment, equals(PlayEnvironment.beach));
      expect(recreated.piX, equals(pi.piX));
      expect(recreated.isFacingLeft, isTrue);
    });

    test('serveBowl does not serve if hunger >= 1.0 or if sleeping', () {
      final fullPi = const PiCompanion(hunger: 1.0, croquettes: 5, bowlFoodCount: 0);
      final s1 = fullPi.serveBowl();
      expect(s1.bowlFoodCount, equals(0));
      expect(s1.croquettes, equals(5));

      final sleepingPi = const PiCompanion(hunger: 0.5, croquettes: 5, bowlFoodCount: 0, isSleeping: true);
      final s2 = sleepingPi.serveBowl();
      expect(s2.bowlFoodCount, equals(0));
      expect(s2.croquettes, equals(5));
    });

    test('throwBall and moveTo do not execute when isSleeping is true', () {
      final sleepingPi = const PiCompanion(balls: 3, isSleeping: true, piX: 0.0, piY: 0.2);
      final thrown = sleepingPi.throwBall(0.5, 0.5, 'Go');
      expect(thrown.isBallActive, isFalse);

      final moved = sleepingPi.moveTo(0.5, 0.5);
      expect(moved.piX, equals(0.0));
      expect(moved.piY, equals(0.2));
    });

    test('wakeUp restores isSleeping to false', () {
      final sleepingPi = const PiCompanion(isSleeping: true);
      final awake = sleepingPi.wakeUp();
      expect(awake.isSleeping, isFalse);
    });
  });

  group('PlayEnvironment Tests', () {
    test('covers all 4 requested decors', () {
      expect(PlayEnvironment.values.length, equals(4));
      expect(PlayEnvironment.fromId('garden'), equals(PlayEnvironment.garden));
      expect(PlayEnvironment.fromId('beach'), equals(PlayEnvironment.beach));
      expect(PlayEnvironment.fromId('forest'), equals(PlayEnvironment.forest));
      expect(PlayEnvironment.fromId('unknown'), equals(PlayEnvironment.livingRoom));
    });
  });
}
