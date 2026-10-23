import 'dart:math';

import '../../profile/domain/school_grade.dart';
import 'math_question.dart';

/// Générateur de questions mathématiques par niveau scolaire (CP à 3e / Grades 1 to 9).
/// Déterministe lorsque fourni avec un `Random` avec graine fixe (idéal pour les tests).
class MathQuestionGenerator {
  final Random _random;

  MathQuestionGenerator([Random? random]) : _random = random ?? Random();

  /// Génère une liste de [count] questions adaptées à la classe [grade].
  List<MathQuestion> generateSession({
    required SchoolGrade grade,
    int count = 6,
  }) {
    final questions = <MathQuestion>[];
    for (int i = 0; i < count; i++) {
      questions.add(_generateSingleQuestion(grade, i));
    }
    return questions;
  }

  MathQuestion _generateSingleQuestion(SchoolGrade grade, int index) {
    switch (grade) {
      case SchoolGrade.cp:
        return _generateCpQuestion(index);
      case SchoolGrade.ce1:
        return _generateCe1Question(index);
      case SchoolGrade.ce2:
        return _generateCe2Question(index);
      case SchoolGrade.cm1:
        return _generateCm1Question(index);
      case SchoolGrade.cm2:
        return _generateCm2Question(index);
      case SchoolGrade.sixieme:
        return _generate6eQuestion(index);
      case SchoolGrade.cinquieme:
        return _generate5eQuestion(index);
      case SchoolGrade.quatrieme:
        return _generate4eQuestion(index);
      case SchoolGrade.troisieme:
        return _generate3eQuestion(index);
    }
  }

  // --- CP (Grade 1) ---
  MathQuestion _generateCpQuestion(int index) {
    final type = index % 3;
    if (type == 0) {
      final a = _random.nextInt(6) + 1; // 1..6
      final b = _random.nextInt(4) + 1; // 1..4
      final answer = a + b;
      return _buildQuestion(
        id: 'cp_add_$index',
        grade: SchoolGrade.cp,
        categoryFr: 'CP • Additions',
        categoryEn: 'Grade 1 • Addition',
        promptFr: 'Combien font :',
        promptEn: 'How much is:',
        mathExpression: '$a + $b = ?',
        correctAnswer: '$answer',
        distractors: [
          '${answer + 1}',
          '${max(1, answer - 1)}',
          '${answer + 2}',
        ],
        hintFr: 'Compte sur tes doigts avec Pi ! 🐾',
        hintEn: 'Count on your paws with Pi! 🐾',
        explanationFr: '$a + $b est égal à $answer.',
        explanationEn: '$a + $b equals $answer.',
      );
    } else if (type == 1) {
      final a = _random.nextInt(6) + 4; // 4..9
      final b = _random.nextInt(a - 1) + 1; // 1..a-1
      final answer = a - b;
      return _buildQuestion(
        id: 'cp_sub_$index',
        grade: SchoolGrade.cp,
        categoryFr: 'CP • Soustractions',
        categoryEn: 'Grade 1 • Subtraction',
        promptFr: 'Combien font :',
        promptEn: 'How much is:',
        mathExpression: '$a - $b = ?',
        correctAnswer: '$answer',
        distractors: [
          '${answer + 1}',
          '${max(0, answer - 1)}',
          '${answer + 2}',
        ],
        hintFr: 'Imagine que Pi retire $b os sur les $a !',
        hintEn: 'Imagine Pi takes away $b bones from $a!',
        explanationFr: '$a - $b est égal à $answer.',
        explanationEn: '$a - $b equals $answer.',
      );
    } else {
      final a = _random.nextInt(8) + 1; // 1..8
      final answer = 10 - a;
      return _buildQuestion(
        id: 'cp_comp_$index',
        grade: SchoolGrade.cp,
        categoryFr: 'CP • Compléments à 10',
        categoryEn: 'Grade 1 • Make 10',
        promptFr: 'Trouve le nombre manquant :',
        promptEn: 'Find the missing number:',
        mathExpression: '$a + ? = 10',
        correctAnswer: '$answer',
        distractors: [
          '${answer + 1}',
          '${max(1, answer - 1)}',
          '${(answer + 3) % 10}',
        ],
        hintFr: 'Combien manque-t-il pour faire 10 ?',
        hintEn: 'How many more to make 10?',
        explanationFr: '$a + $answer = 10.',
        explanationEn: '$a + $answer = 10.',
      );
    }
  }

