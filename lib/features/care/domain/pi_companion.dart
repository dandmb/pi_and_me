import 'dart:convert';
import 'play_environment.dart';

/// Modèle représentant l'état du chiot Pi, ses jauges vitales,
/// son inventaire de friandises/jouets, son niveau de propreté et sa position dans l'aire de jeu.
class PiCompanion {
  final double hunger; // 0.0 .. 1.0 (Faim)
  final double joy; // 0.0 .. 1.0 (Joie)
  final double energy; // 0.0 .. 1.0 (Énergie)
  final double cleanliness; // 0.0 .. 1.0 (Propreté)
  final int dirtCount; // 0 .. 4 (Taches de boue/saleté visibles après le jeu)
  final int croquettes; // Friandises gagnées via le quiz
  final int balls; // Balles de jeu gagnées via le quiz
  final int bones; // Solde total d'os dorés
  final int bowlFoodCount; // 0 .. 3 (Nombre de croquettes servies dans l'assiette)
  final bool isEating; // Vrai pendant la séquence de repas (5 secondes)
  final PlayEnvironment environment;
  final double piX; // Coordonnée X de Pi (-0.8 à 0.8)
  final double piY; // Coordonnée Y de Pi (-0.6 à 0.6)
  final double initialPiX; // Position de départ avant le lancer de balle
  final double initialPiY;
  final double? activeBallX; // Position de la balle lancée sur le terrain
  final double? activeBallY;
  final String? statusMessage;
  final bool isFacingLeft;
  final bool isCarryingBall;
  final bool isSleeping;

  const PiCompanion({
    this.hunger = 0.80,
    this.joy = 0.70,
    this.energy = 0.90,
    this.cleanliness = 1.0,
    this.dirtCount = 0,
    this.croquettes = 3,
    this.balls = 2,
    this.bones = 50,
    this.bowlFoodCount = 0,
    this.isEating = false,
    this.environment = PlayEnvironment.livingRoom,
    this.piX = 0.0,
    this.piY = 0.2,
    this.initialPiX = 0.0,
    this.initialPiY = 0.2,
    this.activeBallX,
    this.activeBallY,
    this.statusMessage,
    this.isFacingLeft = false,
    this.isCarryingBall = false,
    this.isSleeping = false,
  });

  /// Crée un état par défaut joyeux et propre pour un nouvel enfant
  factory PiCompanion.initial() => const PiCompanion();

  bool get isBallActive => activeBallX != null && activeBallY != null;

  bool get isDirty => dirtCount > 0 || cleanliness < 0.75;

  /// Lance une balle de tennis sur le terrain à un endroit aléatoire.
  /// La balle reste sur le terrain SANS être décomptée tant que Pi ne l'a pas atteinte.
  PiCompanion throwBall(double targetX, double targetY, String message) {
    if (balls <= 0 || isBallActive || isSleeping) return this;
    return copyWith(
      activeBallX: targetX,
      activeBallY: targetY,
      initialPiX: piX,
      initialPiY: piY,
      isFacingLeft: targetX < piX,
      statusMessage: message,
      isCarryingBall: false,
    );
  }

  /// Déplace Pi vers une coordonnée (directive tactile de l'enfant ou course automatique).
  PiCompanion moveTo(double targetX, double targetY, {String? message}) {
    if (isSleeping) return this;
    return copyWith(
      piX: targetX,
      piY: targetY,
      isFacingLeft: targetX < piX,
      statusMessage: message ?? statusMessage,
    );
  }

  static double _roundGauge(double value) {
    return ((value.clamp(0.0, 1.0) * 100).round()) / 100.0;
  }

  /// Pi attrape la balle, revient à son point initial, la balle est décomptée,
  /// et en jouant dehors Pi attrape de la saleté (à nettoyer ensuite).
  PiCompanion collectAndReturnBall(String successMessage) {
    if (!isBallActive) return this;
    final newJoy = _roundGauge((joy + 0.25).clamp(0.0, 1.0));
    final newEnergy = _roundGauge((energy - 0.05).clamp(0.1, 1.0));
    final newHunger = _roundGauge((hunger - 0.15).clamp(0.1, 1.0));
    final newBalls = balls > 0 ? balls - 1 : 0;
    // Quand Pi court chercher la balle, il se salit nettement pour que le bain soit flagrant
    final newDirt = (dirtCount + 2).clamp(1, 4);
    final newCleanliness = _roundGauge((cleanliness - 0.35).clamp(0.0, 1.0));

    return copyWith(
      balls: newBalls,
      hunger: newHunger,
      joy: newJoy,
      energy: newEnergy,
      dirtCount: newDirt,
      cleanliness: newCleanliness,
      clearBall: true,
      piX: initialPiX,
      piY: initialPiY,
      isFacingLeft: initialPiX < piX,
      statusMessage: successMessage,
      isCarryingBall: false,
    );
  }

