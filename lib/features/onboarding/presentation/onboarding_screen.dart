import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../navigation/presentation/main_shell_screen.dart';
import '../../profile/domain/child_profile.dart';
import '../../profile/domain/school_grade.dart';
import '../../profile/presentation/profile_controller.dart';

/// Écran 1 : Onboarding & Création du Profil Enfant (Bilingue EN/FR).
/// Conforme à DESIGN_SYSTEM.md §12 et Stitch Screen 11566295510221200974.
class OnboardingScreen extends ConsumerStatefulWidget {
  final bool canCancel;

  const OnboardingScreen({
    super.key,
    this.canCancel = false,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final TextEditingController _nameController;
  String _selectedAvatar = 'avatar_dog';
  SchoolGrade _selectedGrade = SchoolGrade.cm1;
  String? _errorMessage;

  final List<({String id, IconData icon, Color color})> _avatars = const [
    (id: 'avatar_dog', icon: Icons.pets_rounded, color: AppColors.sky600),
    (id: 'avatar_cat', icon: Icons.cruelty_free_rounded, color: AppColors.coral500),
    (id: 'avatar_fox', icon: Icons.forest_rounded, color: AppColors.green600),
    (id: 'avatar_bear', icon: Icons.theater_comedy_rounded, color: Color(0xFF8B5CF6)),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile(String emptyError) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorMessage = emptyError;
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

    if (widget.canCancel && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainShellScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: AppMotion.base,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);

    return PopScope(
      canPop: widget.canCancel,
      child: Scaffold(
        backgroundColor: context.appBg,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSpace.maxContentWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.s5,
                  vertical: AppSpace.s3,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bouton Annuler si ouvert depuis le switcher de profil
                    if (widget.canCancel) ...[
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: context.appSurface,
                              shape: BoxShape.circle,
                              border: Border.all(color: context.appBorder, width: 1.5),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20,
                              color: context.appSubText,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpace.s3),
                        Text(
                          strings.addProfile,
                          style: AppText.h3.copyWith(fontSize: 18, color: context.appText),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.s3),
                  ],

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
                            color: context.appSurface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: context.appBorder, width: 2),
                          ),
                          child: Text(
                            strings.onboardingWelcome,
                            style: AppText.body.copyWith(color: context.appText),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpace.s5),

                  // Titre
                  Text(
                    strings.whoWillPlay,
                    style: AppText.h2.copyWith(color: context.appText),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpace.s5),

                  // 1. Choix de l'avatar vectoriel
                  Text(
                    strings.chooseAvatar,
                    style: AppText.label.copyWith(color: context.appSubText),
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
                            color: isSelected
                                ? (context.isDark ? AppColors.darkSky50 : AppColors.sky50)
                                : context.appSurface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.sky500 : context.appBorder,
                              width: isSelected ? 3.0 : 2.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            avatar.icon,
                            size: 32,
                            color: isSelected ? avatar.color : context.appSubText,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: AppSpace.s5),

                  // 2. Saisie du prénom
                  Text(
                    strings.yourName,
                    style: AppText.label.copyWith(color: context.appSubText),
                  ),
                  const SizedBox(height: AppSpace.s2),
                  TextField(
                    controller: _nameController,
                    maxLength: 12,
                    style: AppText.bodyL.copyWith(color: context.appText),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: context.appSurface,
                      hintText: strings.nameHint,
                      counterText: '',
                      errorText: _errorMessage,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.s4,
                        vertical: AppSpace.s4,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: context.appBorder, width: 2),
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

                  // 3. Sélecteur de classe (CP à 3e / Grade 1 to 9)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        strings.yourGrade,
                        style: AppText.label.copyWith(color: context.appSubText),
                      ),
                      const SizedBox(width: AppSpace.s2),
                      Flexible(
                        child: Text(
                          strings.getCycleLabel(_selectedGrade),
                          style: AppText.bodyS.copyWith(
                            color: context.isDark ? AppColors.darkSky500 : AppColors.sky800,
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
                      final gradeLabel = strings.getGradeLabel(grade);
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedGrade = grade);
                        },
                        child: AnimatedContainer(
                          duration: AppMotion.fast,
                          width: (MediaQuery.of(context).size.width.clamp(0.0, AppSpace.maxContentWidth) - 40 - 16) / 3,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (context.isDark ? AppColors.darkSky50 : AppColors.sky50)
                                : context.appSurface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected ? AppColors.sky500 : context.appBorder,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? AppColors.sky700
                                    : context.appShadow,
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
                                gradeLabel,
                                style: AppText.mathM.copyWith(
                                  color: isSelected
                                      ? (context.isDark ? AppColors.darkSky500 : AppColors.sky800)
                                      : context.appText,
                                  fontWeight: FontWeight.w700,
                                  fontSize: gradeLabel.length > 5 ? 15 : 20,
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

                  // Bouton CTA principal
                  ChunkyButton(
                    label: strings.letsGo,
                    variant: ChunkyButtonVariant.primary,
                    height: 56,
                    onPressed: () => _handleSaveProfile(strings.nameEmptyError),
                  ),

                  const SizedBox(height: AppSpace.s4),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  }
}