  // --- CE1 (Grade 2) ---
  MathQuestion _generateCe1Question(int index) {
    final type = index % 3;
    if (type == 0) {
      final a = (_random.nextInt(4) + 2) * 10 + _random.nextInt(8); // 20..57
      final b = (_random.nextInt(3) + 1) * 10 + _random.nextInt(5); // 10..34
      final answer = a + b;
      return _buildQuestion(
        id: 'ce1_add_$index',
        grade: SchoolGrade.ce1,
        categoryFr: 'CE1 • Additions à 2 chiffres',
        categoryEn: 'Grade 2 • 2-Digit Addition',
        promptFr: 'Calcule la somme :',
        promptEn: 'Calculate the sum:',
        mathExpression: '$a + $b = ?',
        correctAnswer: '$answer',
        distractors: ['${answer + 10}', '${answer - 1}', '${answer + 2}'],
        hintFr: 'Additionne d\'abord les unités, puis les dizaines !',
        hintEn: 'Add the ones first, then the tens!',
        explanationFr: '$a + $b = $answer.',
        explanationEn: '$a + $b = $answer.',
      );
    } else if (type == 1) {
      final base = [2, 5, 10][_random.nextInt(3)];
      final factor = _random.nextInt(9) + 2; // 2..10
      final answer = base * factor;
      return _buildQuestion(
        id: 'ce1_mult_$index',
        grade: SchoolGrade.ce1,
        categoryFr: 'CE1 • Tables de 2, 5 et 10',
        categoryEn: 'Grade 2 • Times Tables 2, 5, 10',
        promptFr: 'Calcule le produit :',
        promptEn: 'Calculate the product:',
        mathExpression: '$factor × $base = ?',
        correctAnswer: '$answer',
        distractors: [
          '${answer + base}',
          '${max(2, answer - base)}',
          '${answer + 1}',
        ],
        hintFr: 'Rappelle-toi de la table de $base !',
        hintEn: 'Remember your table of $base!',
        explanationFr: '$factor × $base = $answer.',
        explanationEn: '$factor × $base = $answer.',
      );
    } else {
      final a = (_random.nextInt(6) + 3) * 2; // nombre pair 6..16
      final answer = a ~/ 2;
      return _buildQuestion(
        id: 'ce1_half_$index',
        grade: SchoolGrade.ce1,
        categoryFr: 'CE1 • Moitiés',
        categoryEn: 'Grade 2 • Halves',
        promptFr: 'Quelle est la moitié de :',
        promptEn: 'What is half of:',
        mathExpression: '$a ÷ 2 = ?',
        correctAnswer: '$answer',
        distractors: [
          '${answer + 1}',
          '${max(1, answer - 1)}',
          '${answer + 2}',
        ],
        hintFr: 'Partage en deux parts égales ! 🐾',
        hintEn: 'Split into two equal parts! 🐾',
        explanationFr: 'La moitié de $a est $answer.',
        explanationEn: 'Half of $a is $answer.',
      );
    }
  }