  /// Fait dormir Pi dans son panier douillet avec régénération d'énergie
  PiCompanion sleep(String successMessage) {
    return copyWith(
      isSleeping: true,
      energy: 1.0,
      joy: _roundGauge((joy + 0.15).clamp(0.0, 1.0)),
      statusMessage: successMessage,
      piX: 0.0,
      piY: 0.20,
    );
  }

  /// Réveille Pi
  PiCompanion wakeUp() {
    return copyWith(isSleeping: false);
  }

  /// Sert des croquettes dans l'assiette une à une (jusqu'à 3, seulement si Pi a faim et ne dort pas)
  PiCompanion serveBowl({String? message}) {
    if (hunger >= 1.0 || croquettes <= 0 || bowlFoodCount >= 3 || isSleeping) return this;
    return copyWith(
      croquettes: croquettes - 1,
      bowlFoodCount: bowlFoodCount + 1,
      statusMessage: message ?? statusMessage,
    );
  }

  /// Fait démarrer le repas : Pi se dirige vers l'assiette
  PiCompanion startEating(double targetX, double targetY, String message) {
    if (bowlFoodCount <= 0 || isSleeping) return this;
    return copyWith(
      isEating: true,
      piX: targetX,
      piY: targetY,
      isFacingLeft: true,
      statusMessage: message,
    );
  }

  /// Termine le repas de 5 secondes : jauge Faim restaurée, assiette vide,
  /// et Pi revient au centre de la pièce
  PiCompanion finishEating(String successMessage) {
    final foodGained = bowlFoodCount * 0.20 + 0.15; // 1 croquette: +35%, 2: +55%, 3: +75%
    final newHunger = _roundGauge((hunger + foodGained).clamp(0.0, 1.0));
    final newJoy = _roundGauge((joy + 0.15).clamp(0.0, 1.0));

    return copyWith(
      hunger: newHunger,
      joy: newJoy,
      bowlFoodCount: 0,
      isEating: false,
      piX: 0.0,
      piY: 0.2, // Retour au centre
      isFacingLeft: 0.0 < piX,
      statusMessage: successMessage,
    );
  }

  /// Nettoie Pi des taches accumulées pendant le jeu (bain/savon)
  PiCompanion clean(String successMessage) {
    if (isSleeping) return this;
    final newJoy = _roundGauge((joy + 0.15).clamp(0.0, 1.0));
    return copyWith(
      cleanliness: 1.0,
      dirtCount: 0,
      joy: newJoy,
      statusMessage: successMessage,
    );
  }

  /// Nourrit Pi ponctuellement (mode direct)
  PiCompanion feed(double targetX, double targetY, String successMessage) {
    if (croquettes <= 0 || hunger >= 1.0 || isSleeping) return this;
    final newHunger = _roundGauge((hunger + 0.25).clamp(0.0, 1.0));
    final newJoy = _roundGauge((joy + 0.10).clamp(0.0, 1.0));
    return copyWith(
      hunger: newHunger,
      joy: newJoy,
      croquettes: croquettes - 1,
      statusMessage: successMessage,
      isFacingLeft: targetX < piX,
      piX: targetX,
      piY: targetY,
    );
  }

  /// Fait reposer Pi (+30% Énergie)
  PiCompanion rest(double targetX, double targetY, String successMessage) {
    final newEnergy = _roundGauge((energy + 0.30).clamp(0.0, 1.0));
    return copyWith(
      energy: newEnergy,
      statusMessage: successMessage,
      isFacingLeft: targetX < piX,
      piX: targetX,
      piY: targetY,
    );
  }

  /// Change de cadre / décor de jeu avec message grammaticalement correct (affiché seulement à la 1re découverte)
  PiCompanion setEnvironment(PlayEnvironment newEnv, {required bool isFrench, bool showWelcome = true}) {
    return copyWith(
      environment: newEnv,
      statusMessage: showWelcome ? newEnv.getWelcome(isFrench) : null,
      clearStatus: !showWelcome,
    );
  }

