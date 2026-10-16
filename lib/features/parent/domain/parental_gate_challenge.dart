import 'dart:math';

/// Défi arithmétique formulé en toutes lettres (Français et Anglais)
/// destiné à vérifier la présence d'un adulte (Parental Gate anti-contournement).
/// Empêche les enfants en bas âge ou non lecteurs d'accéder aux paramètres parents.
class ParentalGateChallenge {
  final String questionFr;
  final String questionEn;
  final int expectedAnswer;

  const ParentalGateChallenge({
    required this.questionFr,
    required this.questionEn,
    required this.expectedAnswer,
  });

  /// Libellé du problème selon la langue sélectionnée
  String getQuestion(bool isFrench) => isFrench ? questionFr : questionEn;

  /// Vérifie si la réponse saisie par l'adulte en chiffres correspond au résultat attendu.
  bool verify(String input) {
    final cleaned = input.trim();
    if (cleaned.isEmpty) return false;
    final parsed = int.tryParse(cleaned);
    return parsed == expectedAnswer;
  }
}

/// Convertisseur de nombres entiers (0 à 100) en lettres françaises et anglaises.
class NumberWordsConverter {
  static const Map<int, String> _unitsFr = {
    0: 'zéro',
    1: 'un',
    2: 'deux',
    3: 'trois',
    4: 'quatre',
    5: 'cinq',
    6: 'six',
    7: 'sept',
    8: 'huit',
    9: 'neuf',
    10: 'dix',
    11: 'onze',
    12: 'douze',
    13: 'treize',
    14: 'quatorze',
    15: 'quinze',
    16: 'seize',
    17: 'dix-sept',
    18: 'dix-huit',
    19: 'dix-neuf',
    20: 'vingt',
    30: 'trente',
    40: 'quarante',
    50: 'cinquante',
    60: 'soixante',
    70: 'soixante-dix',
    80: 'quatre-vingts',
    90: 'quatre-vingt-dix',
    100: 'cent',
  };

  static const Map<int, String> _unitsEn = {
    0: 'zero',
    1: 'one',
    2: 'two',
    3: 'three',
    4: 'four',
    5: 'five',
    6: 'six',
    7: 'seven',
    8: 'eight',
    9: 'nine',
    10: 'ten',
    11: 'eleven',
    12: 'twelve',
    13: 'thirteen',
    14: 'fourteen',
    15: 'fifteen',
    16: 'sixteen',
    17: 'seventeen',
    18: 'eighteen',
    19: 'nineteen',
    20: 'twenty',
    30: 'thirty',
    40: 'forty',
    50: 'fifty',
    60: 'sixty',
    70: 'seventy',
    80: 'eighty',
    90: 'ninety',
    100: 'one hundred',
  };

  /// Convertit un entier (0 à 100) en texte français.
  static String toFrench(int number) {
    if (number < 0) return 'moins ${toFrench(-number)}';
    if (_unitsFr.containsKey(number)) return _unitsFr[number]!;

    if (number < 70) {
      final tens = (number ~/ 10) * 10;
      final rem = number % 10;
      if (rem == 1) return '${_unitsFr[tens]} et un';
      return '${_unitsFr[tens]}-${_unitsFr[rem]}';
    } else if (number < 80) {
      final rem = number - 60;
      if (rem == 11) return 'soixante et onze';
      return 'soixante-${_unitsFr[rem]}';
    } else if (number < 100) {
      final rem = number - 80;
      return 'quatre-vingt-${_unitsFr[rem]}';
    }

    return '$number';
  }

  /// Convertit un entier (0 à 100) en texte anglais.
  static String toEnglish(int number) {
    if (number < 0) return 'minus ${toEnglish(-number)}';
    if (_unitsEn.containsKey(number)) return _unitsEn[number]!;

    if (number < 100) {
      final tens = (number ~/ 10) * 10;
      final rem = number % 10;
      return '${_unitsEn[tens]}-${_unitsEn[rem]}';
    }

    return '$number';
  }
}

/// Générateur aléatoire ou déterministe de défis du Parental Gate.
class ParentalGateChallengeGenerator {
  final Random _random;

  ParentalGateChallengeGenerator([Random? random]) : _random = random ?? Random();