  // --- CE2 (Grade 3) ---
  MathQuestion _generateCe2Question(int index) {
    final type = index % 3;
    if (type == 0) {
      final a = _random.nextInt(6) + 4; // 4..9
      final b = _random.nextInt(6) + 4; // 4..9
      final answer = a * b;
      return _buildQuestion(
        id: 'ce2_mult_$index',
        grade: SchoolGrade.ce2,
        categoryFr: 'CE2 • Tables de multiplication',
        categoryEn: 'Grade 3 • Multiplication Tables',
        promptFr: 'Calcule :',
        promptEn: 'Calculate:',
        mathExpression: '$a × $b = ?',
        correctAnswer: '$answer',
        distractors: [
          '${answer + a}',
          '${max(10, answer - b)}',
          '${answer + 2}',
        ],
        hintFr: 'C\'est la table de $a et de $b !',
        hintEn: 'That\'s the $a and $b times table!',
        explanationFr: '$a × $b = $answer.',
        explanationEn: '$a × $b = $answer.',
      );
    } else if (type == 1) {
      final divisor = _random.nextInt(5) + 3; // 3..7
      final quotient = _random.nextInt(6) + 3; // 3..8
      final dividend = divisor * quotient;
      return _buildQuestion(
        id: 'ce2_div_$index',
        grade: SchoolGrade.ce2,
        categoryFr: 'CE2 • Partages et divisions',
        categoryEn: 'Grade 3 • Division & Sharing',
        promptFr: 'Combien vaut :',
        promptEn: 'How much is:',
        mathExpression: '$dividend ÷ $divisor = ?',
        correctAnswer: '$quotient',
        distractors: [
          '${quotient + 1}',
          '${max(1, quotient - 1)}',
          '${quotient + 2}',
        ],
        hintFr: 'Combien de fois $divisor dans $dividend ?',
        hintEn: 'How many times $divisor in $dividend?',
        explanationFr:
            '$dividend ÷ $divisor = $quotient car $divisor × $quotient = $dividend.',
        explanationEn:
            '$dividend ÷ $divisor = $quotient because $divisor × $quotient = $dividend.',
      );
    } else {
      final c = _random.nextInt(7) + 2; // 2..8
      final d = _random.nextInt(8) + 1; // 1..8
      final u = _random.nextInt(9) + 1; // 1..9
      final fullNumber = c * 100 + d * 10 + u;
      return _buildQuestion(
        id: 'ce2_decomp_$index',
        grade: SchoolGrade.ce2,
        categoryFr: 'CE2 • Numération',
        categoryEn: 'Grade 3 • Place Value',
        promptFr: 'Recompose le nombre :',
        promptEn: 'Put the number together:',
        mathExpression: '${c * 100} + ${d * 10} + $u = ?',
        correctAnswer: '$fullNumber',
        distractors: [
          '${fullNumber + 10}',
          '${fullNumber - 100}',
          '${c * 100 + u * 10 + d}',
        ],
        hintFr: 'Centaines, dizaines et unités !',
        hintEn: 'Hundreds, tens, and units!',
        explanationFr: '${c * 100} + ${d * 10} + $u = $fullNumber.',
        explanationEn: '${c * 100} + ${d * 10} + $u = $fullNumber.',
      );
    }
  }

  // --- CM1 (Grade 4) ---
  MathQuestion _generateCm1Question(int index) {
    final type = index % 3;
    if (type == 0) {
      final unit = _random.nextInt(8) + 1; // 1..8
      final tenth = _random.nextInt(8) + 1; // 1..8
      final answer = '$unit,$tenth';
      return _buildQuestion(
        id: 'cm1_fracdec_$index',
        grade: SchoolGrade.cm1,
        categoryFr: 'CM1 • Fractions Décimales',
        categoryEn: 'Grade 4 • Decimal Fractions',
        promptFr: 'Quelle écriture correspond à :',
        promptEn: 'Which expression matches:',
        mathExpression: '$unit + $tenth/10 = ?',
        correctAnswer: answer,
        distractors: ['$unit,0$tenth', '${unit * 10 + tenth}', '0,$tenth'],
        hintFr: '$unit unités et $tenth dixièmes ! 🐾',
        hintEn: '$unit units and $tenth tenths! 🐾',
        explanationFr: '$unit + $tenth/10 s\'écrit $answer en nombre décimal.',
        explanationEn: '$unit + $tenth/10 is written $answer as a decimal.',
      );
    } else if (type == 1) {
      final a = (_random.nextInt(4) + 1) * 1.5; // ex: 1.5, 3.0, 4.5
      final b = 0.5 + _random.nextInt(3); // 0.5, 1.5, 2.5
      final sum = ((a + b) * 10).round() / 10;
      final aStr = a.toStringAsFixed(1).replaceAll('.', ',');
      final bStr = b.toStringAsFixed(1).replaceAll('.', ',');
      final sumStr = sum.toStringAsFixed(1).replaceAll('.', ',');
      final wrong1 = (sum + 0.5).toStringAsFixed(1).replaceAll('.', ',');
      final wrong2 = max(
        0.1,
        sum - 0.5,
      ).toStringAsFixed(1).replaceAll('.', ',');
      final wrong3 = (sum + 1.0).toStringAsFixed(1).replaceAll('.', ',');
      return _buildQuestion(
        id: 'cm1_adddec_$index',
        grade: SchoolGrade.cm1,
        categoryFr: 'CM1 • Calcul Décimal',
        categoryEn: 'Grade 4 • Decimals',
        promptFr: 'Calcule la somme :',
        promptEn: 'Calculate the sum:',
        mathExpression: '$aStr + $bStr = ?',
        correctAnswer: sumStr,
        distractors: [wrong1, wrong2, wrong3],
        hintFr: 'Aligne bien les virgules !',
        hintEn: 'Line up the decimal points!',
        explanationFr: '$aStr + $bStr = $sumStr.',
        explanationEn: '$aStr + $bStr = $sumStr.',
      );
    } else {
      final fractions = [
        {
          'expr': '1/2',
          'ans': '0,5',
          'wrongs': ['0,2', '1,2', '0,05'],
        },
        {
          'expr': '1/4',
          'ans': '0,25',
          'wrongs': ['0,4', '0,5', '0,14'],
        },
        {
          'expr': '3/4',
          'ans': '0,75',
          'wrongs': ['0,34', '0,5', '0,43'],
        },
        {
          'expr': '1/10',
          'ans': '0,1',
          'wrongs': ['0,01', '1,0', '0,100'],
        },
      ];
      final item = fractions[_random.nextInt(fractions.length)];
      return _buildQuestion(
        id: 'cm1_fracusu_$index',
        grade: SchoolGrade.cm1,
        categoryFr: 'CM1 • Fractions Usuelles',
        categoryEn: 'Grade 4 • Common Fractions',
        promptFr: 'Quelle est la valeur décimale de :',
        promptEn: 'What is the decimal value of:',
        mathExpression: '${item['expr']} = ?',
        correctAnswer: item['ans'] as String,
        distractors: List<String>.from(item['wrongs'] as List),
        hintFr: 'Pense à la moitié ou au quart d\'une tarte !',
        hintEn: 'Think of half or quarter of a pie!',
        explanationFr: '${item['expr']} correspond à ${item['ans']}.',
        explanationEn: '${item['expr']} corresponds to ${item['ans']}.',
      );
    }
  }

