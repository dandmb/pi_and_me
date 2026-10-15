import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../care/domain/pi_companion.dart';
import '../../care/presentation/care_controller.dart';
import '../../care/presentation/care_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../home/presentation/settings_sheet.dart';
import '../../profile/domain/child_profile.dart';
import '../../profile/presentation/profile_controller.dart';
import '../../profile/presentation/widgets/profile_switcher_sheet.dart';
import '../../shop/presentation/shop_screen.dart';

/// Écran Coquille Principale (MainShellScreen) unifiant :
/// - Une AppBar persistante (Nom du profil avec switch, Solde de pièces/os dorés, Paramètres).
/// - Un corps avec navigation par onglets (IndexedStack) préservant l'état des écrans.
/// - Une BottomBar avec exactement 3 onglets : [Salon, Soigner, Boutique] avec le Salon au début.
/// - Règle stricte de navigation : On ne peut quitter l'application que si l'on est sur le Salon.
///   Si l'on est sur Soigner ou Boutique, le bouton Retour ramène automatiquement au Salon.
class MainShellScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  Future<bool> _showExitDialog(BuildContext context, dynamic strings) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Row(
          children: [
            const Icon(Icons.pets, color: AppColors.sky600, size: 24),
            const SizedBox(width: AppSpace.s2),
            Expanded(
              child: Text(
                strings.confirmExitTitle,
                style: AppText.h3.copyWith(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          strings.confirmExitMessage,
          style: AppText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(strings.continuePlaying, style: AppText.label),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(strings.quit),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final profileAsync = ref.watch(activeProfileProvider);
    final companion = ref.watch(careControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          // Règle 3 : Si on n'est pas sur le Salon, le retour ramène toujours au Salon
          if (_currentIndex != 0) {
            setState(() {
              _currentIndex = 0;
            });
          } else {
            // Si on est sur le Salon, demander confirmation pour quitter
            final shouldQuit = await _showExitDialog(context, strings);
            if (shouldQuit && mounted) {
              SystemNavigator.pop();
            }
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 1. Barre supérieure persistante
                _buildTopAppBar(context, profileAsync, companion, strings),

                // 2. Contenu principal selon l'onglet actif
                Expanded(
                  child: profileAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.sky600),
                    ),
                    error: (err, _) => AppErrorView(
                      isFrench: strings.isFrench,
                      onRetry: () => ref.invalidate(activeProfileProvider),
                    ),
                    data: (profile) => IndexedStack(
                      index: _currentIndex,
                      children: [
                        // Onglet 0 : Salon (au début)
                        HomeScreen(
                          isEmbedded: true,
                          onSwitchTab: _onTabSelected,
                        ),
                        // Onglet 1 : Soigner
                        CareScreen(
                          isEmbedded: true,
                          isActive: _currentIndex == 1,
                        ),
                        // Onglet 2 : Boutique
                        const ShopScreen(isEmbedded: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 3. Barre de navigation inférieure persistante (protégée contre la barre système Android)
          bottomNavigationBar: _buildBottomNavigationBar(context, strings),
        ),
      ),
    );
  }

  // --- APP BAR UNIFIÉE ---
  Widget _buildTopAppBar(
    BuildContext context,
    AsyncValue<ChildProfile?> profileAsync,
    PiCompanion companion,
    dynamic strings,
  ) {
    final profile = profileAsync.valueOrNull;
    final childName = profile?.name ?? (strings.isFrench ? 'Ami' : 'Friend');
    final gradeLabel = profile != null
        ? strings.getGradeLabel(profile.grade)
        : (strings.isFrench ? 'CM1' : 'Grade 4');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s5,
        vertical: AppSpace.s3,
      ),
      color: AppColors.bg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pastille profil enfant cliquable pour switcher de profil
          GestureDetector(
            onTap: () => ProfileSwitcherSheet.show(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s3,
                vertical: AppSpace.s1,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.ink200, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.ink100,
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.face_rounded,
                    size: 18,
                    color: AppColors.sky700,
                  ),
                  const SizedBox(width: AppSpace.s2),
                  Text(
                    '$childName ($gradeLabel)',
                    style: AppText.label.copyWith(color: AppColors.ink900),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 18,
                    color: AppColors.ink500,
                  ),
                ],
              ),
            ),
          ),

          // Droite : Solde d'Os dorés & Bouton Paramètres
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Solde de pièces / Os dorés
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
                    const Icon(
                      Icons.stars_rounded,
                      size: 18,
                      color: AppColors.gold600,
                    ),
                    const SizedBox(width: AppSpace.s1),
                    Text(
                      '${companion.bones}',
                      style: AppText.mathS.copyWith(
                        color: AppColors.amber900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpace.s2),

              // Bouton Paramètres (Settings)
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
        ],
      ),
    );
  }

  // --- BOTTOM BAR UNIFIÉE (Salon au début, Soigner, Boutique) ---
  Widget _buildBottomNavigationBar(BuildContext context, dynamic strings) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -3),
            blurRadius: 6,
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.ink100, width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        left: true,
        right: true,
        bottom: true,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Salon (au début, index 0)
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: strings.salonDockLabel,
                isActive: _currentIndex == 0,
              ),

              // 2. Soigner (index 1)
              _buildNavItem(
                index: 1,
                icon: Icons.favorite_rounded,
                label: strings.careDockLabel,
                isActive: _currentIndex == 1,
              ),

              // 3. Boutique (index 2)
              _buildNavItem(
                index: 2,
                icon: Icons.storefront_rounded,
                label: strings.shopDockLabel,
                isActive: _currentIndex == 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: AppMotion.fast,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.sky50 : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: isActive ? AppColors.sky500 : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? AppColors.sky600 : AppColors.ink500,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyS.copyWith(
                      fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                      color: isActive ? AppColors.sky700 : AppColors.ink500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
