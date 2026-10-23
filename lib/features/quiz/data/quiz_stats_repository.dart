import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/quiz_session_record.dart';

/// Dépôt local pour stocker et agréger l'historique des quiz complétés.
/// 100% hors-ligne, zéro tracker, respect strict de la vie privée (RGPD).
class QuizStatsRepository {
  static const String _storagePrefix = 'pi_quiz_history_';
  final SharedPreferences? _prefsInstance;

  QuizStatsRepository({SharedPreferences? prefs}) : _prefsInstance = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefsInstance ?? await SharedPreferences.getInstance();
  }

  /// Enregistre une nouvelle session de quiz terminée.
  Future<void> recordSession(QuizSessionRecord record) async {
    final prefs = await _getPrefs();
    final key = '$_storagePrefix${record.profileId}';
    final existing = await getSessionsForProfile(record.profileId);
    final updated = [...existing, record];
    final encoded = jsonEncode(updated.map((r) => r.toMap()).toList());
    await prefs.setString(key, encoded);
  }

  /// Récupère toutes les sessions enregistrées pour un profil enfant donné.
  Future<List<QuizSessionRecord>> getSessionsForProfile(
    String profileId,
  ) async {
    final prefs = await _getPrefs();
    final key = '$_storagePrefix$profileId';
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((m) => QuizSessionRecord.fromMap(m as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Récupère l'ensemble des sessions de tous les profils du foyer.
  Future<List<QuizSessionRecord>> getAllSessions() async {
    final prefs = await _getPrefs();
    final keys = prefs.getKeys().where((k) => k.startsWith(_storagePrefix));
    final all = <QuizSessionRecord>[];

    for (final key in keys) {
      final raw = prefs.getString(key);
      if (raw != null && raw.isNotEmpty) {
        try {
          final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
          all.addAll(
            decoded.map(
              (m) => QuizSessionRecord.fromMap(m as Map<String, dynamic>),
            ),
          );
        } catch (_) {}
      }
    }
    return all;
  }

  /// Supprime définitivement l'historique de tous les profils (Art. 17 RGPD).
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith(_storagePrefix))
        .toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

/// Provider Riverpod global pour le dépôt d'historique de quiz.
final quizStatsRepositoryProvider = Provider<QuizStatsRepository>((ref) {
  return QuizStatsRepository();
});
