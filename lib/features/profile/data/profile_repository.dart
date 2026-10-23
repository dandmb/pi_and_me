import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/child_profile.dart';

/// Dépôt de gestion locale des profils enfants (Offline-First).
/// Sauvegarde sécurisée et sans over-ingénierie via SharedPreferences & JSON.
class ProfileRepository {
  static const String _keyProfilesList = 'pi_profiles_list';
  static const String _keyActiveProfileId = 'pi_active_profile_id';
  static const int maxProfiles = 4; // Limite fixée par les spécifications

  final SharedPreferences? _prefsInstance;

  ProfileRepository({SharedPreferences? prefs}) : _prefsInstance = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefsInstance ?? await SharedPreferences.getInstance();
  }

  /// Récupère la liste de tous les profils enregistrés (jusqu'à 4).
  Future<List<ChildProfile>> getAllProfiles() async {
    final prefs = await _getPrefs();
    final rawJson = prefs.getString(_keyProfilesList);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => ChildProfile.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Récupère le profil actuellement actif pour la session de jeu.
  Future<ChildProfile?> getActiveProfile() async {
    final profiles = await getAllProfiles();
    if (profiles.isEmpty) return null;

    final prefs = await _getPrefs();
    final activeId = prefs.getString(_keyActiveProfileId);

    if (activeId != null) {
      final found = profiles.where((p) => p.id == activeId);
      if (found.isNotEmpty) return found.first;
    }

    // Par défaut, retourner le premier profil existant
    return profiles.first;
  }

  /// Sauvegarde ou met à jour un profil enfant.
  /// Si le profil est nouveau et que la limite de 4 est atteinte, une Exception est levée.
  Future<void> saveProfile(ChildProfile profile) async {
    final profiles = await getAllProfiles();
    final existingIndex = profiles.indexWhere((p) => p.id == profile.id);

    if (existingIndex >= 0) {
      profiles[existingIndex] = profile;
    } else {
      if (profiles.length >= maxProfiles) {
        throw Exception('Limite de $maxProfiles profils enfants atteinte.');
      }
      profiles.add(profile);
    }

    final prefs = await _getPrefs();
    final encoded = jsonEncode(profiles.map((p) => p.toMap()).toList());
    await prefs.setString(_keyProfilesList, encoded);

    // Définir automatiquement ce profil comme actif
    await prefs.setString(_keyActiveProfileId, profile.id);
  }

  /// Change le profil actif de l'application.
  Future<void> setActiveProfile(String profileId) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyActiveProfileId, profileId);
  }

  /// Supprime un profil enfant par son identifiant.
  Future<void> deleteProfile(String profileId) async {
    final profiles = await getAllProfiles();
    profiles.removeWhere((p) => p.id == profileId);

    final prefs = await _getPrefs();
    final encoded = jsonEncode(profiles.map((p) => p.toMap()).toList());
    await prefs.setString(_keyProfilesList, encoded);

    final activeId = prefs.getString(_keyActiveProfileId);
    if (activeId == profileId) {
      if (profiles.isNotEmpty) {
        await prefs.setString(_keyActiveProfileId, profiles.first.id);
      } else {
        await prefs.remove(_keyActiveProfileId);
      }
    }
  }

  /// Réinitialise toutes les données de profil (Droit à l'oubli RGPD / Tests).
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyProfilesList);
    await prefs.remove(_keyActiveProfileId);
  }
}
