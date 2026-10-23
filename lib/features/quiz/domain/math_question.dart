import '../../profile/domain/school_grade.dart';

/// Les 4 domaines officiels du programme de mathématiques (Éducation Nationale).
enum MathDomain {
  numbers,
  geometry,
  measures,
  problems;

  String get key => name;
}

/// Représente une question mathématique dans le quiz de MathPup.
/// Bilingue (Français/Anglais), adaptée au niveau scolaire de l'enfant (CP à 3e).
class MathQuestion {
  final String id;
  final SchoolGrade grade;
  final MathDomain domain;
  final String categoryFr;
  final String categoryEn;
  final String promptFr;
  final String promptEn;
  final String mathExpression;
  final List<String> options;
  final int correctIndex;
  final String hintFr;
  final String hintEn;
  final String explanationFr;
  final String explanationEn;

  const MathQuestion({
    required this.id,
    required this.grade,
    this.domain = MathDomain.numbers,
    required this.categoryFr,
    required this.categoryEn,
    required this.promptFr,
    required this.promptEn,
    required this.mathExpression,
    required this.options,
    required this.correctIndex,
    required this.hintFr,
    required this.hintEn,
    required this.explanationFr,
    required this.explanationEn,
  }) : assert(
         options.length == 4,
         'Une question doit comporter exactement 4 choix.',
       ),
       assert(
         correctIndex >= 0 && correctIndex < 4,
         'correctIndex doit être compris entre 0 et 3.',
       );

  /// Libellé de la catégorie selon la langue
  String getCategory(bool isFrench) => isFrench ? categoryFr : categoryEn;

  /// Énoncé de la question selon la langue
  String getPrompt(bool isFrench) => isFrench ? promptFr : promptEn;

  /// Indice / astuce de Pi selon la langue
  String getHint(bool isFrench) => isFrench ? hintFr : hintEn;

  /// Explication pédagogique en cas d'erreur
  String getExplanation(bool isFrench) =>
      isFrench ? explanationFr : explanationEn;

  /// Texte de la bonne réponse
  String get correctAnswer => options[correctIndex];

  /// Vérifie si l'indice proposé est la bonne réponse
  bool isAnswerCorrect(int index) => index == correctIndex;
}
