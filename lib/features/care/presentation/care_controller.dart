import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/pi_companion.dart';
import '../domain/play_environment.dart';

/// Contrôleur Riverpod pour gérer l'état du compagnon Pi, ses soins et son aire de jeu.
/// Persistance locale automatique dans SharedPreferences.
class CareController extends StateNotifier<PiCompanion> {
  static const String _storageKey = 'pi_companion_state_v1';
  static const String _visitedEnvKey = 'pi_visited_environments_v1';
  final SharedPreferences? _prefs;
  Timer? _statusTimer;
  Set<String> _visitedEnvironments = {};

  CareController({
    SharedPreferences? prefsInstance,
    PiCompanion? initialCompanion,
  }) : _prefs = prefsInstance,
       super(initialCompanion ?? PiCompanion.initial()) {
    if (initialCompanion == null) {
      _loadFromStorage();
    } else if (initialCompanion.statusMessage != null) {
      _startStatusDismissTimer();
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  /// Démarre un compte à rebours pour faire disparaître automatiquement
  /// le message de récompense après quelques secondes (max 5s, ici 4s)
  void _startStatusDismissTimer({int seconds = 4}) {
    _statusTimer?.cancel();
    _statusTimer = Timer(Duration(seconds: seconds), () {
      state = state.copyWith(clearStatus: true);
    });
  }

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await _getPrefs();
      final rawJson = prefs.getString(_storageKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        state = PiCompanion.fromJson(rawJson);
      }
      final visited = prefs.getStringList(_visitedEnvKey);
      if (visited != null) {
        _visitedEnvironments = visited.toSet();
      }
    } catch (_) {
      // Conserve l'état initial en cas d'erreur de parsing
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_storageKey, state.toJson());
    } catch (_) {
      // Ignorer silencieusement pour le mode offline
    }
  }

  Future<void> _saveVisitedEnvironments() async {
    try {
      final prefs = await _getPrefs();
      await prefs.setStringList(_visitedEnvKey, _visitedEnvironments.toList());
    } catch (_) {
      // Ignorer silencieusement
    }
  }

  /// Lance une balle de tennis sur le terrain (non décomptée tant qu'elle n'est pas rapportée)
  void throwBall(double targetX, double targetY, String message) {
    _statusTimer?.cancel();
    state = state.throwBall(targetX, targetY, message);
  }

  /// Pi attrape la balle, revient à son point initial, et la balle est alors décomptée
  void collectAndReturnBall(String successMessage) {
    state = state.collectAndReturnBall(successMessage);
    _saveToStorage();
    _startStatusDismissTimer(seconds: 4);
  }

  /// Déplace Pi librement selon le tap de l'enfant ou la course automatique
  void moveTo(double targetX, double targetY, {String? message}) {
    state = state.moveTo(targetX, targetY, message: message);
  }

  /// Nourrit Pi à l'emplacement indiqué
  void feed(double targetX, double targetY, String successMessage) {
    state = state.feed(targetX, targetY, successMessage);
    _saveToStorage();
    _startStatusDismissTimer(seconds: 4);
  }

  /// Fait se reposer Pi à l'emplacement indiqué
  void rest(double targetX, double targetY, String successMessage) {
    state = state.rest(targetX, targetY, successMessage);
    _saveToStorage();
    _startStatusDismissTimer(seconds: 4);
  }

  /// Fait dormir Pi dans son panier avec le cadre de nuit
  void sleepPi(String successMessage) {
    state = state.sleep(successMessage);
    _saveToStorage();
    _startStatusDismissTimer(seconds: 4);
  }

  /// Réveille Pi
  void wakeUpPi() {
    state = state.wakeUp();
    _saveToStorage();
  }

  /// Change de décor / environnement (affiche le message de bienvenue uniquement lors de la 1re découverte)
  void changeEnvironment(PlayEnvironment newEnv, {required bool isFrench}) {
    final isFirstVisit = !_visitedEnvironments.contains(newEnv.id);
    if (isFirstVisit) {
      _visitedEnvironments.add(newEnv.id);
      _saveVisitedEnvironments();
      state = state.setEnvironment(
        newEnv,
        isFrench: isFrench,
        showWelcome: true,
      );
      _startStatusDismissTimer(seconds: 4);
    } else {
      state = state.setEnvironment(
        newEnv,
        isFrench: isFrench,
        showWelcome: false,
      );
    }
    _saveToStorage();
  }

  /// Ajoute des récompenses remportées lors d'un quiz
  void addRewards({
    required int bones,
    required int croquettes,
    required int balls,
  }) {
    state = state.addRewards(
      addedBones: bones,
      addedCroquettes: croquettes,
      addedBalls: balls,
    );
    _saveToStorage();
  }

  /// Débite des Os dorés lors d'un achat dans la boutique
  void deductBones(int amount) {
    state = state.deductBones(amount);
    _saveToStorage();
  }

  /// Sert une croquette dans l'assiette
  void serveBowl({String? message}) {
    state = state.serveBowl(message: message);
    _saveToStorage();
    if (message != null) _startStatusDismissTimer(seconds: 4);
  }

  /// Déclenche le déplacement de Pi vers l'assiette pour manger
  void startEating(double targetX, double targetY, String message) {
    _statusTimer?.cancel();
    state = state.startEating(targetX, targetY, message);
  }

  /// Termine le repas de 5 secondes, vide l'assiette, restaure la jauge et ramène Pi au centre
  void finishEating(String successMessage) {
    state = state.finishEating(successMessage);
    _saveToStorage();
    _startStatusDismissTimer(seconds: 4);
  }

  /// Nettoie Pi de la saleté accumulée en jouant
  void cleanPi(String successMessage) {
    state = state.clean(successMessage);
    _saveToStorage();
    _startStatusDismissTimer(seconds: 4);
  }

  /// Efface le message temporaire de Pi
  void clearMessage() {
    _statusTimer?.cancel();
    state = state.copyWith(clearStatus: true);
  }
}

/// Provider global de l'état du compagnon Pi
final careControllerProvider =
    StateNotifierProvider<CareController, PiCompanion>((ref) {
      return CareController();
    });