  // --- CM2 (Grade 5) ---
  MathQuestion _generateCm2Question(int index) {
    final type = index % 3;
    if (type == 0) {
      final percent = [50, 25, 10][_random.nextInt(3)];
      final base = percent == 25 ? 40 : (percent == 50 ? 60 : 80);
      final ansVal = (base * percent) ~/ 100;
      return _buildQuestion(
        id: 'cm2_percent_$index',
        grade: SchoolGrade.cm2,
        categoryFr: 'CM2 • Pourcentages',
        categoryEn: 'Grade 5 • Percentages',
        promptFr: 'Calcule :',
        promptEn: 'Calculate:',
        mathExpression: '$percent% de $base = ?',
        correctAnswer: '$ansVal',
        distractors: [
          '${ansVal + 5}',
          '${max(5, ansVal - 5)}',
          '${ansVal * 2}',
        ],
        hintFr: percent == 50
            ? '50% c\'est la moitié !'
            : (percent == 25
                  ? '25% c\'est le quart !'
                  : '10% c\'est divisé par 10 !'),
        hintEn: percent == 50
            ? '50% is half!'
            : (percent == 25 ? '25% is a quarter!' : '10% is divided by 10!'),
        explanationFr: '$percent% de $base = $ansVal.',
        explanationEn: '$percent% of $base = $ansVal.',
      );
    } else if (type == 1) {
      final num = (_random.nextInt(80) + 12) / 10; // ex: 1.2 .. 9.1
      final mult10 = (num * 10).round();
      final numStr = num.toStringAsFixed(1).replaceAll('.', ',');
      return _buildQuestion(
        id: 'cm2_mult10_$index',
        grade: SchoolGrade.cm2,
        categoryFr: 'CM2 • Multiplier par 10',
        categoryEn: 'Grade 5 • Multiply by 10',
        promptFr: 'Quel est le résultat de :',
        promptEn: 'What is the result of:',
        mathExpression: '$numStr × 10 = ?',
        correctAnswer: '$mult10',
        distractors: ['${numStr}0', '${mult10 * 10}', '0,$mult10'],
        hintFr: 'Déplace la virgule d\'un rang vers la droite !',
        hintEn: 'Move the decimal point one step to the right!',
        explanationFr: '$numStr × 10 = $mult10.',
        explanationEn: '$numStr × 10 = $mult10.',
      );
    } else {
      final side = _random.nextInt(7) + 3; // 3..9
      final perimeter = side * 4;
      return _buildQuestion(
        id: 'cm2_perim_$index',
        grade: SchoolGrade.cm2,
        categoryFr: 'CM2 • Périmètres',
        categoryEn: 'Grade 5 • Perimeters',
        promptFr: 'Périmètre d\'un carré de côté :',
        promptEn: 'Perimeter of a square with side:',
        mathExpression: 'c = $side cm → Périmètre = ?',
        correctAnswer: '$perimeter cm',
        distractors: [
          '${side * side} cm',
          '${side * 2} cm',
          '${perimeter + 4} cm',
        ],
        hintFr: 'Le carré a 4 côtés égaux ! Périmètre = 4 × c.',
        hintEn: 'A square has 4 equal sides! Perimeter = 4 × s.',
        explanationFr: '4 × $side cm = $perimeter cm.',
        explanationEn: '4 × $side cm = $perimeter cm.',
      );
    }
  }

