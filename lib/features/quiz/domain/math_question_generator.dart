import 'dart:math';

import '../../profile/domain/school_grade.dart';
import 'math_question.dart';

/// Générateur de questions mathématiques par niveau scolaire (CP à 3e / Grades 1 to 9).
/// Déterministe lorsque fourni avec un `Random` avec graine fixe (idéal pour les tests).
/// Conforme aux 4 domaines du socle officiel : Nombres & Calculs, Géométrie, Grandeurs & Mesures, Problèmes.
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

  // ==========================================
  // CP (Grade 1 - Cycle 2)
  // ==========================================
  MathQuestion _generateCpQuestion(int index) {
    final type = index % 6;
    if (type == 0) {
      final a = _random.nextInt(6) + 1; // 1..6
      final b = _random.nextInt(4) + 1; // 1..4
      final answer = a + b;
      return _buildQuestion(
        id: 'cp_add_$index',
        grade: SchoolGrade.cp,
        domain: MathDomain.numbers,
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
        domain: MathDomain.numbers,
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
    } else if (type == 2) {
      final a = _random.nextInt(8) + 1; // 1..8
      final answer = 10 - a;
      return _buildQuestion(
        id: 'cp_comp_$index',
        grade: SchoolGrade.cp,
        domain: MathDomain.numbers,
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
    } else if (type == 3) {
      final a = _random.nextInt(5) + 1; // 1..5
      final answer = a * 2;
      return _buildQuestion(
        id: 'cp_double_$index',
        grade: SchoolGrade.cp,
        domain: MathDomain.numbers,
        categoryFr: 'CP • Les Doubles',
        categoryEn: 'Grade 1 • Doubles',
        promptFr: 'Quel est le double de :',
        promptEn: 'What is double of:',
        mathExpression: 'Double de $a = ?',
        correctAnswer: '$answer',
        distractors: [
          '${answer + 1}',
          '${max(1, answer - 2)}',
          '${a + 1}',
        ],
        hintFr: 'Le double de $a, c\'est $a + $a ! 🐾',
        hintEn: 'Double of $a is $a + $a! 🐾',
        explanationFr: 'Le double de $a est $a + $a = $answer.',
        explanationEn: 'Double of $a is $a + $a = $answer.',
      );
    } else if (type == 4) {
      final biscuits = _random.nextInt(5) + 2; // 2..6
      final extra = _random.nextInt(4) + 1; // 1..4
      final total = biscuits + extra;
      return _buildQuestion(
        id: 'cp_prob_$index',
        grade: SchoolGrade.cp,
        domain: MathDomain.problems,
        categoryFr: 'CP • Problème de Pi',
        categoryEn: 'Grade 1 • Pi\'s Problem',
        promptFr: 'Pi a $biscuits biscuits dans sa gamelle. Tu lui en donnes $extra de plus. Combien en a-t-il ?',
        promptEn: 'Pi has $biscuits treats in his bowl. You give him $extra more. How many does he have?',
        mathExpression: '$biscuits + $extra = ? biscuits',
        correctAnswer: '$total',
        distractors: [
          '${total + 1}',
          '${max(1, total - 1)}',
          '${total + 2}',
        ],
        hintFr: 'Additionne les biscuits avec Pi ! 🐾',
        hintEn: 'Add the treats together with Pi! 🐾',
        explanationFr: '$biscuits + $extra = $total biscuits en tout.',
        explanationEn: '$biscuits + $extra = $total treats in total.',
      );
    } else {
      final shapes = [
        {'nameFr': 'triangle', 'nameEn': 'triangle', 'sides': '3'},
        {'nameFr': 'carré', 'nameEn': 'square', 'sides': '4'},
        {'nameFr': 'rectangle', 'nameEn': 'rectangle', 'sides': '4'},
      ];
      final item = shapes[_random.nextInt(shapes.length)];
      final sides = item['sides'] as String;
      return _buildQuestion(
        id: 'cp_geom_$index',
        grade: SchoolGrade.cp,
        domain: MathDomain.geometry,
        categoryFr: 'CP • Formes et Géométrie',
        categoryEn: 'Grade 1 • Shapes & Geometry',
        promptFr: 'Combien de côtés possède un ${item['nameFr']} ?',
        promptEn: 'How many sides does a ${item['nameEn']} have?',
        mathExpression: '${item['nameFr']} → ? côtés',
        correctAnswer: sides,
        distractors: ['2', '5', sides == '3' ? '4' : '3'],
        hintFr: 'Trace la forme avec ton doigt pour compter les côtés ! 🐾',
        hintEn: 'Trace the shape with your finger to count the sides! 🐾',
        explanationFr: 'Un ${item['nameFr']} possède exactement $sides côtés.',
        explanationEn: 'A ${item['nameEn']} has exactly $sides sides.',
      );
    }
  }

  // ==========================================
  // CE1 (Grade 2 - Cycle 2)
  // ==========================================
  MathQuestion _generateCe1Question(int index) {
    final type = index % 6;
    if (type == 0) {
      final a = (_random.nextInt(4) + 2) * 10 + _random.nextInt(8); // 20..57
      final b = (_random.nextInt(3) + 1) * 10 + _random.nextInt(5); // 10..34
      final answer = a + b;
      return _buildQuestion(
        id: 'ce1_add_$index',
        grade: SchoolGrade.ce1,
        domain: MathDomain.numbers,
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
        domain: MathDomain.numbers,
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
    } else if (type == 2) {
      final a = (_random.nextInt(6) + 3) * 2; // 6..16
      final answer = a ~/ 2;
      return _buildQuestion(
        id: 'ce1_half_$index',
        grade: SchoolGrade.ce1,
        domain: MathDomain.numbers,
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
    } else if (type == 3) {
      final tens = _random.nextInt(4) + 3; // 3..6
      final units = _random.nextInt(7) + 2; // 2..8
      final a = tens * 10 + units;
      final subTens = _random.nextInt(tens - 1) + 1;
      final subUnits = _random.nextInt(units);
      final b = subTens * 10 + subUnits;
      final answer = a - b;
      return _buildQuestion(
        id: 'ce1_sub_$index',
        grade: SchoolGrade.ce1,
        domain: MathDomain.numbers,
        categoryFr: 'CE1 • Soustractions à 2 chiffres',
        categoryEn: 'Grade 2 • 2-Digit Subtraction',
        promptFr: 'Calcule la différence :',
        promptEn: 'Calculate the difference:',
        mathExpression: '$a - $b = ?',
        correctAnswer: '$answer',
        distractors: ['${answer + 10}', '${max(1, answer - 1)}', '${answer + 2}'],
        hintFr: 'Soustrais les unités avec les unités, puis les dizaines !',
        hintEn: 'Subtract units first, then tens!',
        explanationFr: '$a - $b = $answer.',
        explanationEn: '$a - $b = $answer.',
      );
    } else if (type == 4) {
      final dist1 = (_random.nextInt(4) + 1) * 10; // 10..40
      final dist2 = (_random.nextInt(3) + 1) * 5; // 5..15
      final total = dist1 + dist2;
      return _buildQuestion(
        id: 'ce1_prob_$index',
        grade: SchoolGrade.ce1,
        domain: MathDomain.measures,
        categoryFr: 'CE1 • Problème de Course',
        categoryEn: 'Grade 2 • Distance Problem',
        promptFr: 'Pi court $dist1 mètres pour attraper sa balle, puis $dist2 mètres pour revenir. Quelle distance a-t-il courue ?',
        promptEn: 'Pi runs $dist1 meters to catch his ball, then $dist2 meters back. How far did he run in total?',
        mathExpression: '$dist1 m + $dist2 m = ? m',
        correctAnswer: '$total m',
        distractors: ['${total + 10} m', '${max(5, total - 5)} m', '$dist1 m'],
        hintFr: 'Additionne les deux distances parcourues par Pi ! 🐾',
        hintEn: 'Add both distances ran by Pi! 🐾',
        explanationFr: '$dist1 m + $dist2 m = $total mètres au total.',
        explanationEn: '$dist1 m + $dist2 m = $total meters in total.',
      );
    } else {
      final shapes = [
        {'nameFr': 'triangle', 'nameEn': 'triangle', 'sides': 3},
        {'nameFr': 'carré', 'nameEn': 'square', 'sides': 4},
        {'nameFr': 'rectangle', 'nameEn': 'rectangle', 'sides': 4},
        {'nameFr': 'pentagone', 'nameEn': 'pentagon', 'sides': 5},
      ];
      final item = shapes[_random.nextInt(shapes.length)];
      final sides = item['sides'] as int;
      return _buildQuestion(
        id: 'ce1_geom_$index',
        grade: SchoolGrade.ce1,
        domain: MathDomain.geometry,
        categoryFr: 'CE1 • Formes Géométriques',
        categoryEn: 'Grade 2 • Geometric Shapes',
        promptFr: 'Combien de côtés possède un ${item['nameFr']} ?',
        promptEn: 'How many sides does a ${item['nameEn']} have?',
        mathExpression: '${item['nameFr']} → ? côtés',
        correctAnswer: '$sides',
        distractors: [
          '${sides + 1}',
          '${max(2, sides - 1)}',
          '${sides + 2}',
        ],
        hintFr: 'Dessine la forme dans ta tête pour compter ses côtés !',
        hintEn: 'Picture the shape in your mind and count its sides!',
        explanationFr: 'Un ${item['nameFr']} possède exactement $sides côtés.',
        explanationEn: 'A ${item['nameEn']} has exactly $sides sides.',
      );
    }
  }

  // ==========================================
  // CE2 (Grade 3 - Cycle 2)
  // ==========================================
  MathQuestion _generateCe2Question(int index) {
    final type = index % 6;
    if (type == 0) {
      final a = _random.nextInt(6) + 4; // 4..9
      final b = _random.nextInt(6) + 4; // 4..9
      final answer = a * b;
      return _buildQuestion(
        id: 'ce2_mult_$index',
        grade: SchoolGrade.ce2,
        domain: MathDomain.numbers,
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
        domain: MathDomain.numbers,
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
    } else if (type == 2) {
      final c = _random.nextInt(7) + 2; // 2..8
      final d = _random.nextInt(8) + 1; // 1..8
      final u = _random.nextInt(9) + 1; // 1..9
      final fullNumber = c * 100 + d * 10 + u;
      return _buildQuestion(
        id: 'ce2_decomp_$index',
        grade: SchoolGrade.ce2,
        domain: MathDomain.numbers,
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
    } else if (type == 3) {
      final isMeter = _random.nextBool();
      if (isMeter) {
        final m = _random.nextInt(7) + 2; // 2..8
        final cm = m * 100;
        return _buildQuestion(
          id: 'ce2_conv_$index',
          grade: SchoolGrade.ce2,
          domain: MathDomain.measures,
          categoryFr: 'CE2 • Mesures & Longueurs',
          categoryEn: 'Grade 3 • Length Conversions',
          promptFr: 'Convertis en centimètres :',
          promptEn: 'Convert to centimeters:',
          mathExpression: '$m m = ? cm',
          correctAnswer: '$cm cm',
          distractors: ['${m * 10} cm', '${m * 1000} cm', '${cm + 10} cm'],
          hintFr: 'Rappelle-toi : 1 mètre = 100 centimètres !',
          hintEn: 'Remember: 1 meter = 100 centimeters!',
          explanationFr: '$m m = $m × 100 cm = $cm cm.',
          explanationEn: '$m m = $m × 100 cm = $cm cm.',
        );
      } else {
        final kg = _random.nextInt(5) + 2; // 2..6
        final g = kg * 1000;
        return _buildQuestion(
          id: 'ce2_conv_$index',
          grade: SchoolGrade.ce2,
          domain: MathDomain.measures,
          categoryFr: 'CE2 • Masses & Conversions',
          categoryEn: 'Grade 3 • Mass Conversions',
          promptFr: 'Convertis en grammes :',
          promptEn: 'Convert to grams:',
          mathExpression: '$kg kg = ? g',
          correctAnswer: '$g g',
          distractors: ['${kg * 100} g', '${kg * 10} g', '${g + 100} g'],
          hintFr: '1 kilogramme équivaut à 1 000 grammes !',
          hintEn: '1 kilogram equals 1,000 grams!',
          explanationFr: '$kg kg = $kg × 1 000 g = $g g.',
          explanationEn: '$kg kg = $kg × 1,000 g = $g g.',
        );
      }
    } else if (type == 4) {
      final meals = _random.nextInt(2) + 2; // 2 ou 3
      final kibbles = (_random.nextInt(4) + 4) * 10; // 40, 50, 60, 70
      final total = meals * kibbles;
      return _buildQuestion(
        id: 'ce2_prob_$index',
        grade: SchoolGrade.ce2,
        domain: MathDomain.problems,
        categoryFr: 'CE2 • Problème de Pi',
        categoryEn: 'Grade 3 • Pi\'s Problem',
        promptFr: 'Pi mange $kibbles croquettes par repas et fait $meals repas par jour. Combien de croquettes mange-t-il par jour ?',
        promptEn: 'Pi eats $kibbles kibbles per meal and has $meals meals a day. How many kibbles does he eat per day?',
        mathExpression: '$meals × $kibbles = ? croquettes',
        correctAnswer: '$total',
        distractors: [
          '${total + kibbles}',
          '${max(20, total - kibbles)}',
          '${total + 10}',
        ],
        hintFr: 'Multiplie le nombre de repas par le nombre de croquettes ! 🐾',
        hintEn: 'Multiply the number of meals by the kibbles! 🐾',
        explanationFr: '$meals repas × $kibbles croquettes = $total croquettes par jour.',
        explanationEn: '$meals meals × $kibbles kibbles = $total kibbles per day.',
      );
    } else {
      return _buildQuestion(
        id: 'ce2_geom_$index',
        grade: SchoolGrade.ce2,
        domain: MathDomain.geometry,
        categoryFr: 'CE2 • Angles & Polygones',
        categoryEn: 'Grade 3 • Right Angles',
        promptFr: 'Combien d\'angles droits possède un rectangle ?',
        promptEn: 'How many right angles does a rectangle have?',
        mathExpression: 'Rectangle → ? angles droits',
        correctAnswer: '4',
        distractors: ['2', '3', '0'],
        hintFr: 'Ses 4 coins sont parfaitement droits comme ceux d\'un livre !',
        hintEn: 'All 4 corners are right angles like a notebook!',
        explanationFr: 'Un rectangle possède exactement 4 angles droits.',
        explanationEn: 'A rectangle has exactly 4 right angles.',
      );
    }
  }

  // ==========================================
  // CM1 (Grade 4 - Cycle 3)
  // ==========================================
  MathQuestion _generateCm1Question(int index) {
    final type = index % 6;
    if (type == 0) {
      final unit = _random.nextInt(8) + 1; // 1..8
      final tenth = _random.nextInt(8) + 1; // 1..8
      final answer = '$unit,$tenth';
      return _buildQuestion(
        id: 'cm1_fracdec_$index',
        grade: SchoolGrade.cm1,
        domain: MathDomain.numbers,
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
      final a = (_random.nextInt(4) + 1) * 1.5; // 1.5, 3.0, 4.5
      final b = 0.5 + _random.nextInt(3); // 0.5, 1.5, 2.5
      final sum = ((a + b) * 10).round() / 10;
      final aStr = a.toStringAsFixed(1).replaceAll('.', ',');
      final bStr = b.toStringAsFixed(1).replaceAll('.', ',');
      final sumStr = sum.toStringAsFixed(1).replaceAll('.', ',');
      final wrong1 = (sum + 0.5).toStringAsFixed(1).replaceAll('.', ',');
      final wrong2 = max(0.1, sum - 0.5).toStringAsFixed(1).replaceAll('.', ',');
      final wrong3 = (sum + 1.0).toStringAsFixed(1).replaceAll('.', ',');
      return _buildQuestion(
        id: 'cm1_adddec_$index',
        grade: SchoolGrade.cm1,
        domain: MathDomain.numbers,
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
    } else if (type == 2) {
      final fractions = [
        {'expr': '1/2', 'ans': '0,5', 'wrongs': ['0,2', '1,2', '0,05']},
        {'expr': '1/4', 'ans': '0,25', 'wrongs': ['0,4', '0,5', '0,14']},
        {'expr': '3/4', 'ans': '0,75', 'wrongs': ['0,34', '0,5', '0,43']},
        {'expr': '1/10', 'ans': '0,1', 'wrongs': ['0,01', '1,0', '0,100']},
      ];
      final item = fractions[_random.nextInt(fractions.length)];
      return _buildQuestion(
        id: 'cm1_fracusu_$index',
        grade: SchoolGrade.cm1,
        domain: MathDomain.numbers,
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
    } else if (type == 3) {
      final aVal = (_random.nextInt(5) + 5) * 1.0; // 5.0..9.0
      final sub = (_random.nextInt(4) + 1) * 0.5; // 0.5..2.0
      final diff = aVal - sub;
      final aStr = aVal.toStringAsFixed(1).replaceAll('.', ',');
      final subStr = sub.toStringAsFixed(1).replaceAll('.', ',');
      final diffStr = diff.toStringAsFixed(1).replaceAll('.', ',');
      return _buildQuestion(
        id: 'cm1_subdec_$index',
        grade: SchoolGrade.cm1,
        domain: MathDomain.numbers,
        categoryFr: 'CM1 • Soustraction Décimale',
        categoryEn: 'Grade 4 • Decimal Subtraction',
        promptFr: 'Calcule la différence :',
        promptEn: 'Calculate the difference:',
        mathExpression: '$aStr - $subStr = ?',
        correctAnswer: diffStr,
        distractors: [
          (diff + 1.0).toStringAsFixed(1).replaceAll('.', ','),
          max(0.5, diff - 0.5).toStringAsFixed(1).replaceAll('.', ','),
          (aVal + sub).toStringAsFixed(1).replaceAll('.', ','),
        ],
        hintFr: 'Pense à rendre la monnaie sur $aStr € !',
        hintEn: 'Think of getting change from $aStr €!',
        explanationFr: '$aStr - $subStr = $diffStr.',
        explanationEn: '$aStr - $subStr = $diffStr.',
      );
    } else if (type == 4) {
      final l = _random.nextInt(5) + 5; // 5..9
      final w = _random.nextInt(4) + 2; // 2..5
      final perim = 2 * (l + w);
      return _buildQuestion(
        id: 'cm1_perim_$index',
        grade: SchoolGrade.cm1,
        domain: MathDomain.measures,
        categoryFr: 'CM1 • Périmètre du Rectangle',
        categoryEn: 'Grade 4 • Rectangle Perimeter',
        promptFr: 'Calcule le périmètre du rectangle :',
        promptEn: 'Calculate the perimeter of the rectangle:',
        mathExpression: 'L = $l cm, l = $w cm → P = ?',
        correctAnswer: '$perim cm',
        distractors: [
          '${l * w} cm',
          '${perim + 2} cm',
          '${l + w} cm',
        ],
        hintFr: 'Périmètre = 2 × (Longueur + largeur) !',
        hintEn: 'Perimeter = 2 × (Length + width)!',
        explanationFr: 'P = 2 × ($l + $w) = 2 × ${l + w} = $perim cm.',
        explanationEn: 'P = 2 × ($l + $w) = 2 × ${l + w} = $perim cm.',
      );
    } else {
      final parts = _random.nextInt(3) + 3; // 3, 4, 5
      final weightPerPart = (_random.nextInt(4) + 2) * 50; // 100..250
      final total = parts * weightPerPart;
      return _buildQuestion(
        id: 'cm1_prob_$index',
        grade: SchoolGrade.cm1,
        domain: MathDomain.problems,
        categoryFr: 'CM1 • Partage avec Pi',
        categoryEn: 'Grade 4 • Sharing Problem',
        promptFr: 'Pi partage équitablement un paquet de $total g de friandises en $parts sachets. Quel est le poids de chaque sachet ?',
        promptEn: 'Pi splits a $total g bag of treats into $parts equal pouches. What is the weight of each pouch?',
        mathExpression: '$total g ÷ $parts = ? g',
        correctAnswer: '$weightPerPart g',
        distractors: [
          '${weightPerPart + 50} g',
          '${max(25, weightPerPart - 50)} g',
          '${parts * 10} g',
        ],
        hintFr: 'Divise la masse totale par le nombre de sachets ! 🐾',
        hintEn: 'Divide total weight by number of pouches! 🐾',
        explanationFr: '$total g ÷ $parts = $weightPerPart g par sachet.',
        explanationEn: '$total g ÷ $parts = $weightPerPart g per pouch.',
      );
    }
  }

  // ==========================================
  // CM2 (Grade 5 - Cycle 3)
  // ==========================================
  MathQuestion _generateCm2Question(int index) {
    final type = index % 6;
    if (type == 0) {
      final percent = [50, 25, 10][_random.nextInt(3)];
      final base = percent == 25 ? 40 : (percent == 50 ? 60 : 80);
      final ansVal = (base * percent) ~/ 100;
      return _buildQuestion(
        id: 'cm2_percent_$index',
        grade: SchoolGrade.cm2,
        domain: MathDomain.numbers,
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
      final num = (_random.nextInt(80) + 12) / 10; // 1.2 .. 9.1
      final mult10 = (num * 10).round();
      final numStr = num.toStringAsFixed(1).replaceAll('.', ',');
      return _buildQuestion(
        id: 'cm2_mult10_$index',
        grade: SchoolGrade.cm2,
        domain: MathDomain.numbers,
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
    } else if (type == 2) {
      final side = _random.nextInt(7) + 3; // 3..9
      final perimeter = side * 4;
      return _buildQuestion(
        id: 'cm2_perim_$index',
        grade: SchoolGrade.cm2,
        domain: MathDomain.measures,
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
    } else if (type == 3) {
      final l = _random.nextInt(6) + 5; // 5..10
      final w = _random.nextInt(4) + 3; // 3..6
      final area = l * w;
      return _buildQuestion(
        id: 'cm2_area_$index',
        grade: SchoolGrade.cm2,
        domain: MathDomain.geometry,
        categoryFr: 'CM2 • Aire du Rectangle',
        categoryEn: 'Grade 5 • Rectangle Area',
        promptFr: 'Calcule l\'aire du rectangle :',
        promptEn: 'Calculate the area of the rectangle:',
        mathExpression: 'L = $l cm, l = $w cm → Aire = ?',
        correctAnswer: '$area cm²',
        distractors: [
          '${2 * (l + w)} cm²',
          '${area + 5} cm²',
          '${l * 2 + w * 2} cm²',
        ],
        hintFr: 'Aire d\'un rectangle = Longueur × largeur !',
        hintEn: 'Area of a rectangle = Length × width!',
        explanationFr: 'Aire = $l × $w = $area cm².',
        explanationEn: 'Area = $l × $w = $area cm².',
      );
    } else if (type == 4) {
      final denom = [3, 4, 5][_random.nextInt(3)];
      final whole = _random.nextInt(2) + 1; // 1 ou 2
      final remainder = _random.nextInt(denom - 1) + 1; // 1..denom-1
      final num = whole * denom + remainder;
      return _buildQuestion(
        id: 'cm2_fracent_$index',
        grade: SchoolGrade.cm2,
        domain: MathDomain.numbers,
        categoryFr: 'CM2 • Fractions et Entiers',
        categoryEn: 'Grade 5 • Fractions & Whole Numbers',
        promptFr: 'Décompose la fraction sous la forme d\'un entier et d\'une fraction :',
        promptEn: 'Break down the fraction into an integer and a fraction:',
        mathExpression: '$num/$denom = ? + $remainder/$denom',
        correctAnswer: '$whole',
        distractors: ['${whole + 1}', '${whole + 2}', '${max(0, whole - 1)}'],
        hintFr: 'Combien de fois $denom entre en entier dans $num ?',
        hintEn: 'How many whole times does $denom fit into $num?',
        explanationFr: '$num/$denom = ($whole × $denom + $remainder)/$denom = $whole + $remainder/$denom.',
        explanationEn: '$num/$denom = ($whole × $denom + $remainder)/$denom = $whole + $remainder/$denom.',
      );
    } else {
      final unitCost = _random.nextInt(3) + 3; // 3, 4, 5 os
      final q1 = 2;
      final cost1 = q1 * unitCost;
      final q2 = _random.nextInt(3) + 4; // 4, 5, 6
      final cost2 = q2 * unitCost;
      return _buildQuestion(
        id: 'cm2_prob_$index',
        grade: SchoolGrade.cm2,
        domain: MathDomain.problems,
        categoryFr: 'CM2 • Proportionnalité de Pi',
        categoryEn: 'Grade 5 • Proportions with Pi',
        promptFr: 'Si $q1 balles pour Pi coûtent $cost1 os dorés, combien coûtent $q2 balles ?',
        promptEn: 'If $q1 balls for Pi cost $cost1 golden bones, how much do $q2 balls cost?',
        mathExpression: '$q1 balles = $cost1 os → $q2 balles = ? os',
        correctAnswer: '$cost2 os',
        distractors: [
          '${cost2 + unitCost} os',
          '${cost2 - unitCost} os',
          '${cost1 * 2} os',
        ],
        hintFr: 'Calcule d\'abord le prix d\'une seule balle ($cost1 ÷ $q1 = $unitCost os) ! 🐾',
        hintEn: 'First find the price of 1 ball ($cost1 ÷ $q1 = $unitCost bones)! 🐾',
        explanationFr: '1 balle = $unitCost os, donc $q2 balles = $q2 × $unitCost = $cost2 os dorés.',
        explanationEn: '1 ball = $unitCost bones, so $q2 balls = $q2 × $unitCost = $cost2 golden bones.',
      );
    }
  }

  // ==========================================
  // 6e (Grade 6 - Cycle 3)
  // ==========================================
  MathQuestion _generate6eQuestion(int index) {
    final type = index % 6;
    if (type == 0) {
      // 1. Priorités opératoires avec décimaux et soustraction/multiplication
      final base = (_random.nextInt(4) + 4) * 10; // 40, 50, 60, 70
      final mult = _random.nextInt(3) + 3; // 3, 4, 5
      final dec = [2.5, 3.5, 4.5][_random.nextInt(3)];
      final product = (mult * dec).round();
      final correct = base - product;
      final wrongPriority = ((base - mult) * dec).round();
      return _buildQuestion(
        id: '6e_prio_$index',
        grade: SchoolGrade.sixieme,
        domain: MathDomain.numbers,
        categoryFr: '6e • Priorités et Décimaux',
        categoryEn: 'Grade 6 • Order of Operations & Decimals',
        promptFr: 'Calcule en respectant les priorités opératoires :',
        promptEn: 'Calculate following operation order:',
        mathExpression:
            '$base - $mult × ${dec.toString().replaceAll('.', ',')} = ?',
        correctAnswer: '$correct',
        distractors: [
          '$wrongPriority',
          '${correct + 10}',
          '${max(2, correct - 10)}',
        ],
        hintFr: 'La multiplication s\'effectue TOUJOURS avant la soustraction !',
        hintEn: 'Multiplication ALWAYS takes precedence over subtraction!',
        explanationFr:
            'On calcule d\'abord $mult × ${dec.toString().replaceAll('.', ',')} = $product, puis $base - $product = $correct.',
        explanationEn:
            'First calculate $mult × $dec = $product, then $base - $product = $correct.',
      );
    } else if (type == 1) {
      // 2. Périmètre du cercle (Formule 6e P = 2 * pi * r avec pi ≈ 3,14)
      final rList = [5, 10, 20];
      final r = rList[_random.nextInt(rList.length)];
      final perim = (2 * 3.14 * r).toStringAsFixed(1).replaceAll('.', ',');
      final perimDouble = 2 * 3.14 * r;
      return _buildQuestion(
        id: '6e_circle_$index',
        grade: SchoolGrade.sixieme,
        domain: MathDomain.geometry,
        categoryFr: '6e • Périmètre du Cercle',
        categoryEn: 'Grade 6 • Circle Circumference',
        promptFr:
            'Un cercle a un rayon de $r cm (avec π ≈ 3,14). Quel est son périmètre ?',
        promptEn:
            'A circle has radius $r cm (with π ≈ 3.14). What is its circumference?',
        mathExpression: 'P = 2 × π × r → P = 2 × 3,14 × $r = ? cm',
        correctAnswer: '$perim cm',
        distractors: [
          '${(3.14 * r).toStringAsFixed(1).replaceAll('.', ',')} cm',
          '${(perimDouble + 6.28).toStringAsFixed(1).replaceAll('.', ',')} cm',
          '${(r * 4)} cm',
        ],
        hintFr: 'La formule du périmètre d\'un cercle est 2 × π × r !',
        hintEn: 'The circumference formula is 2 × π × r!',
        explanationFr: 'P = 2 × 3,14 × $r = $perim cm.',
        explanationEn: 'P = 2 × 3.14 × $r = ${perim.replaceAll(',', '.')} cm.',
      );
    } else if (type == 2) {
      // 3. Fraction d'une quantité (Grand classique 6e)
      final fractions = [
        {'num': 3, 'den': 4, 'total': 80, 'unit': 'kg'},
        {'num': 2, 'den': 5, 'total': 150, 'unit': '€'},
        {'num': 5, 'den': 6, 'total': 42, 'unit': 'm'},
        {'num': 7, 'den': 10, 'total': 200, 'unit': 'L'},
      ];
      final f = fractions[_random.nextInt(fractions.length)];
      final num = f['num'] as int;
      final den = f['den'] as int;
      final total = f['total'] as int;
      final unit = f['unit'] as String;
      final ans = (total ~/ den) * num;
      return _buildQuestion(
        id: '6e_fracqty_$index',
        grade: SchoolGrade.sixieme,
        domain: MathDomain.numbers,
        categoryFr: '6e • Fraction d\'une Quantité',
        categoryEn: 'Grade 6 • Fraction of a Quantity',
        promptFr: 'Calcule la fraction de la quantité :',
        promptEn: 'Calculate the fraction of the quantity:',
        mathExpression: '$num/$den de $total $unit = ? $unit',
        correctAnswer: '$ans $unit',
        distractors: [
          '${(total ~/ den)} $unit',
          '${ans + den} $unit',
          '${max(2, ans - den * 2)} $unit',
        ],
        hintFr:
            'Divise la quantité par le dénominateur ($den), puis multiplie par le numérateur ($num) !',
        hintEn:
            'Divide quantity by denominator ($den), then multiply by numerator ($num)!',
        explanationFr:
            '($total ÷ $den) × $num = ${total ~/ den} × $num = $ans $unit.',
        explanationEn:
            '($total ÷ $den) × $num = ${total ~/ den} × $num = $ans $unit.',
      );
    } else if (type == 3) {
      // 4. Calcul mental avec décimaux (×0,1 ou ÷0,5)
      final isDivHalf = _random.nextBool();
      if (isDivHalf) {
        final val = (_random.nextInt(6) + 4) * 4; // 16, 20, 24, 28, 32...
        final ans = val * 2;
        return _buildQuestion(
          id: '6e_divhalf_$index',
          grade: SchoolGrade.sixieme,
          domain: MathDomain.numbers,
          categoryFr: '6e • Division par 0,5',
          categoryEn: 'Grade 6 • Division by 0.5',
          promptFr: 'Astuce de calcul mental collège :',
          promptEn: 'Mental math shortcut:',
          mathExpression: '$val ÷ 0,5 = ?',
          correctAnswer: '$ans',
          distractors: [
            '${val ~/ 2}',
            '${val + 5}',
            '${ans + 4}',
          ],
          hintFr:
              'Diviser par 0,5 revient exactement à MULTIPLIER par 2 ! 🐾',
          hintEn:
              'Dividing by 0.5 is exactly the same as multiplying by 2! 🐾',
          explanationFr:
              'Diviser par 0,5 (un demi), c\'est multiplier par 2 : $val × 2 = $ans.',
          explanationEn:
              'Dividing by 0.5 is multiplying by 2: $val × 2 = $ans.',
        );
      } else {
        final intPart = _random.nextInt(50) + 20; // 20..69
        final decPart = _random.nextInt(9) + 1; // 1..9
        final original = '$intPart,$decPart';
        final ans = '${intPart ~/ 10},${intPart % 10}$decPart';
        final wrong1 = '${intPart * 10},$decPart';
        final wrong2 = '0,$intPart$decPart';
        final wrong3 = '${intPart + 1},$decPart';
        return _buildQuestion(
          id: '6e_mult01_$index',
          grade: SchoolGrade.sixieme,
          domain: MathDomain.numbers,
          categoryFr: '6e • Multiplication par 0,1',
          categoryEn: 'Grade 6 • Multiply by 0.1',
          promptFr: 'Règle de déplacement de la virgule :',
          promptEn: 'Decimal point shift rule:',
          mathExpression: '$original × 0,1 = ?',
          correctAnswer: ans,
          distractors: [wrong1, wrong2, wrong3],
          hintFr:
              'Multiplier par 0,1 décale la virgule d\'un rang vers la gauche !',
          hintEn:
              'Multiplying by 0.1 shifts the decimal point one place to the left!',
          explanationFr: '$original × 0,1 = $ans (on divise par 10).',
          explanationEn:
              '${original.replaceAll(',', '.')} × 0.1 = ${ans.replaceAll(',', '.')}.',
        );
      }
    } else if (type == 4) {
      // 5. Grandeurs & Mesures : Conversions de volumes / capacités et durées
      final isDuration = _random.nextBool();
      if (isDuration) {
        const startH = 14;
        const startM = 45;
        const durH = 1;
        const durM = 35;
        // 14h45 + 1h35 = 16h20
        const totalM = startM + durM; // 80
        const endH = startH + durH + (totalM ~/ 60); // 16
        const endM = totalM % 60; // 20
        return _buildQuestion(
          id: '6e_dur_$index',
          grade: SchoolGrade.sixieme,
          domain: MathDomain.measures,
          categoryFr: '6e • Calculs de Durée',
          categoryEn: 'Grade 6 • Duration Calculations',
          promptFr:
              'Un train part à 14h45 et roule pendant 1h35. À quelle heure arrive-t-il ?',
          promptEn:
              'A train departs at 2:45 PM and travels for 1h35. When does it arrive?',
          mathExpression: '14h45 + 1h35 = ?',
          correctAnswer: '${endH}h$endM',
          distractors: [
            '${endH}h$totalM',
            '${endH - 1}h$endM',
            '${endH + 1}h10',
          ],
          hintFr:
              '60 minutes forment 1 heure pleine ! 14h45 + 15 min = 15h00...',
          hintEn:
              '60 minutes make 1 full hour! 2:45 + 15 min = 3:00...',
          explanationFr:
              '14h45 + 1h = 15h45. Puis 15h45 + 35 min = 16h20.',
          explanationEn:
              '2:45 + 1h = 3:45. Then 3:45 + 35 min = 4:20.',
        );
      } else {
        final liters = [1.5, 2.5, 3.5][_random.nextInt(3)];
        final ml = (liters * 1000).toInt();
        final lStr = liters.toString().replaceAll('.', ',');
        return _buildQuestion(
          id: '6e_cap_$index',
          grade: SchoolGrade.sixieme,
          domain: MathDomain.measures,
          categoryFr: '6e • Conversions de Capacités',
          categoryEn: 'Grade 6 • Capacity Conversions',
          promptFr: 'Convertis le volume en millilitres :',
          promptEn: 'Convert capacity to milliliters:',
          mathExpression: '$lStr L = ? mL',
          correctAnswer: '$ml mL',
          distractors: [
            '${(liters * 100).toInt()} mL',
            '${(liters * 10).toInt()} mL',
            '${ml + 500} mL',
          ],
          hintFr: '1 Litre équivaut à 1 000 millilitres !',
          hintEn: '1 Liter equals 1,000 milliliters!',
          explanationFr: '$lStr L × 1 000 = $ml mL.',
          explanationEn: '$liters L × 1,000 = $ml mL.',
        );
      }
    } else {
      // 6. Problèmes & Proportionnalité : Remises et proportions réelles
      final isPriceDiscount = _random.nextBool();
      if (isPriceDiscount) {
        final origPrice = (_random.nextInt(3) + 3) * 20; // 60, 80, 100
        final newPrice = origPrice - (origPrice ~/ 4);
        final realDiscount = origPrice ~/ 4;
        return _buildQuestion(
          id: '6e_discount_$index',
          grade: SchoolGrade.sixieme,
          domain: MathDomain.problems,
          categoryFr: '6e • Remise et Pourcentage',
          categoryEn: 'Grade 6 • Discount & Percentage',
          promptFr:
              'Un sac de croquettes coûte $origPrice €. Il bénéficie de 25% de remise. Quel est le nouveau prix ?',
          promptEn:
              'A pet food bag costs $origPrice €. With a 25% discount, what is the new price?',
          mathExpression: '$origPrice € - 25% = ? €',
          correctAnswer: '$newPrice €',
          distractors: [
            '$realDiscount €',
            '${newPrice + 10} €',
            '${origPrice - 25} €',
          ],
          hintFr:
              '25% correspond au quart du prix ($origPrice ÷ 4), qu\'on soustrait ensuite !',
          hintEn:
              '25% is one quarter of the price ($origPrice ÷ 4), subtract it from the total!',
          explanationFr:
              'Remise = $origPrice ÷ 4 = $realDiscount €. Nouveau prix = $origPrice - $realDiscount = $newPrice €.',
          explanationEn:
              'Discount = $origPrice ÷ 4 = $realDiscount €. Final price = $origPrice - $realDiscount = $newPrice €.',
        );
      } else {
        const puppies = 4;
        const grams = 320;
        const targetPuppies = 6;
        const totalGrams = (grams ~/ puppies) * targetPuppies; // 80 * 6 = 480
        return _buildQuestion(
          id: '6e_prop_puppies_$index',
          grade: SchoolGrade.sixieme,
          domain: MathDomain.problems,
          categoryFr: '6e • Proportionnalité Directe',
          categoryEn: 'Grade 6 • Direct Proportion',
          promptFr:
              'Pour $puppies chiots, il faut $grams g de nourriture par jour. Combien faut-il pour $targetPuppies chiots ?',
          promptEn:
              'For $puppies puppies, $grams g of food is needed. How much is needed for $targetPuppies puppies?',
          mathExpression: '$grams g ÷ $puppies × $targetPuppies = ? g',
          correctAnswer: '$totalGrams g',
          distractors: [
            '${totalGrams - 80} g',
            '${totalGrams + 80} g',
            '${grams * 2} g',
          ],
          hintFr:
              'Calcule d\'abord la ration pour 1 seul chiot ($grams ÷ $puppies), puis multiplie par $targetPuppies !',
          hintEn:
              'Find ration for 1 puppy first ($grams ÷ $puppies), then multiply by $targetPuppies!',
          explanationFr:
              '1 chiot = $grams ÷ $puppies = ${grams ~/ puppies} g. Donc $targetPuppies chiots = ${grams ~/ puppies} × $targetPuppies = $totalGrams g.',
          explanationEn:
              '1 puppy = $grams ÷ $puppies = ${grams ~/ puppies} g. So $targetPuppies puppies = ${grams ~/ puppies} × $targetPuppies = $totalGrams g.',
        );
      }
    }
  }

  // ==========================================
  // 5e (Grade 7 - Cycle 4)
  // ==========================================
  MathQuestion _generate5eQuestion(int index) {
    final type = index % 6;
    if (type == 0) {
      final a = -(_random.nextInt(7) + 3); // -3..-9
      final b = _random.nextInt(10) + 2; // 2..11
      final answer = a + b;
      return _buildQuestion(
        id: '5e_rel_$index',
        grade: SchoolGrade.cinquieme,
        domain: MathDomain.numbers,
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
        domain: MathDomain.numbers,
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
    } else if (type == 2) {
      final a1 = _random.nextInt(3) + 1; // 1..3
      final answerNum = a1 * 2 + 1;
      return _buildQuestion(
        id: '5e_frac_$index',
        grade: SchoolGrade.cinquieme,
        domain: MathDomain.numbers,
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
    } else if (type == 3) {
      final a = _random.nextInt(8) + 2; // 2..9
      final b = -(_random.nextInt(6) + 2); // -2..-7
      final answer = a - b; // a - (-|b|) = a + |b|
      return _buildQuestion(
        id: '5e_subrel_$index',
        grade: SchoolGrade.cinquieme,
        domain: MathDomain.numbers,
        categoryFr: '5e • Soustraction de Relatifs',
        categoryEn: 'Grade 7 • Subtracting Signed Numbers',
        promptFr: 'Calcule la différence de relatifs :',
        promptEn: 'Calculate the difference:',
        mathExpression: '$a - ($b) = ?',
        correctAnswer: '$answer',
        distractors: ['${a + b}', '${-answer}', '${answer - 2}'],
        hintFr: 'Soustraire un nombre négatif revient à AJOUTER son opposé : $a - ($b) = $a + ${-b} ! 🐾',
        hintEn: 'Subtracting a negative number means ADDING its opposite: $a - ($b) = $a + ${-b}! 🐾',
        explanationFr: '$a - ($b) = $a + ${-b} = $answer.',
        explanationEn: '$a - ($b) = $a + ${-b} = $answer.',
      );
    } else if (type == 4) {
      final n1 = _random.nextInt(6) + 10; // 10..15
      final n2 = _random.nextInt(6) + 12; // 12..17
      final rem = (n1 + n2) % 3;
      final n3 = rem == 0 ? 12 : (rem == 1 ? 14 : 13);
      final avg = (n1 + n2 + n3) ~/ 3;
      return _buildQuestion(
        id: '5e_stat_$index',
        grade: SchoolGrade.cinquieme,
        domain: MathDomain.problems,
        categoryFr: '5e • Statistiques & Moyennes',
        categoryEn: 'Grade 7 • Averages',
        promptFr: 'Calcule la moyenne des trois notes suivantes :',
        promptEn: 'Calculate the average of these three scores:',
        mathExpression: 'Notes : $n1, $n2, $n3 → Moyenne = ?',
        correctAnswer: '$avg',
        distractors: ['${avg + 1}', '${max(1, avg - 1)}', '${avg + 2}'],
        hintFr: 'Additionne les 3 notes et divise la somme par 3 !',
        hintEn: 'Add the 3 scores and divide the sum by 3!',
        explanationFr: '($n1 + $n2 + $n3) ÷ 3 = ${n1 + n2 + n3} ÷ 3 = $avg.',
        explanationEn: '($n1 + $n2 + $n3) ÷ 3 = ${n1 + n2 + n3} ÷ 3 = $avg.',
      );
    } else {
      final base = (_random.nextInt(4) + 3) * 2; // 6, 8, 10, 12
      final height = _random.nextInt(5) + 3; // 3..7
      final area = (base * height) ~/ 2;
      return _buildQuestion(
        id: '5e_triarea_$index',
        grade: SchoolGrade.cinquieme,
        domain: MathDomain.geometry,
        categoryFr: '5e • Aire du Triangle',
        categoryEn: 'Grade 7 • Triangle Area',
        promptFr: 'Calcule l\'aire du triangle :',
        promptEn: 'Calculate the area of the triangle:',
        mathExpression: 'Base = $base cm, Hauteur = $height cm → Aire = ?',
        correctAnswer: '$area cm²',
        distractors: ['${base * height} cm²', '${area + 4} cm²', '${max(5, area - 4)} cm²'],
        hintFr: 'Aire d\'un triangle = (Base × Hauteur) ÷ 2 !',
        hintEn: 'Area of a triangle = (Base × Height) ÷ 2!',
        explanationFr: 'Aire = ($base × $height) ÷ 2 = ${base * height} ÷ 2 = $area cm².',
        explanationEn: 'Area = ($base × $height) ÷ 2 = ${base * height} ÷ 2 = $area cm².',
      );
    }
  }

  // ==========================================
  // 4e (Grade 8 - Cycle 4)
  // ==========================================
  MathQuestion _generate4eQuestion(int index) {
    final type = index % 6;
    if (type == 0) {
      final a = -(_random.nextInt(6) + 2); // -2..-7
      final b = -(_random.nextInt(5) + 2); // -2..-6
      final answer = a * b; // positif !
      return _buildQuestion(
        id: '4e_multrel_$index',
        grade: SchoolGrade.quatrieme,
        domain: MathDomain.numbers,
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
        domain: MathDomain.numbers,
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
    } else if (type == 2) {
      final a = _random.nextInt(6) + 3; // 3..8
      final x = _random.nextInt(7) + 2; // 2..8
      final b = a * x;
      return _buildQuestion(
        id: '4e_eq_$index',
        grade: SchoolGrade.quatrieme,
        domain: MathDomain.numbers,
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
    } else if (type == 3) {
      final pyth = [
        {'a': 3, 'b': 4, 'c': 5},
        {'a': 6, 'b': 8, 'c': 10},
        {'a': 5, 'b': 12, 'c': 13},
        {'a': 8, 'b': 15, 'c': 17},
      ];
      final item = pyth[_random.nextInt(pyth.length)];
      final a = item['a']!;
      final b = item['b']!;
      final c = item['c']!;
      return _buildQuestion(
        id: '4e_pyth_$index',
        grade: SchoolGrade.quatrieme,
        domain: MathDomain.geometry,
        categoryFr: '4e • Théorème de Pythagore',
        categoryEn: 'Grade 8 • Pythagorean Theorem',
        promptFr: 'Dans un triangle rectangle en A, AB = $a cm et AC = $b cm. Quelle est la longueur de l\'hypoténuse BC ?',
        promptEn: 'In a right triangle at A, AB = $a cm and AC = $b cm. What is the length of hypotenuse BC?',
        mathExpression: 'BC² = $a² + $b² → BC = ?',
        correctAnswer: '$c cm',
        distractors: ['${a + b} cm', '${c + 2} cm', '${max(1, c - 2)} cm'],
        hintFr: 'Théorème de Pythagore : BC² = AB² + AC² ! 🐾',
        hintEn: 'Pythagorean Theorem: BC² = AB² + AC²! 🐾',
        explanationFr: 'BC² = $a² + $b² = ${a * a} + ${b * b} = ${c * c}, donc BC = √${c * c} = $c cm.',
        explanationEn: 'BC² = $a² + $b² = ${a * a} + ${b * b} = ${c * c}, so BC = √${c * c} = $c cm.',
      );
    } else if (type == 4) {
      final n1 = _random.nextInt(3) + 2; // 2..4
      final d1 = 5;
      final n2 = _random.nextInt(3) + 1; // 1..3
      final d2 = 3;
      final numAns = n1 * n2;
      final denAns = d1 * d2;
      return _buildQuestion(
        id: '4e_multfrac_$index',
        grade: SchoolGrade.quatrieme,
        domain: MathDomain.numbers,
        categoryFr: '4e • Produit de Fractions',
        categoryEn: 'Grade 8 • Multiplying Fractions',
        promptFr: 'Calcule le produit des deux fractions :',
        promptEn: 'Calculate the product of both fractions:',
        mathExpression: '$n1/$d1 × $n2/$d2 = ?',
        correctAnswer: '$numAns/$denAns',
        distractors: [
          '${n1 + n2}/${d1 + d2}',
          '${numAns + 1}/$denAns',
          '$numAns/${d1 + d2}',
        ],
        hintFr: 'Multiplie les numérateurs entre eux et les dénominateurs entre eux !',
        hintEn: 'Multiply numerators together and denominators together!',
        explanationFr: '($n1 × $n2) ÷ ($d1 × $d2) = $numAns/$denAns.',
        explanationEn: '($n1 × $n2) ÷ ($d1 × $d2) = $numAns/$denAns.',
      );
    } else {
      final speed = (_random.nextInt(5) + 6) * 10; // 60, 70, 80, 90, 100
      final time = _random.nextInt(3) + 2; // 2..4 h
      final dist = speed * time;
      return _buildQuestion(
        id: '4e_speed_$index',
        grade: SchoolGrade.quatrieme,
        domain: MathDomain.problems,
        categoryFr: '4e • Vitesse & Grandeurs',
        categoryEn: 'Grade 8 • Speed & Distance',
        promptFr: 'Un train parcourt $dist km en $time heures à vitesse constante. Quelle est sa vitesse moyenne ?',
        promptEn: 'A train travels $dist km in $time hours at constant speed. What is its average speed?',
        mathExpression: 'v = $dist km ÷ $time h = ?',
        correctAnswer: '$speed km/h',
        distractors: ['${speed + 10} km/h', '${speed - 10} km/h', '${dist - time} km/h'],
        hintFr: 'Vitesse moyenne = Distance ÷ Temps ! 🐾',
        hintEn: 'Average speed = Distance ÷ Time! 🐾',
        explanationFr: 'v = $dist ÷ $time = $speed km/h.',
        explanationEn: 'v = $dist ÷ $time = $speed km/h.',
      );
    }
  }

  // ==========================================
  // 3e (Grade 9 - Cycle 4 - Brevet)
  // ==========================================
  MathQuestion _generate3eQuestion(int index) {
    final type = index % 6;
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
        domain: MathDomain.numbers,
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
        domain: MathDomain.numbers,
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
    } else if (type == 2) {
      final k = _random.nextInt(3) + 2; // 2..4
      final c = _random.nextInt(5) + 2; // 2..6
      final kc = k * c;
      return _buildQuestion(
        id: '3e_dev_$index',
        grade: SchoolGrade.troisieme,
        domain: MathDomain.numbers,
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
    } else if (type == 3) {
      final am = _random.nextInt(3) + 2; // 2..4
      final factor = _random.nextInt(2) + 2; // 2 ou 3
      final ab = am * factor;
      final an = _random.nextInt(3) + 3; // 3..5
      final ac = an * factor;
      return _buildQuestion(
        id: '3e_thales_$index',
        grade: SchoolGrade.troisieme,
        domain: MathDomain.geometry,
        categoryFr: '3e • Théorème de Thalès',
        categoryEn: 'Grade 9 • Thales Theorem',
        promptFr: 'Les droites (MN) et (BC) sont parallèles. Avec AM = $am cm, AB = $ab cm et AN = $an cm, calcule AC :',
        promptEn: 'Lines (MN) and (BC) are parallel. With AM = $am cm, AB = $ab cm, and AN = $an cm, calculate AC:',
        mathExpression: 'AM/AB = AN/AC → $am/$ab = $an/AC → AC = ?',
        correctAnswer: '$ac cm',
        distractors: ['${ac + 2} cm', '${max(1, ac - factor)} cm', '${an + factor} cm'],
        hintFr: 'D\'après le théorème de Thalès : AM/AB = AN/AC ! 🐾',
        hintEn: 'According to Thales theorem: AM/AB = AN/AC! 🐾',
        explanationFr: 'Le coefficient d\'agrandissement est $ab ÷ $am = $factor, donc AC = $an × $factor = $ac cm.',
        explanationEn: 'The scale factor is $ab ÷ $am = $factor, so AC = $an × $factor = $ac cm.',
      );
    } else if (type == 4) {
      final a = _random.nextInt(3) + 2; // 2..4
      final b = _random.nextInt(5) + 1; // 1..5
      final inputVal = _random.nextInt(4) + 2; // 2..5
      final image = a * inputVal + b;
      return _buildQuestion(
        id: '3e_func_$index',
        grade: SchoolGrade.troisieme,
        domain: MathDomain.numbers,
        categoryFr: '3e • Notions de Fonctions',
        categoryEn: 'Grade 9 • Linear Functions',
        promptFr: 'Soit la fonction f(x) = $a x + $b. Quelle est l\'image de $inputVal par f ?',
        promptEn: 'Let f(x) = $a x + $b. What is the image of $inputVal by f?',
        mathExpression: 'f($inputVal) = ?',
        correctAnswer: '$image',
        distractors: ['${image + a}', '${a * inputVal}', '${image - 2}'],
        hintFr: 'Remplace x par $inputVal dans la formule de f(x) !',
        hintEn: 'Substitute x with $inputVal in the formula for f(x)!',
        explanationFr: 'f($inputVal) = $a × $inputVal + $b = ${a * inputVal} + $b = $image.',
        explanationEn: 'f($inputVal) = $a × $inputVal + $b = ${a * inputVal} + $b = $image.',
      );
    } else {
      return _buildQuestion(
        id: '3e_proba_$index',
        grade: SchoolGrade.troisieme,
        domain: MathDomain.problems,
        categoryFr: '3e • Probabilités',
        categoryEn: 'Grade 9 • Probability',
        promptFr: 'On lance un dé équilibré à 6 faces (numérotées de 1 à 6). Quelle est la probabilité d\'obtenir un nombre pair (2, 4 ou 6) ?',
        promptEn: 'A fair 6-sided die is rolled. What is the probability of rolling an even number (2, 4, or 6)?',
        mathExpression: 'P(pair) = ?',
        correctAnswer: '1/2',
        distractors: ['1/6', '1/3', '2/3'],
        hintFr: 'Il y a 3 nombres pairs sur 6 issues possibles : 3/6 ! 🐾',
        hintEn: 'There are 3 even numbers out of 6 possible outcomes: 3/6! 🐾',
        explanationFr: 'Il y a 3 faces paires sur 6, donc P = 3/6 = 1/2.',
        explanationEn: 'There are 3 even faces out of 6, so P = 3/6 = 1/2.',
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
        lower.contains('angle') ||
        lower.contains('pythagore') ||
        lower.contains('forme') ||
        lower.contains('espace')) {
      return MathDomain.geometry;
    }
    if (lower.contains('périmètre') ||
        lower.contains('mesure') ||
        lower.contains('longueur') ||
        lower.contains('masse') ||
        lower.contains('vitesse') ||
        lower.contains('conversion')) {
      return MathDomain.measures;
    }
    if (lower.contains('problème') ||
        lower.contains('partage') ||
        lower.contains('statistique') ||
        lower.contains('probabilité') ||
        lower.contains('proportionnalité')) {
      return MathDomain.problems;
    }
    return MathDomain.numbers;
  }
}
