import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/theme_mode_controller.dart';
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
/// - Une AppBar persistante et stylée (Profil avec switch, Solde d'os dorés, Switch Dark Mode, Paramètres).
/// - Un corps avec navigation par onglets (IndexedStack) préservant l'état des écrans.
/// - Une BottomBar stylée (Dock flottant) avec 3 onglets : [Salon, Soigner, Boutique] avec le Salon au début.
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
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
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
          backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 1. Barre supérieure persistante et stylée
                _buildTopAppBar(context, profileAsync, companion, strings, isDark, themeMode),

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
          // 3. Barre de navigation inférieure persistante (Dock flottant moderne)
          bottomNavigationBar: _buildBottomNavigationBar(context, strings, isDark),
        ),
      ),
    );
  }

  // --- APP BAR UNIFIÉE & STYLÉE ---
  Widget _buildTopAppBar(
    BuildContext context,
    AsyncValue<ChildProfile?> profileAsync,
    PiCompanion companion,
    dynamic strings,
    bool isDark,
    ThemeMode themeMode,
  ) {
    final profile = profileAsync.valueOrNull;
    final childName = profile?.name ?? (strings.isFrench ? 'Ami' : 'Friend');
    final gradeLabel = profile != null
        ? strings.getGradeLabel(profile.grade)
        : (strings.isFrench ? 'CM1' : 'Grade 4');

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkInk200 : AppColors.ink200;
    final textColor = isDark ? AppColors.darkInk900 : AppColors.ink900;
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.ink100;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s4,
        vertical: AppSpace.s2,
      ),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pastille profil enfant cliquable pour switcher de profil
          GestureDetector(
            onTap: () => ProfileSwitcherSheet.show(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s3,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: borderColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSky50 : AppColors.sky50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.face_rounded,
                      size: 16,
                      color: AppColors.sky600,
                    ),
                  ),
                  const SizedBox(width: AppSpace.s2),
                  Text(
                    '$childName ($gradeLabel)',
                    style: AppText.label.copyWith(
                      color: textColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 18,
                    color: isDark ? AppColors.darkInk500 : AppColors.ink500,
                  ),
                ],
              ),
            ),
          ),

          // Droite : Solde d'Os dorés + Toggle Thème Sombre + Bouton Paramètres
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Solde de pièces / Os dorés
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.s3,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF451A03) : AppColors.amber50,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: isDark ? const Color(0xFFD97706) : const Color(0xFFFDE68A),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFFFEF3C7),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
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
                        color: isDark ? const Color(0xFFFDE68A) : AppColors.amber900,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Bouton Toggle Mode Sombre / Clair rapide
              GestureDetector(
                onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    size: 18,
                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF6366F1),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Bouton Paramètres (Settings)
              GestureDetector(
                onTap: () => SettingsSheet.show(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    size: 19,
                    color: isDark ? AppColors.darkInk600 : AppColors.ink600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- BOTTOM BAR UNIFIÉE (Dock Flottant Moderne : Salon, Soigner, Boutique) ---
  Widget _buildBottomNavigationBar(BuildContext context, dynamic strings, bool isDark) {
    final dockBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final dockBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Container(
        margin: const EdgeInsets.only(left: 18, right: 18, bottom: 8, top: 4),
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: dockBg,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: dockBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              offset: const Offset(0, 4),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 1. Salon (au début, index 0)
            _buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: strings.salonDockLabel,
              isActive: _currentIndex == 0,
              isDark: isDark,
            ),

            // 2. Soigner (index 1)
            _buildNavItem(
              index: 1,
              icon: Icons.favorite_rounded,
              label: strings.careDockLabel,
              isActive: _currentIndex == 1,
              isDark: isDark,
            ),

            // 3. Boutique (index 2)
            _buildNavItem(
              index: 2,
              icon: Icons.storefront_rounded,
              label: strings.shopDockLabel,
              isActive: _currentIndex == 2,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isActive ? 16 : 8,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                        offset: const Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? Colors.white
                      : (isDark ? AppColors.darkInk500 : AppColors.ink500),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyS.copyWith(
                      fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                      fontSize: 12.5,
                      color: isActive
                          ? Colors.white
                          : (isDark ? AppColors.darkInk600 : AppColors.ink600),
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