  // --- 6e (Grade 6) ---
  MathQuestion _generate6eQuestion(int index) {
    final type = index % 3;
    if (type == 0) {
      final a = _random.nextInt(5) + 2; // 2..6
      final b = _random.nextInt(4) + 2; // 2..5
      final c = _random.nextInt(5) + 2; // 2..6
      final correct = a + (b * c);
      final wrongPriority = (a + b) * c;
      return _buildQuestion(
        id: '6e_prio_$index',
        grade: SchoolGrade.sixieme,
        categoryFr: '6e • Priorités Opératoires',
        categoryEn: 'Grade 6 • Order of Operations',
        promptFr: 'Calcule en respectant les priorités :',
        promptEn: 'Calculate following operation order:',
        mathExpression: '$a + $b × $c = ?',
        correctAnswer: '$correct',
        distractors: [
          '$wrongPriority',
          '${correct + 2}',
          '${max(1, correct - 3)}',
        ],
        hintFr: 'La multiplication est prioritaire sur l\'addition ! 🐾',
        hintEn: 'Multiplication comes before addition! 🐾',
        explanationFr:
            'On calcule d\'abord $b × $c = ${b * c}, puis $a + ${b * c} = $correct.',
        explanationEn:
            'First calculate $b × $c = ${b * c}, then $a + ${b * c} = $correct.',
      );
    } else if (type == 1) {
      final l = _random.nextInt(6) + 4; // 4..9
      final w = _random.nextInt(4) + 2; // 2..5
      final area = l * w;
      return _buildQuestion(
        id: '6e_area_$index',
        grade: SchoolGrade.sixieme,
        categoryFr: '6e • Aires et Géométrie',
        categoryEn: 'Grade 6 • Area & Geometry',
        promptFr: 'Aire d\'un rectangle de dimensions :',
        promptEn: 'Area of a rectangle with dimensions:',
        mathExpression: 'L = $l cm, l = $w cm → Aire = ?',
        correctAnswer: '$area cm²',
        distractors: [
          '${(l + w) * 2} cm²',
          '${area + 4} cm²',
          '${l * 2 + w} cm²',
        ],
        hintFr: 'L\'aire d\'un rectangle est Longueur × largeur !',
        hintEn: 'The area of a rectangle is Length × width!',
        explanationFr: 'Aire = $l × $w = $area cm².',
        explanationEn: 'Area = $l × $w = $area cm².',
      );
    } else {
      final num = (_random.nextInt(5) + 3) * 2; // 6, 8, 10..
      return _buildQuestion(
        id: '6e_divdec_$index',
        grade: SchoolGrade.sixieme,
        categoryFr: '6e • Division Décimale',
        categoryEn: 'Grade 6 • Decimal Division',
        promptFr: 'Calcule le quotient :',
        promptEn: 'Calculate the quotient:',
        mathExpression: '$num ÷ 4 = ?',
        correctAnswer: (num / 4).toStringAsFixed(2).replaceAll('.', ','),
        distractors: [
          ((num / 4) + 0.5).toStringAsFixed(2).replaceAll('.', ','),
          ((num / 4) - 0.25).toStringAsFixed(2).replaceAll('.', ','),
          '${num ~/ 4}',
        ],
        hintFr: 'Divise par 2, puis encore par 2 !',
        hintEn: 'Divide by 2, then by 2 again!',
        explanationFr:
            '$num ÷ 4 = ${(num / 4).toStringAsFixed(2).replaceAll('.', ',')}.',
        explanationEn:
            '$num ÷ 4 = ${(num / 4).toStringAsFixed(2).replaceAll('.', ',')}.',
      );
    }
  }

