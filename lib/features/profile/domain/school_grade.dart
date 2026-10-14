/// Niveaux scolaires officiels couverts par Pi & Moi (CP à la 3e).
/// Structurés selon les cycles pédagogiques du système éducatif français.
enum SchoolGrade {
  cp(
    id: 'cp',
    label: 'CP',
    fullName: 'Cours Préparatoire',
    cycle: 2,
    cycleLabel: 'Cycle 2 (Apprentissages fondamentaux)',
  ),
  ce1(
    id: 'ce1',
    label: 'CE1',
    fullName: 'Cours Élémentaire 1',
    cycle: 2,
    cycleLabel: 'Cycle 2 (Apprentissages fondamentaux)',
  ),
  ce2(
    id: 'ce2',
    label: 'CE2',
    fullName: 'Cours Élémentaire 2',
    cycle: 2,
    cycleLabel: 'Cycle 2 (Apprentissages fondamentaux)',
  ),
  cm1(
    id: 'cm1',
    label: 'CM1',
    fullName: 'Cours Moyen 1',
    cycle: 3,
    cycleLabel: 'Cycle 3 (Consolidation)',
  ),
  cm2(
    id: 'cm2',
    label: 'CM2',
    fullName: 'Cours Moyen 2',
    cycle: 3,
    cycleLabel: 'Cycle 3 (Consolidation)',
  ),
  sixieme(
    id: '6e',
    label: '6e',
    fullName: 'Classe de Sixième',
    cycle: 3,
    cycleLabel: 'Cycle 3 (Consolidation)',
  ),
  cinquieme(
    id: '5e',
    label: '5e',
    fullName: 'Classe de Cinquième',
    cycle: 4,
    cycleLabel: 'Cycle 4 (Approfondissements)',
  ),
  quatrieme(
    id: '4e',
    label: '4e',
    fullName: 'Classe de Quatrième',
    cycle: 4,
    cycleLabel: 'Cycle 4 (Approfondissements)',
  ),
  troisieme(
    id: '3e',
    label: '3e',
    fullName: 'Classe de Troisième',
    cycle: 4,
    cycleLabel: 'Cycle 4 (Approfondissements)',
  );

  final String id;
  final String label;
  final String fullName;
  final int cycle;
  final String cycleLabel;

  const SchoolGrade({
    required this.id,
    required this.label,
    required this.fullName,
    required this.cycle,
    required this.cycleLabel,
  });

  /// Parse un identifiant (ex: "cp", "6e") vers son enum SchoolGrade
  static SchoolGrade fromId(String id, {SchoolGrade fallback = SchoolGrade.cm1}) {
    for (final grade in SchoolGrade.values) {
      if (grade.id.toLowerCase() == id.toLowerCase()) {
        return grade;
      }
    }
    return fallback;
  }
}
