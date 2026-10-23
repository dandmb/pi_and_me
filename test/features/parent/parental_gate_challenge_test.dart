import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pi_et_moi/features/parent/domain/parental_gate_challenge.dart';

void main() {
  group('NumberWordsConverter Tests', () {
    test('French number conversions', () {
      expect(NumberWordsConverter.toFrench(0), 'zéro');
      expect(NumberWordsConverter.toFrench(1), 'un');
      expect(NumberWordsConverter.toFrench(7), 'sept');
      expect(NumberWordsConverter.toFrench(12), 'douze');
      expect(NumberWordsConverter.toFrench(20), 'vingt');
      expect(NumberWordsConverter.toFrench(21), 'vingt et un');
      expect(NumberWordsConverter.toFrench(35), 'trente-cinq');
      expect(NumberWordsConverter.toFrench(48), 'quarante-huit');
      expect(NumberWordsConverter.toFrench(71), 'soixante et onze');
      expect(NumberWordsConverter.toFrench(75), 'soixante-quinze');
      expect(NumberWordsConverter.toFrench(80), 'quatre-vingts');
      expect(NumberWordsConverter.toFrench(92), 'quatre-vingt-douze');
    });

    test('English number conversions', () {
      expect(NumberWordsConverter.toEnglish(0), 'zero');
      expect(NumberWordsConverter.toEnglish(1), 'one');
      expect(NumberWordsConverter.toEnglish(8), 'eight');
      expect(NumberWordsConverter.toEnglish(14), 'fourteen');
      expect(NumberWordsConverter.toEnglish(20), 'twenty');
      expect(NumberWordsConverter.toEnglish(48), 'forty-eight');
      expect(NumberWordsConverter.toEnglish(56), 'fifty-six');
      expect(NumberWordsConverter.toEnglish(100), 'one hundred');
    });
  });

  group('ParentalGateChallenge Tests', () {
    const challenge = ParentalGateChallenge(
      questionFr: 'Quarante-huit divisé par six',
      questionEn: 'Forty-eight divided by six',
      expectedAnswer: 8,
    );

    test('Retrieves localized questions properly', () {
      expect(challenge.getQuestion(true), 'Quarante-huit divisé par six');
      expect(challenge.getQuestion(false), 'Forty-eight divided by six');
    });

    test('Verifies correct numerical answers with whitespace trimming and decimal/comma notation', () {
      expect(challenge.verify('8'), isTrue);
      expect(challenge.verify('  8  '), isTrue);
      expect(challenge.verify('08'), isTrue);
      expect(challenge.verify('8.0'), isTrue);
      expect(challenge.verify('8,0'), isTrue);
    });

    test('Verifies challenges with explicit decimal answers', () {
      const decimalChallenge = ParentalGateChallenge(
        questionFr: 'Quinze divisé par deux',
        questionEn: 'Fifteen divided by two',
        expectedAnswer: 7.5,
      );
      expect(decimalChallenge.verify('7.5'), isTrue);
      expect(decimalChallenge.verify('7,5'), isTrue);
      expect(decimalChallenge.verify(' 7,5 '), isTrue);
      expect(decimalChallenge.verify('7'), isFalse);
      expect(decimalChallenge.verify('7,4'), isFalse);
    });

    test('Rejects incorrect or malformed inputs', () {
      expect(challenge.verify('7'), isFalse);
      expect(challenge.verify('huit'), isFalse);
      expect(challenge.verify(''), isFalse);
      expect(challenge.verify('   '), isFalse);
      expect(challenge.verify('8,5'), isFalse);
      expect(challenge.verify('abc'), isFalse);
    });
  });

  group('ParentalGateChallengeGenerator Tests', () {
    test('Deterministic challenge generation with fixed Random seed', () {
      final generator = ParentalGateChallengeGenerator(Random(123));
      final c1 = generator.generate();
      expect(c1.expectedAnswer, greaterThan(0));
      expect(c1.questionFr.isNotEmpty, isTrue);
      expect(c1.questionEn.isNotEmpty, isTrue);

      final c2 = generator.generate();
      expect(c2.expectedAnswer, greaterThan(0));
    });

    test('Generates challenges across multiple operations', () {
      final generator = ParentalGateChallengeGenerator(Random(42));
      final answers = <num>[];
      for (int i = 0; i < 20; i++) {
        final c = generator.generate();
        answers.add(c.expectedAnswer);
        expect(c.expectedAnswer, greaterThanOrEqualTo(1));
      }
      expect(answers.toSet().length, greaterThan(3));
    });
  });

  group('ParentalGateLockoutManager Tests', () {
    test('Tracks failed attempts and locks out on 3rd failure', () {
      final manager = ParentalGateLockoutManager(lockoutDurationSeconds: 30);
      expect(manager.failedAttempts, 0);
      expect(manager.remainingAttempts, 3);
      expect(manager.isLocked, isFalse);
      expect(manager.remainingSeconds, 0);

      // Attempt 1 fails
      var justLocked = manager.recordFailure();
      expect(justLocked, isFalse);
      expect(manager.failedAttempts, 1);
      expect(manager.remainingAttempts, 2);
      expect(manager.isLocked, isFalse);

      // Attempt 2 fails
      justLocked = manager.recordFailure();
      expect(justLocked, isFalse);
      expect(manager.failedAttempts, 2);
      expect(manager.remainingAttempts, 1);
      expect(manager.isLocked, isFalse);

      // Attempt 3 fails -> triggers lockout
      justLocked = manager.recordFailure();
      expect(justLocked, isTrue);
      expect(manager.failedAttempts, 3);
      expect(manager.remainingAttempts, 0);
      expect(manager.isLocked, isTrue);
      expect(manager.remainingSeconds, greaterThan(0));

      // Reset clears lockout
      manager.reset();
      expect(manager.failedAttempts, 0);
      expect(manager.remainingAttempts, 3);
      expect(manager.isLocked, isFalse);
    });
  });
}