  // --- 5e (Grade 7) ---
  MathQuestion _generate5eQuestion(int index) {
    final type = index % 3;
    if (type == 0) {
      final a = -(_random.nextInt(7) + 3); // -3..-9
      final b = _random.nextInt(10) + 2; // 2..11
      final answer = a + b;
      return _buildQuestion(
        id: '5e_rel_$index',
        grade: SchoolGrade.cinquieme,
        categoryFr: '5e • Nombres Relatifs',
        categoryEn: 'Grade 7 • Signed Numbers',
        promptFr: 'Calcule la somme de relatifs :',
        promptEn: 'Calculate the sum:',
        mathExpression: '($a) + $b = ?',
        correctAnswer: '$answer',
        distractors: ['${-answer}', '${a - b}', '${answer + 2}'],
        hintFr: 'Pense à un ascenseur qui part de l\'étage $a et monte de $b !',
        hintEn: 'Think of an elevator starting at floor $a and going up $b!',
        explanationFr: '($a) + $b = $answer.',
        explanationEn: '($a) + $b = $answer.',
      );
    } else if (type == 1) {
      final xVal = _random.nextInt(5) + 2; // 2..6
      final coeff = _random.nextInt(3) + 2; // 2..4
      final constant = _random.nextInt(6) + 1; // 1..6
      final answer = coeff * xVal + constant;
      return _buildQuestion(
        id: '5e_lit_$index',
        grade: SchoolGrade.cinquieme,
        categoryFr: '5e • Calcul Littéral',
        categoryEn: 'Grade 7 • Algebraic Expressions',
        promptFr: 'Pour x = $xVal, quelle est la valeur de :',
        promptEn: 'For x = $xVal, what is the value of:',
        mathExpression: '$coeff x + $constant = ?',
        correctAnswer: '$answer',
        distractors: [
          '${answer + coeff}',
          '${coeff + xVal + constant}',
          '${answer - 2}',
        ],
        hintFr: 'Remplace x par $xVal et multiplie par $coeff !',
        hintEn: 'Replace x with $xVal and multiply by $coeff!',
        explanationFr:
            '$coeff × $xVal + $constant = ${coeff * xVal} + $constant = $answer.',
        explanationEn:
            '$coeff × $xVal + $constant = ${coeff * xVal} + $constant = $answer.',
      );
    } else {
      final a1 = _random.nextInt(3) + 1; // 1..3
      final answerNum = a1 * 2 + 1;
      return _buildQuestion(
        id: '5e_frac_$index',
        grade: SchoolGrade.cinquieme,
        categoryFr: '5e • Fractions',
        categoryEn: 'Grade 7 • Fractions',
        promptFr: 'Calcule la somme de fractions :',
        promptEn: 'Calculate the fraction sum:',
        mathExpression: '$a1/2 + 1/4 = ?',
        correctAnswer: '$answerNum/4',
        distractors: ['${a1 + 1}/6', '${answerNum + 1}/4', '$a1/4'],
        hintFr: 'Mets au même dénominateur : 2 × 2 = 4 !',
        hintEn: 'Put under the common denominator: 2 × 2 = 4!',
        explanationFr:
            '$a1/2 = ${a1 * 2}/4, donc ${a1 * 2}/4 + 1/4 = $answerNum/4.',
        explanationEn:
            '$a1/2 = ${a1 * 2}/4, so ${a1 * 2}/4 + 1/4 = $answerNum/4.',
      );
    }
  }

