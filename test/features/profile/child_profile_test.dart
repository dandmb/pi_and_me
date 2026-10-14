import 'package:flutter_test/flutter_test.dart';
import 'package:pi_et_moi/features/profile/domain/child_profile.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';

void main() {
  group('SchoolGrade Enum Tests', () {
    test('All 9 French curriculum grades are correctly declared', () {
      expect(SchoolGrade.values.length, 9);
      expect(SchoolGrade.cp.label, 'CP');
      expect(SchoolGrade.ce1.label, 'CE1');
      expect(SchoolGrade.ce2.label, 'CE2');
      expect(SchoolGrade.cm1.label, 'CM1');
      expect(SchoolGrade.cm2.label, 'CM2');
      expect(SchoolGrade.sixieme.label, '6e');
      expect(SchoolGrade.cinquieme.label, '5e');
      expect(SchoolGrade.quatrieme.label, '4e');
      expect(SchoolGrade.troisieme.label, '3e');
    });

    test('Cycles are correctly mapped', () {
      expect(SchoolGrade.cp.cycle, 2);
      expect(SchoolGrade.cm1.cycle, 3);
      expect(SchoolGrade.sixieme.cycle, 3);
      expect(SchoolGrade.troisieme.cycle, 4);
    });

    test('fromId parses correctly with fallback', () {
      expect(SchoolGrade.fromId('6e'), SchoolGrade.sixieme);
      expect(SchoolGrade.fromId('cp'), SchoolGrade.cp);
      expect(SchoolGrade.fromId('inconnu'), SchoolGrade.cm1);
    });
  });

  group('ChildProfile Model Tests', () {
    final testDate = DateTime(2026, 10, 14, 12, 0);

    final profile = ChildProfile(
      id: 'profile_1',
      name: 'Léa',
      avatar: 'avatar_dog',
      grade: SchoolGrade.cm1,
      createdAt: testDate,
    );

    test('Serialization toMap and fromMap preserves data', () {
      final map = profile.toMap();
      expect(map['id'], 'profile_1');
      expect(map['name'], 'Léa');
      expect(map['avatar'], 'avatar_dog');
      expect(map['grade'], 'cm1');
      expect(map['createdAt'], testDate.toIso8601String());

      final restored = ChildProfile.fromMap(map);
      expect(restored.id, profile.id);
      expect(restored.name, profile.name);
      expect(restored.avatar, profile.avatar);
      expect(restored.grade, profile.grade);
      expect(restored.createdAt, profile.createdAt);
      expect(restored, profile);
    });

    test('JSON serialization toJson and fromJson works', () {
      final jsonStr = profile.toJson();
      final restored = ChildProfile.fromJson(jsonStr);
      expect(restored, profile);
    });

    test('copyWith updates fields selectively', () {
      final updated = profile.copyWith(name: 'Hugo', grade: SchoolGrade.ce2);
      expect(updated.name, 'Hugo');
      expect(updated.grade, SchoolGrade.ce2);
      expect(updated.id, profile.id);
      expect(updated.avatar, profile.avatar);
    });
  });
}
