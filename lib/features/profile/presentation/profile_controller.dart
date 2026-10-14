import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_repository.dart';
import '../domain/child_profile.dart';

/// Provider pour accéder au dépôt de profils dans toute l'application.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

/// Provider permettant d'écouter la liste de tous les profils existants.
final allProfilesProvider = FutureProvider<List<ChildProfile>>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getAllProfiles();
});

/// Notifier Riverpod gérant le profil actif sélectionné pour la session.
class ActiveProfileNotifier extends AsyncNotifier<ChildProfile?> {
  @override
  Future<ChildProfile?> build() async {
    final repo = ref.read(profileRepositoryProvider);
    return repo.getActiveProfile();
  }

  /// Change de profil actif.
  Future<void> switchProfile(String profileId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      await repo.setActiveProfile(profileId);
      ref.invalidate(allProfilesProvider);
      return repo.getActiveProfile();
    });
  }

  /// Crée ou met à jour un profil enfant, puis le définit comme actif.
  Future<void> saveProfile(ChildProfile profile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      await repo.saveProfile(profile);
      ref.invalidate(allProfilesProvider);
      return profile;
    });
  }

  /// Supprime un profil enfant.
  Future<void> deleteProfile(String profileId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      await repo.deleteProfile(profileId);
      ref.invalidate(allProfilesProvider);
      return repo.getActiveProfile();
    });
  }
}

/// Provider global du profil enfant actif.
final activeProfileProvider =
    AsyncNotifierProvider<ActiveProfileNotifier, ChildProfile?>(() {
  return ActiveProfileNotifier();
});
