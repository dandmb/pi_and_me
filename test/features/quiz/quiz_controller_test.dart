import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';
import 'package:pi_et_moi/features/quiz/domain/math_question_generator.dart';
import 'package:pi_et_moi/features/quiz/presentation/quiz_controller.dart';

void main() {
  group('QuizController Tests', () {
    late QuizController controller;

    setUp(() {
      final generator = MathQuestionGenerator(Random(123));
      controller = QuizController(generator: generator);
    });

    test('initial state is empty and uncompleted', () {
      expect(controller.state.questions, isEmpty);
      expect(controller.state.currentIndex, equals(0));
      expect(controller.state.score, equals(0));
      expect(controller.state.isCompleted, isFalse);
    });

    test('startQuiz populates 6 questions and resets counters', () {
      controller.startQuiz(SchoolGrade.cm1);

      expect(controller.state.questions.length, equals(6));
      expect(controller.state.currentIndex, equals(0));
      expect(controller.state.selectedIndex, isNull);
      expect(controller.state.isAnswered, isFalse);
      expect(controller.state.score, equals(0));
      expect(controller.state.currentQuestion, isNotNull);
      expect(controller.state.progress, equals(0.0));
    });

    test('selectOption updates selectedIndex but not once answered', () {
      controller.startQuiz(SchoolGrade.ce2);

      controller.selectOption(2);
      expect(controller.state.selectedIndex, equals(2));

      controller.selectOption(0);
      expect(controller.state.selectedIndex, equals(0));

      controller.validateAnswer();
      expect(controller.state.isAnswered, isTrue);

      // Once answered, selecting a different option has no effect
      controller.selectOption(3);
      expect(controller.state.selectedIndex, equals(0));
    });

    test('validateAnswer records correct score and updates answersHistory', () {
      controller.startQuiz(SchoolGrade.cp);

      final currentQ = controller.state.currentQuestion!;
      final correctIdx = currentQ.correctIndex;

      controller.selectOption(correctIdx);
      controller.validateAnswer();

      expect(controller.state.isAnswered, isTrue);
      expect(controller.state.isCurrentCorrect, isTrue);
      expect(controller.state.score, equals(1));
      expect(controller.state.answersHistory, equals([true]));
    });

    test('nextQuestion advances to next question and resets selection', () {
      controller.startQuiz(SchoolGrade.cp);

      controller.selectOption(0);
      controller.validateAnswer();
      controller.nextQuestion();

      expect(controller.state.currentIndex, equals(1));
      expect(controller.state.selectedIndex, isNull);
      expect(controller.state.isAnswered, isFalse);
      expect(controller.state.isCurrentCorrect, isNull);
    });

    test('completing full quiz of 6 questions calculates rewards', () {
      controller.startQuiz(SchoolGrade.sixieme);

      for (int i = 0; i < 6; i++) {
        final q = controller.state.currentQuestion!;
        // Choose correct answer for each
        controller.selectOption(q.correctIndex);
        controller.validateAnswer();
        controller.nextQuestion();
      }

      expect(controller.state.isCompleted, isTrue);
      expect(controller.state.score, equals(6));
      // 6 * 5 + 5 = 35 bones
      expect(controller.state.bonesEarned, equals(35));
      expect(controller.state.croquettesEarned, equals(3));
      expect(controller.state.ballsEarned, equals(2));
    });

    test('resetQuiz clears all state', () {
      controller.startQuiz(SchoolGrade.cm1);
      controller.selectOption(1);
      controller.validateAnswer();
      controller.resetQuiz();

      expect(controller.state.questions, isEmpty);
      expect(controller.state.score, equals(0));
      expect(controller.state.isAnswered, isFalse);
    });
  });
}