  /// Crédite les récompenses remportées lors d'un quiz
  PiCompanion addRewards({
    required int addedBones,
    required int addedCroquettes,
    required int addedBalls,
  }) {
    return copyWith(
      bones: bones + addedBones,
      croquettes: croquettes + addedCroquettes,
      balls: balls + addedBalls,
    );
  }

  /// Débite des Os dorés pour un achat dans la boutique
  PiCompanion deductBones(int amount) {
    return copyWith(bones: (bones - amount).clamp(0, 999999));
  }

  PiCompanion copyWith({
    double? hunger,
    double? joy,
    double? energy,
    double? cleanliness,
    int? dirtCount,
    int? croquettes,
    int? balls,
    int? bones,
    int? bowlFoodCount,
    bool? isEating,
    PlayEnvironment? environment,
    double? piX,
    double? piY,
    double? initialPiX,
    double? initialPiY,
    double? activeBallX,
    double? activeBallY,
    bool clearBall = false,
    String? statusMessage,
    bool clearStatus = false,
    bool? isFacingLeft,
    bool? isCarryingBall,
    bool? isSleeping,
  }) {
    return PiCompanion(
      hunger: hunger ?? this.hunger,
      joy: joy ?? this.joy,
      energy: energy ?? this.energy,
      cleanliness: cleanliness ?? this.cleanliness,
      dirtCount: dirtCount ?? this.dirtCount,
      croquettes: croquettes ?? this.croquettes,
      balls: balls ?? this.balls,
      bones: bones ?? this.bones,
      bowlFoodCount: bowlFoodCount ?? this.bowlFoodCount,
      isEating: isEating ?? this.isEating,
      environment: environment ?? this.environment,
      piX: piX ?? this.piX,
      piY: piY ?? this.piY,
      initialPiX: initialPiX ?? this.initialPiX,
      initialPiY: initialPiY ?? this.initialPiY,
      activeBallX: clearBall ? null : (activeBallX ?? this.activeBallX),
      activeBallY: clearBall ? null : (activeBallY ?? this.activeBallY),
      statusMessage: clearStatus ? null : (statusMessage ?? this.statusMessage),
      isFacingLeft: isFacingLeft ?? this.isFacingLeft,
      isCarryingBall: isCarryingBall ?? this.isCarryingBall,
      isSleeping: isSleeping ?? this.isSleeping,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hunger': hunger,
      'joy': joy,
      'energy': energy,
      'cleanliness': cleanliness,
      'dirtCount': dirtCount,
      'croquettes': croquettes,
      'balls': balls,
      'bones': bones,
      'bowlFoodCount': bowlFoodCount,
      'environment': environment.id,
      'piX': piX,
      'piY': piY,
      'initialPiX': initialPiX,
      'initialPiY': initialPiY,
      'isFacingLeft': isFacingLeft,
      'isSleeping': isSleeping,
    };
  }

  factory PiCompanion.fromMap(Map<String, dynamic> map) {
    return PiCompanion(
      hunger: (map['hunger'] as num?)?.toDouble() ?? 0.80,
      joy: (map['joy'] as num?)?.toDouble() ?? 0.70,
      energy: (map['energy'] as num?)?.toDouble() ?? 0.90,
      cleanliness: (map['cleanliness'] as num?)?.toDouble() ?? 1.0,
      dirtCount: (map['dirtCount'] as num?)?.toInt() ?? 0,
      croquettes: (map['croquettes'] as num?)?.toInt() ?? 3,
      balls: (map['balls'] as num?)?.toInt() ?? 2,
      bones: (map['bones'] as num?)?.toInt() ?? 50,
      bowlFoodCount: (map['bowlFoodCount'] as num?)?.toInt() ?? 0,
      environment: PlayEnvironment.fromId(map['environment'] as String? ?? 'living_room'),
      piX: (map['piX'] as num?)?.toDouble() ?? 0.0,
      piY: (map['piY'] as num?)?.toDouble() ?? 0.2,
      initialPiX: (map['initialPiX'] as num?)?.toDouble() ?? 0.0,
      initialPiY: (map['initialPiY'] as num?)?.toDouble() ?? 0.2,
      isFacingLeft: map['isFacingLeft'] as bool? ?? false,
      isSleeping: map['isSleeping'] as bool? ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory PiCompanion.fromJson(String source) =>
      PiCompanion.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