  // --- 4e (Grade 8) ---
  MathQuestion _generate4eQuestion(int index) {
    final type = index % 3;
    if (type == 0) {
      final a = -(_random.nextInt(6) + 2); // -2..-7
      final b = -(_random.nextInt(5) + 2); // -2..-6
      final answer = a * b; // positif !
      return _buildQuestion(
        id: '4e_multrel_$index',
        grade: SchoolGrade.quatrieme,
        categoryFr: '4e • Produit de Relatifs',
        categoryEn: 'Grade 8 • Multiplying Signed Numbers',
        promptFr: 'Calcule le produit :',
        promptEn: 'Calculate the product:',
        mathExpression: '($a) × ($b) = ?',
        correctAnswer: '$answer',
        distractors: ['${-answer}', '${a + b}', '${answer + 4}'],
        hintFr: 'Le produit de deux nombres négatifs est TOUJOURS positif ! 🐾',
        hintEn: 'The product of two negative numbers is ALWAYS positive! 🐾',
        explanationFr: 'Moins par moins donne plus : ($a) × ($b) = +$answer.',
        explanationEn:
            'Negative times negative gives positive: ($a) × ($b) = +$answer.',
      );
    } else if (type == 1) {
      final p = _random.nextInt(4) + 2; // 2..5
      final answer = pow(10, p).toInt();
      return _buildQuestion(
        id: '4e_pow10_$index',
        grade: SchoolGrade.quatrieme,
        categoryFr: '4e • Puissances de 10',
        categoryEn: 'Grade 8 • Powers of 10',
        promptFr: 'Quelle est la valeur de :',
        promptEn: 'What is the value of:',
        mathExpression: '10^$p = ?',
        correctAnswer: '$answer',
        distractors: ['${10 * p}', '${answer ~/ 10}', '${answer * 10}'],
        hintFr: '10 puissance $p s\'écrit avec un 1 suivi de $p zéros !',
        hintEn: '10 to the power of $p is a 1 followed by $p zeros!',
        explanationFr: '10^$p = $answer ($p zéros).',
        explanationEn: '10^$p = $answer ($p zeros).',
      );
    } else {
      final a = _random.nextInt(6) + 3; // 3..8
      final x = _random.nextInt(7) + 2; // 2..8
      final b = a * x;
      return _buildQuestion(
        id: '4e_eq_$index',
        grade: SchoolGrade.quatrieme,
        categoryFr: '4e • Équations simples',
        categoryEn: 'Grade 8 • Linear Equations',
        promptFr: 'Résous l\'équation :',
        promptEn: 'Solve the equation:',
        mathExpression: '$a x = $b → x = ?',
        correctAnswer: '$x',
        distractors: ['${x + 1}', '${max(1, x - 1)}', '${b - a}'],
        hintFr: 'Divise les deux côtés par $a !',
        hintEn: 'Divide both sides by $a!',
        explanationFr: 'x = $b ÷ $a = $x.',
        explanationEn: 'x = $b ÷ $a = $x.',
      );
    }
  }

