import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';
import 'package:pi_et_moi/features/quiz/domain/math_question.dart';
import 'package:pi_et_moi/features/quiz/domain/math_question_generator.dart';

void main() {
  group('MathQuestionGenerator Unit Tests', () {
    test('generates exactly 6 questions by default for all 9 grades', () {
      final generator = MathQuestionGenerator(Random(42));

      for (final grade in SchoolGrade.values) {
        final session = generator.generateSession(grade: grade);
        expect(
          session.length,
          equals(6),
          reason: 'Grade ${grade.label} must have 6 questions',
        );

        for (final q in session) {
          expect(q.grade, equals(grade));
          expect(
            q.options.length,
            equals(4),
            reason: 'Each question must have 4 options',
          );
          // 4 options distinctes
          expect(
            q.options.toSet().length,
            equals(4),
            reason: 'All 4 options must be distinct: ${q.options}',
          );
          expect(q.correctIndex, inInclusiveRange(0, 3));
          expect(q.options[q.correctIndex], equals(q.correctAnswer));
          expect(q.mathExpression.isNotEmpty, isTrue);
          expect(q.promptFr.isNotEmpty, isTrue);
          expect(q.promptEn.isNotEmpty, isTrue);
          expect(q.categoryFr.isNotEmpty, isTrue);
          expect(q.categoryEn.isNotEmpty, isTrue);
          expect(q.hintFr.isNotEmpty, isTrue);
          expect(q.hintEn.isNotEmpty, isTrue);
          expect(q.explanationFr.isNotEmpty, isTrue);
          expect(q.explanationEn.isNotEmpty, isTrue);
        }
      }
    });

    test('bilingual getters return correct language string', () {
      final question = MathQuestion(
        id: 'test_q',
        grade: SchoolGrade.cm1,
        categoryFr: 'CM1 • Fractions Décimales',
        categoryEn: 'Grade 4 • Decimal Fractions',
        promptFr: 'Quelle écriture correspond à :',
        promptEn: 'Which expression matches:',
        mathExpression: '3 + 7/10 = ?',
        options: const ['3,07', '3,7', '37', '0,37'],
        correctIndex: 1,
        hintFr: '3 unités et 7 dixièmes !',
        hintEn: '3 units and 7 tenths!',
        explanationFr: '3 + 7/10 = 3,7',
        explanationEn: '3 + 7/10 = 3.7',
      );

      // Français
      expect(question.getCategory(true), equals('CM1 • Fractions Décimales'));
      expect(
        question.getPrompt(true),
        equals('Quelle écriture correspond à :'),
      );
      expect(question.getHint(true), equals('3 unités et 7 dixièmes !'));
      expect(question.getExplanation(true), equals('3 + 7/10 = 3,7'));
      expect(question.correctAnswer, equals('3,7'));
      expect(question.isAnswerCorrect(1), isTrue);
      expect(question.isAnswerCorrect(0), isFalse);

      // Anglais
      expect(
        question.getCategory(false),
        equals('Grade 4 • Decimal Fractions'),
      );
      expect(question.getPrompt(false), equals('Which expression matches:'));
      expect(question.getHint(false), equals('3 units and 7 tenths!'));
      expect(question.getExplanation(false), equals('3 + 7/10 = 3.7'));
    });

    test('asserts validation on 4 options and index range', () {
      expect(
        () => MathQuestion(
          id: 'invalid',
          grade: SchoolGrade.cp,
          categoryFr: 'cat',
          categoryEn: 'cat',
          promptFr: 'prompt',
          promptEn: 'prompt',
          mathExpression: '1+1',
          options: const ['1', '2', '3'], // Only 3 options
          correctIndex: 0,
          hintFr: 'h',
          hintEn: 'h',
          explanationFr: 'e',
          explanationEn: 'e',
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => MathQuestion(
          id: 'invalid_index',
          grade: SchoolGrade.cp,
          categoryFr: 'cat',
          categoryEn: 'cat',
          promptFr: 'prompt',
          promptEn: 'prompt',
          mathExpression: '1+1',
          options: const ['1', '2', '3', '4'],
          correctIndex: 5, // Out of range
          hintFr: 'h',
          hintEn: 'h',
          explanationFr: 'e',
          explanationEn: 'e',
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
