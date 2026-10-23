import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/features/profile/data/profile_repository.dart';
import 'package:pi_et_moi/features/profile/domain/child_profile.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';
import 'package:pi_et_moi/features/profile/presentation/profile_controller.dart';

void main() {
  group('ProfileController Riverpod Tests', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(ProfileRepository()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'Initial activeProfileProvider state loads null if no profile exists',
      () async {
        final initial = await container.read(activeProfileProvider.future);
        expect(initial, isNull);
      },
    );

    test('saveProfile updates active profile in Riverpod state', () async {
      final profile = ChildProfile(
        id: '101',
        name: 'Léa',
        avatar: 'dog',
        grade: SchoolGrade.cm1,
        createdAt: DateTime.now(),
      );

      final notifier = container.read(activeProfileProvider.notifier);
      await notifier.saveProfile(profile);

      final active = container.read(activeProfileProvider).value;
      expect(active, isNotNull);
      expect(active?.name, 'Léa');
      expect(active?.grade, SchoolGrade.cm1);
    });
  });
}