  // --- 3e (Grade 9) ---
  MathQuestion _generate3eQuestion(int index) {
    final type = index % 3;
    if (type == 0) {
      final squares = [
        {'val': 36, 'root': 6},
        {'val': 49, 'root': 7},
        {'val': 64, 'root': 8},
        {'val': 81, 'root': 9},
        {'val': 100, 'root': 10},
        {'val': 121, 'root': 11},
      ];
      final item = squares[_random.nextInt(squares.length)];
      final root = item['root']!;
      final val = item['val']!;
      return _buildQuestion(
        id: '3e_sqrt_$index',
        grade: SchoolGrade.troisieme,
        categoryFr: '3e • Racines Carrées',
        categoryEn: 'Grade 9 • Square Roots',
        promptFr: 'Calcule la racine carrée :',
        promptEn: 'Calculate the square root:',
        mathExpression: '√$val = ?',
        correctAnswer: '$root',
        distractors: ['${root + 1}', '${root - 1}', '${val ~/ 2}'],
        hintFr: 'Quel nombre multiplié par lui-même donne $val ?',
        hintEn: 'Which number multiplied by itself gives $val?',
        explanationFr: '$root × $root = $val, donc √$val = $root.',
        explanationEn: '$root × $root = $val, so √$val = $root.',
      );
    } else if (type == 1) {
      final a = _random.nextInt(3) + 2; // 2..4
      final x = _random.nextInt(5) + 2; // 2..6
      final c = _random.nextInt(8) + 1; // 1..8
      final rhs = a * x + c;
      return _buildQuestion(
        id: '3e_eq2_$index',
        grade: SchoolGrade.troisieme,
        categoryFr: '3e • Équations du 1er Degré',
        categoryEn: 'Grade 9 • Linear Equations',
        promptFr: 'Résous l\'équation pour trouver x :',
        promptEn: 'Solve for x:',
        mathExpression: '$a x + $c = $rhs → x = ?',
        correctAnswer: '$x',
        distractors: ['${x + 2}', '${max(1, x - 1)}', '${x + 1}'],
        hintFr: 'Isole d\'abord $a x en soustrayant $c, puis divise par $a !',
        hintEn: 'First subtract $c, then divide by $a!',
        explanationFr:
            '$a x = $rhs - $c = ${a * x}, donc x = ${a * x} ÷ $a = $x.',
        explanationEn:
            '$a x = $rhs - $c = ${a * x}, so x = ${a * x} ÷ $a = $x.',
      );
    } else {
      final k = _random.nextInt(3) + 2; // 2..4
      final c = _random.nextInt(5) + 2; // 2..6
      final kc = k * c;
      return _buildQuestion(
        id: '3e_dev_$index',
        grade: SchoolGrade.troisieme,
        categoryFr: '3e • Développement',
        categoryEn: 'Grade 9 • Expansion',
        promptFr: 'Développe l\'expression :',
        promptEn: 'Expand the expression:',
        mathExpression: '$k (x + $c) = ?',
        correctAnswer: '$k x + $kc',
        distractors: ['$k x + $c', 'x + $kc', '${k + 1} x + $kc'],
        hintFr: 'Distribue $k sur chaque terme entre parenthèses !',
        hintEn: 'Distribute $k over each term in the parentheses!',
        explanationFr: '$k × x + $k × $c = $k x + $kc.',
        explanationEn: '$k × x + $k × $c = $k x + $kc.',
      );
    }
  }

  /// Assemble et mélange les options pour garantir 4 choix distincts
  MathQuestion _buildQuestion({
    required String id,
    required SchoolGrade grade,
    MathDomain? domain,
    required String categoryFr,
    required String categoryEn,
    required String promptFr,
    required String promptEn,
    required String mathExpression,
    required String correctAnswer,
    required List<String> distractors,
    required String hintFr,
    required String hintEn,
    required String explanationFr,
    required String explanationEn,
  }) {
    final cleanDistractors = <String>[];
    for (final d in distractors) {
      if (d != correctAnswer && !cleanDistractors.contains(d)) {
        cleanDistractors.add(d);
      }
    }

    // Si on manque de distracteurs uniques, on en fabrique
    int fallbackCounter = 1;
    while (cleanDistractors.length < 3) {
      final candidate = '${cleanDistractors.length + fallbackCounter}';
      if (candidate != correctAnswer && !cleanDistractors.contains(candidate)) {
        cleanDistractors.add(candidate);
      }
      fallbackCounter++;
    }

    final allOptions = [
      correctAnswer,
      cleanDistractors[0],
      cleanDistractors[1],
      cleanDistractors[2],
    ];
    allOptions.shuffle(_random);
    final correctIndex = allOptions.indexOf(correctAnswer);

    final effectiveDomain = domain ?? _inferDomain(categoryFr);

    return MathQuestion(
      id: id,
      grade: grade,
      domain: effectiveDomain,
      categoryFr: categoryFr,
      categoryEn: categoryEn,
      promptFr: promptFr,
      promptEn: promptEn,
      mathExpression: mathExpression,
      options: allOptions,
      correctIndex: correctIndex,
      hintFr: hintFr,
      hintEn: hintEn,
      explanationFr: explanationFr,
      explanationEn: explanationEn,
    );
  }

  static MathDomain _inferDomain(String categoryFr) {
    final lower = categoryFr.toLowerCase();
    if (lower.contains('géométrie') ||
        lower.contains('aires') ||
        lower.contains('espace')) {
      return MathDomain.geometry;
    }
    if (lower.contains('périmètre') || lower.contains('mesure')) {
      return MathDomain.measures;
    }
    if (lower.contains('complément') ||
        lower.contains('partage') ||
        lower.contains('pourcentage') ||
        lower.contains('moitié')) {
      return MathDomain.problems;
    }
    return MathDomain.numbers;
  }
}
