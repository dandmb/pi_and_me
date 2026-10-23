/// Langues prises en charge par MathPup.
/// Par défaut : Anglais (en). Si le français est activé : Français (fr).
enum AppLanguage {
  en(code: 'en', label: 'EN', name: 'English', flag: '🇬🇧'),
  fr(code: 'fr', label: 'FR', name: 'Français', flag: '🇫🇷');

  final String code;
  final String label;
  final String name;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.label,
    required this.name,
    required this.flag,
  });

  /// Parse le code de langue avec fallback par défaut vers l'anglais (en)
  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.en;
    return AppLanguage.values.firstWhere(
      (lang) => lang.code.toLowerCase() == code.toLowerCase(),
      orElse: () => AppLanguage.en,
    );
  }
}