  /// Génère un nouveau défi mathématique textuel.
  ParentalGateChallenge generate() {
    final type = _random.nextInt(4); // 0: multiplication, 1: division, 2: addition, 3: soustraction
    switch (type) {
      case 0:
        return _generateMultiplication();
      case 1:
        return _generateDivision();
      case 2:
        return _generateAddition();
      case 3:
      default:
        return _generateSubtraction();
    }
  }

  ParentalGateChallenge _generateMultiplication() {
    final a = _random.nextInt(4) + 6; // 6..9
    final b = _random.nextInt(4) + 6; // 6..9
    final expected = a * b;

    final aFr = _capitalize(NumberWordsConverter.toFrench(a));
    final bFr = NumberWordsConverter.toFrench(b);
    final aEn = _capitalize(NumberWordsConverter.toEnglish(a));
    final bEn = NumberWordsConverter.toEnglish(b);

    return ParentalGateChallenge(
      questionFr: '$aFr multiplié par $bFr',
      questionEn: '$aEn multiplied by $bEn',
      expectedAnswer: expected,
    );
  }

  ParentalGateChallenge _generateDivision() {
    final divisor = _random.nextInt(4) + 4; // 4..7
    final quotient = _random.nextInt(5) + 4; // 4..8
    final dividend = divisor * quotient;

    final divFr = _capitalize(NumberWordsConverter.toFrench(dividend));
    final dFr = NumberWordsConverter.toFrench(divisor);
    final divEn = _capitalize(NumberWordsConverter.toEnglish(dividend));
    final dEn = NumberWordsConverter.toEnglish(divisor);

    return ParentalGateChallenge(
      questionFr: '$divFr divisé par $dFr',
      questionEn: '$divEn divided by $dEn',
      expectedAnswer: quotient,
    );
  }

  ParentalGateChallenge _generateAddition() {
    final a = _random.nextInt(25) + 18; // 18..42
    final b = _random.nextInt(25) + 15; // 15..39
    final expected = a + b;

    final aFr = _capitalize(NumberWordsConverter.toFrench(a));
    final bFr = NumberWordsConverter.toFrench(b);
    final aEn = _capitalize(NumberWordsConverter.toEnglish(a));
    final bEn = NumberWordsConverter.toEnglish(b);

    return ParentalGateChallenge(
      questionFr: '$aFr plus $bFr',
      questionEn: '$aEn plus $bEn',
      expectedAnswer: expected,
    );
  }

  ParentalGateChallenge _generateSubtraction() {
    final a = _random.nextInt(30) + 45; // 45..74
    final b = _random.nextInt(20) + 12; // 12..31
    final expected = a - b;

    final aFr = _capitalize(NumberWordsConverter.toFrench(a));
    final bFr = NumberWordsConverter.toFrench(b);
    final aEn = _capitalize(NumberWordsConverter.toEnglish(a));
    final bEn = NumberWordsConverter.toEnglish(b);

    return ParentalGateChallenge(
      questionFr: '$aFr moins $bFr',
      questionEn: '$aEn minus $bEn',
      expectedAnswer: expected,
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

/// Gestionnaire d'état de verrouillage temporaire en cas de tentatives infructueuses répétées.
/// Protège contre le bruteforce (3 essais autorisés puis verrouillage de 30 secondes).
class ParentalGateLockoutManager {
  static const int maxAttempts = 3;
  static const int defaultLockoutSeconds = 30;

  final int lockoutDurationSeconds;
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  ParentalGateLockoutManager({this.lockoutDurationSeconds = defaultLockoutSeconds});

  int get failedAttempts => _failedAttempts;

  bool get isLocked {
    if (_lockedUntil == null) return false;
    return DateTime.now().isBefore(_lockedUntil!);
  }

  int get remainingSeconds {
    if (!isLocked || _lockedUntil == null) return 0;
    final diff = _lockedUntil!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  int get remainingAttempts => (maxAttempts - _failedAttempts).clamp(0, maxAttempts);

  /// Enregistre une tentative erronée.
  /// Renvoie `true` si le système vient de passer en état verrouillé.
  bool recordFailure() {
    _failedAttempts++;
    if (_failedAttempts >= maxAttempts) {
      _lockedUntil = DateTime.now().add(Duration(seconds: lockoutDurationSeconds));
      return true;
    }
    return false;
  }

  /// Réinitialise les tentatives après un succès ou l'expiration du verrou.
  void reset() {
    _failedAttempts = 0;
    _lockedUntil = null;
  }
}
