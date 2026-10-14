import 'dart:convert';
import 'school_grade.dart';

/// Modèle représentant le profil d'un enfant dans Pi & Moi.
/// Conforme aux exigences RGPD / Google Play Familles :
/// Seuls le prénom, l'avatar et la classe sont collectés (zéro nom de famille, zéro PII).
class ChildProfile {
  final String id;
  final String name;
  final String avatar;
  final SchoolGrade grade;
  final DateTime createdAt;

  const ChildProfile({
    required this.id,
    required this.name,
    required this.avatar,
    required this.grade,
    required this.createdAt,
  });

  /// Crée un profil par défaut (exemple onboarding)
  factory ChildProfile.defaultProfile({String name = 'Léa', SchoolGrade grade = SchoolGrade.cm1}) {
    return ChildProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      avatar: 'avatar_dog',
      grade: grade,
      createdAt: DateTime.now(),
    );
  }

  /// Convertit l'objet en Map pour la sérialisation JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'grade': grade.id,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Reconstruit l'objet depuis une Map
  factory ChildProfile.fromMap(Map<String, dynamic> map) {
    return ChildProfile(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name'] as String? ?? 'Ami',
      avatar: map['avatar'] as String? ?? 'avatar_dog',
      grade: SchoolGrade.fromId(map['grade'] as String? ?? 'cm1'),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Sérialisation JSON
  String toJson() => jsonEncode(toMap());

  /// Désérialisation JSON
  factory ChildProfile.fromJson(String source) =>
      ChildProfile.fromMap(jsonDecode(source) as Map<String, dynamic>);

  /// Copie immuable avec mise à jour partielle
  ChildProfile copyWith({
    String? id,
    String? name,
    String? avatar,
    SchoolGrade? grade,
    DateTime? createdAt,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      grade: grade ?? this.grade,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildProfile &&
        other.id == id &&
        other.name == name &&
        other.avatar == avatar &&
        other.grade == grade;
  }

  @override
  int get hashCode => Object.hash(id, name, avatar, grade);

  @override
  String toString() => 'ChildProfile(id: $id, name: $name, grade: ${grade.label})';
}
