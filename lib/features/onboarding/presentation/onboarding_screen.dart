import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../home/presentation/home_screen.dart';
import '../../profile/domain/child_profile.dart';
import '../../profile/domain/school_grade.dart';
import '../../profile/presentation/profile_controller.dart';

/// Écran 1 : Onboarding & Création du Profil Enfant.
/// Conforme à DESIGN_SYSTEM.md §12 et Stitch Screen 11566295510221200974.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Léa');
  String _selectedAvatar = 'avatar_dog';
  SchoolGrade _selectedGrade = SchoolGrade.cm1;
  String? _errorMessage;

  final List<({String id, String label, String emoji})> _avatars = const [
    (id: 'avatar_dog', label: 'Pi', emoji: '🐶'),
    (id: 'avatar_cat', label: 'Minou', emoji: '🐱'),
    (id: 'avatar_fox', label: 'Renard', emoji: '🦊'),
    (id: 'avatar_bear', label: 'Ourson', emoji: '🐻'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Wouf ! Quel est ton prénom ?';
      });
      return;
    }

    final newProfile = ChildProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      avatar: _selectedAvatar,
      grade: _selectedGrade,
      createdAt: DateTime.now(),
    );

    await ref.read(activeProfileProvider.notifier).saveProfile(newProfile);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppMotion.base,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpace.maxContentWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s5,
                vertical: AppSpace.s4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête avec Pi et sa bulle
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/pi_transparent.png',
                        height: 70,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.pets,
                          size: 50,
                          color: AppColors.sky600,
                        ),
                      ),
                      const SizedBox(width: AppSpace.s3),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpace.s4,
                            vertical: AppSpace.s3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.ink200, width: 2),
                          ),
                          child: Text(
                            'Wouf ! Crée ton profil pour jouer avec moi !',
                            style: AppText.body.copyWith(color: AppColors.ink900),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpace.s6),

                  // Titre
                  Text(
                    'Qui va jouer avec Pi ?',
                    style: AppText.h2,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpace.s5),

                  // 1. Choix de l'avatar
                  Text(
                    'Choisis ton avatar',
                    style: AppText.label.copyWith(color: AppColors.ink600),
                  ),
                  const SizedBox(height: AppSpace.s2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _avatars.map((avatar) {
                      final isSelected = _selectedAvatar == avatar.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedAvatar = avatar.id);
                        },
                        child: AnimatedContainer(
                          duration: AppMotion.fast,
                          padding: const EdgeInsets.all(AppSpace.s2),
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.sky50 : AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.sky500 : AppColors.ink200,
                              width: isSelected ? 3.0 : 2.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            avatar.emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpace.s5),

                  // 2. Saisie du prénom
                  Text(
                    'Ton prénom',
                    style: AppText.label.copyWith(color: AppColors.ink600),
                  ),
                  const SizedBox(height: AppSpace.s2),
                  TextField(
                    controller: _nameController,
                    maxLength: 12,
                    style: AppText.bodyL,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surface,
                      hintText: 'Ex: Léa',
                      counterText: '',
                      errorText: _errorMessage,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.s4,
                        vertical: AppSpace.s4,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.ink200, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.sky500, width: 3),
                      ),
                    ),
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                  ),

                  const SizedBox(height: AppSpace.s4),

                  // 3. Sélecteur de classe (CP à 3e)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ta classe',
                        style: AppText.label.copyWith(color: AppColors.ink600),
                      ),
                      const SizedBox(width: AppSpace.s2),
                      Flexible(
                        child: Text(
                          _selectedGrade.cycleLabel,
                          style: AppText.bodyS.copyWith(
                            color: AppColors.sky800,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.s2),

                  // Grille des 9 classes scolaires
                  Wrap(
                    spacing: AppSpace.s2,
                    runSpacing: AppSpace.s2,
                    children: SchoolGrade.values.map((grade) {
                      final isSelected = _selectedGrade == grade;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedGrade = grade);
                        },
                        child: AnimatedContainer(
                          duration: AppMotion.fast,
                          width: (MediaQuery.of(context).size.width.clamp(0.0, AppSpace.maxContentWidth) - 40 - 16) / 3,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.sky50 : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected ? AppColors.sky500 : AppColors.ink200,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? AppColors.sky700 : AppColors.ink300,
                                offset: const Offset(0, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                grade.label,
                                style: AppText.mathM.copyWith(
                                  color: isSelected ? AppColors.sky800 : AppColors.ink900,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: AppColors.sky600,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpace.s8),

                  // Bouton CTA principal « C'est parti ! »
                  ChunkyButton(
                    label: 'C\'est parti !',
                    variant: ChunkyButtonVariant.primary,
                    height: 56,
                    onPressed: _handleSaveProfile,
                  ),

                  const SizedBox(height: AppSpace.s4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
