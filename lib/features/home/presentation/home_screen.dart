import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../profile/presentation/profile_controller.dart';
import 'settings_sheet.dart';

/// Écran 1 bis : Le Salon de Pi (Hub Principal bilingue EN/FR).
/// Présente l'enfant, l'état de Pi et le point d'accès au Quiz.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(activeProfileProvider);
    final strings = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.sky600),
          ),
          error: (err, _) => Center(
            child: Text('Erreur : $err', style: AppText.body),
          ),
          data: (profile) {
            final childName = profile?.name ?? 'Ami';
            final gradeLabel = profile != null
                ? strings.getGradeLabel(profile.grade)
                : (strings.isFrench ? 'CM1' : 'Grade 4');

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s5,
                vertical: AppSpace.s3,
              ),
              child: Column(
                children: [
                  // Barre supérieure : Pastille profil, Solde d'Os & Sélecteur de langue
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Pastille profil enfant
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.s3,
                          vertical: AppSpace.s1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppColors.ink200, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Text('🐶', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: AppSpace.s2),
                            Text(
                              '$childName ($gradeLabel)',
                              style: AppText.label.copyWith(color: AppColors.ink900),
                            ),
                          ],
                        ),
                      ),

                      // Pastille Os dorés
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.s3,
                          vertical: AppSpace.s1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.amber50,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: const Color(0xFFFDE68A),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('🦴', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: AppSpace.s1),
                            Text(
                              '50',
                              style: AppText.mathS.copyWith(
                                color: AppColors.amber900,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bouton Paramètres (ouvre la feuille des réglages et du choix de langue)
                      GestureDetector(
                        onTap: () => SettingsSheet.show(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.ink200, width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.ink100,
                                offset: Offset(0, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.settings_rounded,
                            size: 22,
                            color: AppColors.ink600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpace.s4),

                  // Bulle de dialogue de Pi
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.s5,
                      vertical: AppSpace.s3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.ink200, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.ink100,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      strings.readyForQuiz(childName),
                      style: AppText.bodyL.copyWith(color: AppColors.ink900),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: AppSpace.s4),

                  // Mascotte Pi avec ombre au sol
                  SizedBox(
                    height: 160,
                    width: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: 8,
                          child: Container(
                            width: 90,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.12),
                              borderRadius: const BorderRadius.all(
                                Radius.elliptical(90, 16),
                              ),
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/images/pi_transparent.png',
                          height: 130,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.pets,
                            size: 90,
                            color: AppColors.sky600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpace.s4),

                  // Jauges de Pi
                  Container(
                    padding: const EdgeInsets.all(AppSpace.s4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.ink200, width: 2),
                    ),
                    child: Column(
                      children: [
                        _GaugeRow(
                          icon: '🍖',
                          label: strings.hunger,
                          value: 0.80,
                          color: AppColors.green500,
                        ),
                        const SizedBox(height: AppSpace.s3),
                        _GaugeRow(
                          icon: '🎾',
                          label: strings.joy,
                          value: 0.65,
                          color: AppColors.sky500,
                        ),
                        const SizedBox(height: AppSpace.s3),
                        _GaugeRow(
                          icon: '🌙',
                          label: strings.energy,
                          value: 0.90,
                          color: AppColors.teal400,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpace.s5),

                  // Bouton principal pour lancer le quiz
                  ChunkyButton(
                    label: strings.playQuiz,
                    variant: ChunkyButtonVariant.primary,
                    height: 56,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(strings.phase2Notice),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpace.s2),

                  // Bouton secondaire pour changer d'enfant / profil
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const OnboardingScreen(),
                        ),
                      );
                    },
                    child: Text(
                      strings.changeProfile,
                      style: AppText.label.copyWith(color: AppColors.sky800),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GaugeRow extends StatelessWidget {
  final String icon;
  final String label;
  final double value;
  final Color color;

  const _GaugeRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).toInt();

    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: AppSpace.s2),
        SizedBox(
          width: 70,
          child: Text(label, style: AppText.label),
        ),
        const SizedBox(width: AppSpace.s2),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              height: 10,
              color: AppColors.ink100,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(color: color),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpace.s2),
        SizedBox(
          width: 40,
          child: Text(
            '$percent %',
            style: AppText.mathXS,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
