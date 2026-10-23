import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/features/profile/data/profile_repository.dart';
import 'package:pi_et_moi/features/profile/domain/child_profile.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';

void main() {
  group('ProfileRepository Tests', () {
    late ProfileRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = ProfileRepository();
    });

    test('Initially returns empty profiles and null active profile', () async {
      final profiles = await repository.getAllProfiles();
      expect(profiles, isEmpty);

      final active = await repository.getActiveProfile();
      expect(active, isNull);
    });

    test('Saving first profile sets it as active profile', () async {
      final lea = ChildProfile(
        id: '1',
        name: 'Léa',
        avatar: 'dog',
        grade: SchoolGrade.cm1,
        createdAt: DateTime.now(),
      );

      await repository.saveProfile(lea);

      final all = await repository.getAllProfiles();
      expect(all.length, 1);
      expect(all.first.name, 'Léa');

      final active = await repository.getActiveProfile();
      expect(active, isNotNull);
      expect(active?.id, '1');
      expect(active?.name, 'Léa');
    });

    test('Can switch active profile between multiple profiles', () async {
      final p1 = ChildProfile(
        id: '1',
        name: 'Léa',
        avatar: 'dog',
        grade: SchoolGrade.cm1,
        createdAt: DateTime.now(),
      );
      final p2 = ChildProfile(
        id: '2',
        name: 'Hugo',
        avatar: 'cat',
        grade: SchoolGrade.ce2,
        createdAt: DateTime.now(),
      );

      await repository.saveProfile(p1);
      await repository.saveProfile(p2); // will be active

      var active = await repository.getActiveProfile();
      expect(active?.name, 'Hugo');

      await repository.setActiveProfile('1');
      active = await repository.getActiveProfile();
      expect(active?.name, 'Léa');
    });

    test('Updates profile when ID already exists', () async {
      final p1 = ChildProfile(
        id: '1',
        name: 'Léa',
        avatar: 'dog',
        grade: SchoolGrade.cm1,
        createdAt: DateTime.now(),
      );
      await repository.saveProfile(p1);

      final p1Updated = p1.copyWith(name: 'Léa M.', grade: SchoolGrade.cm2);
      await repository.saveProfile(p1Updated);

      final all = await repository.getAllProfiles();
      expect(all.length, 1);
      expect(all.first.name, 'Léa M.');
      expect(all.first.grade, SchoolGrade.cm2);
    });

    test('Enforces maximum 4 profiles limit', () async {
      for (int i = 1; i <= 4; i++) {
        await repository.saveProfile(
          ChildProfile(
            id: '$i',
            name: 'Enfant $i',
            avatar: 'dog',
            grade: SchoolGrade.cp,
            createdAt: DateTime.now(),
          ),
        );
      }

      final all = await repository.getAllProfiles();
      expect(all.length, 4);

      // 5th profile should throw exception
      expect(
        () => repository.saveProfile(
          ChildProfile(
            id: '5',
            name: 'Enfant 5',
            avatar: 'dog',
            grade: SchoolGrade.cp,
            createdAt: DateTime.now(),
          ),
        ),
        throwsException,
      );
    });

    test('Deleting active profile sets another profile as active', () async {
      final p1 = ChildProfile(
        id: '1',
        name: 'Léa',
        avatar: 'dog',
        grade: SchoolGrade.cm1,
        createdAt: DateTime.now(),
      );
      final p2 = ChildProfile(
        id: '2',
        name: 'Hugo',
        avatar: 'cat',
        grade: SchoolGrade.ce2,
        createdAt: DateTime.now(),
      );

      await repository.saveProfile(p1);
      await repository.saveProfile(p2);
      await repository.setActiveProfile('1');

      await repository.deleteProfile('1');

      final all = await repository.getAllProfiles();
      expect(all.length, 1);
      expect(all.first.name, 'Hugo');

      final active = await repository.getActiveProfile();
      expect(active?.id, '2');
    });
  });
}
