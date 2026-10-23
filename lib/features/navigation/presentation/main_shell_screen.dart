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
import '../../profile/domain/school_grade.dart';
import '../../profile/presentation/profile_controller.dart';
import '../../profile/presentation/widgets/profile_switcher_sheet.dart';
import '../../shop/presentation/shop_screen.dart';
import '../../parent/presentation/daily_limit_controller.dart';
import '../../parent/presentation/daily_limit_screen.dart';

/// Conteneur principal de navigation avec barre d'onglets (Salon, Soigner, Boutique).
class MainShellScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainShellScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  // L'index de l'onglet actuellement sélectionné (0 = Salon, 1 = Soigner, 2 = Boutique)
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    final limitState = ref.read(dailyLimitControllerProvider);
    if (limitState.isLimitReached && (index == 1 || index == 2)) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const DailyLimitScreen()));
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  Future<bool> _showExitDialog(BuildContext context, dynamic strings) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
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
                style: AppText.h3.copyWith(
                  fontSize: 18,
                  color: isDark ? AppColors.darkInk900 : AppColors.ink900,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          strings.confirmExitMessage,
          style: AppText.body.copyWith(
            color: isDark ? AppColors.darkInk600 : AppColors.ink600,
          ),
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
            child: Text(strings.quit, style: AppText.buttonM),
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
    final limitState = ref.watch(dailyLimitControllerProvider);

    // Si la limite quotidienne est atteinte et qu'on était sur Soigner ou Boutique,
    // on repositionne automatiquement sur le Salon pour respecter le repos de Pi.
    if (limitState.isLimitReached && _currentIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      });
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
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
            child: isLandscape
                ? Row(
                    children: [
                      // Rail de navigation latéral en mode paysage
                      _buildLandscapeNavigationRail(
                        context,
                        strings,
                        isDark,
                        limitState.isLimitReached,
                      ),
                      // Contenu principal avec AppBar compacte
                      Expanded(
                        child: Column(
                          children: [
                            _buildTopAppBar(
                              context,
                              profileAsync,
                              companion,
                              strings,
                              isDark,
                              themeMode,
                              isLandscape: true,
                            ),
                            Expanded(
                              child: profileAsync.when(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.sky600,
                                  ),
                                ),
                                error: (err, _) => AppErrorView(
                                  isFrench: strings.isFrench,
                                  onRetry: () =>
                                      ref.invalidate(activeProfileProvider),
                                ),
                                data: (profile) => IndexedStack(
                                  index: _currentIndex,
                                  children: [
                                    HomeScreen(
                                      isEmbedded: true,
                                      onSwitchTab: _onTabSelected,
                                    ),
                                    CareScreen(
                                      isEmbedded: true,
                                      isActive: _currentIndex == 1,
                                    ),
                                    const ShopScreen(isEmbedded: true),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      // 1. Barre supérieure persistante et stylée
                      _buildTopAppBar(
                        context,
                        profileAsync,
                        companion,
                        strings,
                        isDark,
                        themeMode,
                      ),

                      // 2. Contenu principal selon l'onglet actif
                      Expanded(
                        child: profileAsync.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.sky600,
                            ),
                          ),
                          error: (err, _) => AppErrorView(
                            isFrench: strings.isFrench,
                            onRetry: () =>
                                ref.invalidate(activeProfileProvider),
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
          // 3. Barre de navigation inférieure persistante (Portrait uniquement)
          bottomNavigationBar: isLandscape
              ? null
              : _buildBottomNavigationBar(
                  context,
                  strings,
                  isDark,
                  limitState.isLimitReached,
                ),
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
    ThemeMode themeMode, {
    bool isLandscape = false,
  }) {
    final profile = profileAsync.valueOrNull;
    final childName = profile?.name ?? strings.defaultFriendName;
    final gradeLabel = profile != null
        ? strings.getGradeLabel(profile.grade)
        : strings.getGradeLabel(SchoolGrade.cm1);

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkInk200 : AppColors.ink200;
    final textColor = isDark ? AppColors.darkInk900 : AppColors.ink900;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : AppColors.ink100;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpace.s4,
        vertical: isLandscape ? AppSpace.s1 : AppSpace.s2,
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
                    color: isDark
                        ? const Color(0xFFD97706)
                        : const Color(0xFFFDE68A),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.25)
                          : const Color(0xFFFEF3C7),
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
                        color: isDark
                            ? const Color(0xFFFDE68A)
                            : AppColors.amber900,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
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

  // --- RAIL DE NAVIGATION LATÉRAL (Mode Paysage) ---
  Widget _buildLandscapeNavigationRail(
    BuildContext context,
    dynamic strings,
    bool isDark,
    bool isLimitReached,
  ) {
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkInk200 : AppColors.ink200;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : AppColors.ink100;

    return Container(
      width: 78,
      margin: const EdgeInsets.fromLTRB(AppSpace.s3, AppSpace.s2, 0, AppSpace.s2),
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s2, horizontal: 4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Mini Logo Chiot Pi
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF003640) : const Color(0xFFE0F7FC),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: AppColors.sky600, size: 20),
          ),
          const SizedBox(height: AppSpace.s3),
          // 1. Salon
          _buildLandscapeRailItem(
            index: 0,
            icon: Icons.home_rounded,
            label: strings.salonDockLabel,
            isActive: _currentIndex == 0,
            isDark: isDark,
          ),
          const SizedBox(height: AppSpace.s2),
          // 2. Soigner
          _buildLandscapeRailItem(
            index: 1,
            icon: Icons.favorite_rounded,
            label: strings.careDockLabel,
            isActive: _currentIndex == 1,
            isDark: isDark,
            isLocked: isLimitReached,
          ),
          const SizedBox(height: AppSpace.s2),
          // 3. Boutique
          _buildLandscapeRailItem(
            index: 2,
            icon: Icons.storefront_rounded,
            label: strings.shopDockLabel,
            isActive: _currentIndex == 2,
            isDark: isDark,
            isLocked: isLimitReached,
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeRailItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isDark,
    bool isLocked = false,
  }) {
    final effectiveIcon = isLocked ? Icons.lock_outline_rounded : icon;
    final itemOpacity = isLocked ? 0.45 : 1.0;

    return Opacity(
      opacity: itemOpacity,
      child: GestureDetector(
        key: Key('nav_item_$index'),
        onTap: () => _onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? AppColors.darkSky500 : AppColors.sky500)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                effectiveIcon,
                size: 20,
                color: isActive
                    ? (isDark ? const Color(0xFF003640) : Colors.white)
                    : (isDark ? AppColors.darkInk500 : AppColors.ink500),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.bodyS.copyWith(
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                  fontSize: 10,
                  color: isActive
                      ? (isDark ? const Color(0xFF003640) : Colors.white)
                      : (isDark ? AppColors.darkInk600 : AppColors.ink600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- BOTTOM BAR UNIFIÉE (Dock Flottant Moderne : Salon, Soigner, Boutique) ---
  Widget _buildBottomNavigationBar(
    BuildContext context,
    dynamic strings,
    bool isDark,
    bool isLimitReached,
  ) {
    final dockBg = isDark ? AppColors.darkSurface : Colors.white;
    final dockBorder = isDark ? AppColors.darkInk200 : const Color(0xFFE2E8F0);

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

            // 2. Soigner (index 1, verrouillé si limite atteinte)
            _buildNavItem(
              index: 1,
              icon: Icons.favorite_rounded,
              label: strings.careDockLabel,
              isActive: _currentIndex == 1,
              isDark: isDark,
              isLocked: isLimitReached,
            ),

            // 3. Boutique (index 2, verrouillée si limite atteinte)
            _buildNavItem(
              index: 2,
              icon: Icons.storefront_rounded,
              label: strings.shopDockLabel,
              isActive: _currentIndex == 2,
              isDark: isDark,
              isLocked: isLimitReached,
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
    bool isLocked = false,
  }) {
    final effectiveIcon = isLocked ? Icons.lock_outline_rounded : icon;
    final itemOpacity = isLocked ? 0.45 : 1.0;

    return Expanded(
      child: Opacity(
        opacity: itemOpacity,
        child: GestureDetector(
          key: Key('nav_item_$index'),
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
                color: isActive
                    ? (isDark ? AppColors.darkSky500 : AppColors.sky500)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color:
                              (isDark ? AppColors.darkSky500 : AppColors.sky500)
                                  .withValues(alpha: 0.30),
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
                    effectiveIcon,
                    size: 20,
                    color: isActive
                        ? (isDark ? const Color(0xFF003640) : Colors.white)
                        : (isDark ? AppColors.darkInk500 : AppColors.ink500),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyS.copyWith(
                        fontWeight: isActive
                            ? FontWeight.w900
                            : FontWeight.w700,
                        fontSize: 12.5,
                        color: isActive
                            ? (isDark ? const Color(0xFF003640) : Colors.white)
                            : (isDark
                                  ? AppColors.darkInk600
                                  : AppColors.ink600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
