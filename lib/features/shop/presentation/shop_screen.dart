import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../care/presentation/care_controller.dart';
import '../../care/presentation/widgets/animated_pi_mascot.dart';
import '../../navigation/presentation/main_shell_screen.dart';
import '../../profile/domain/school_grade.dart';
import '../../profile/presentation/profile_controller.dart';
import '../domain/accessory_category.dart';
import '../domain/accessory_item.dart';
import '../domain/shop_state.dart';
import 'shop_controller.dart';

/// Onglets de navigation au sein de l'espace Boutique / Dressing
enum ShopTabMode { shop, wardrobe }

/// Écran 5 : La Boutique & Garde-robe de Pi le chiot (Bilingue FR/EN).
/// Permet à l'enfant :
/// 1. D'acheter de nouveaux accessoires avec ses Os dorés gagnés lors des quiz.
/// 2. De gérer sa garde-robe personnelle pour faire porter ou enlever les accessoires à Pi.
class ShopScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;

  const ShopScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  ShopTabMode _tabMode = ShopTabMode.shop;

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final companion = ref.watch(careControllerProvider);
    final shopState = ref.watch(shopControllerProvider);
    final shopNotifier = ref.read(shopControllerProvider.notifier);
    final profileAsync = ref.watch(activeProfileProvider);
    final currentGrade = profileAsync.value?.grade ?? SchoolGrade.cp;

    // L'accessoire actuellement essayé dans la cabine (soit la sélection, soit l'équipé)
    final previewId = shopState.selectedAccessoryId ?? shopState.equippedAccessoryId;
    final previewItem = ShopCatalog.findById(previewId);

    return Scaffold(
      backgroundColor: context.appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s4,
            vertical: AppSpace.s2,
          ),
          child: Column(
            children: [
              // 1. Barre supérieure (si non embarqué)
              if (!widget.isEmbedded) ...[
                _buildHeader(context, companion.bones, strings),
                const SizedBox(height: AppSpace.s2),
              ],

              // 2. Sélecteur d'onglets [ Boutique ] [ Garde-robe ]
              _buildTabSelector(shopState, strings),

              const SizedBox(height: AppSpace.s2),

              // 3. Sélecteur de catégories d'accessoires (Chapeaux, Lunettes, Colliers, Capes)
              _buildCategorySelector(shopState, shopNotifier, strings),

              const SizedBox(height: AppSpace.s2),

              // 4. Cabine d'essayage en direct avec Pi sur son socle
              _buildFittingRoom(previewId, previewItem, shopState, shopNotifier, strings),

              // 5. Message de retour / notification d'achat ou d'équipement
              if (shopState.feedbackMessage != null) ...[
                const SizedBox(height: AppSpace.s2),
                _buildFeedbackBanner(shopState.feedbackMessage!),
              ],

              const SizedBox(height: AppSpace.s2),

              // 6. Contenu actif : Grille du catalogue (Boutique) OU Dressing (Garde-robe)
              Expanded(
                child: _tabMode == ShopTabMode.shop
                    ? _buildCatalogGrid(
                        shopState,
                        shopNotifier,
                        companion.bones,
                        currentGrade,
                        strings,
                      )
                    : _buildWardrobeContent(
                        shopState,
                        shopNotifier,
                        strings,
                      ),
              ),

              // 7. Barre de navigation inférieure (si non embarqué)
              if (!widget.isEmbedded) ...[
                const SizedBox(height: AppSpace.s2),
                _buildBottomDock(context, strings),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- EN-TÊTE ---
  Widget _buildHeader(BuildContext context, int bonesCount, dynamic strings) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainShellScreen(initialIndex: 0)),
              (route) => false,
            );
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
        const SizedBox(width: AppSpace.s2),
        Expanded(
          child: Text(
            _tabMode == ShopTabMode.shop ? strings.shopTitle : strings.wardrobeTab,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.h3.copyWith(color: context.appText, fontSize: 18),
          ),
        ),
        const SizedBox(width: AppSpace.s2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 4),
          decoration: BoxDecoration(
            color: context.isDark ? const Color(0xFF451A03) : AppColors.amber50,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: context.isDark ? const Color(0xFFD97706) : const Color(0xFFFDE68A),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, size: 16, color: AppColors.gold600),
              const SizedBox(width: 4),
              Text(
                '$bonesCount',
                style: AppText.bodyS.copyWith(
                  fontWeight: FontWeight.w900,
                  color: context.isDark ? const Color(0xFFFDE68A) : AppColors.amber900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- SÉLECTEUR D'ONGLETS [ BOUTIQUE ] [ GARDE-ROBE ] ---
  Widget _buildTabSelector(ShopState shopState, dynamic strings) {
    final ownedCount = shopState.ownedAccessoryIds.length;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: context.appBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_tabMode != ShopTabMode.shop) {
                  setState(() {
                    _tabMode = ShopTabMode.shop;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _tabMode == ShopTabMode.shop
                      ? AppColors.sky600
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: 16,
                      color: _tabMode == ShopTabMode.shop ? Colors.white : context.appSubText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      strings.shopTab,
                      style: AppText.label.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _tabMode == ShopTabMode.shop ? Colors.white : context.appSubText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_tabMode != ShopTabMode.wardrobe) {
                  setState(() {
                    _tabMode = ShopTabMode.wardrobe;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _tabMode == ShopTabMode.wardrobe
                      ? AppColors.coral500
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.checkroom_rounded,
                      size: 16,
                      color: _tabMode == ShopTabMode.wardrobe ? Colors.white : context.appSubText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${strings.wardrobeTab}${ownedCount > 0 ? ' ($ownedCount)' : ''}',
                      style: AppText.label.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _tabMode == ShopTabMode.wardrobe ? Colors.white : context.appSubText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SÉLECTEUR DE CATÉGORIES ---
  Widget _buildCategorySelector(
    ShopState shopState,
    ShopController shopNotifier,
    dynamic strings,
  ) {
    final selectedCategory = shopState.selectedCategory;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AccessoryCategory.values.map((category) {
          final isSelected = category == selectedCategory;
          final hasEquippedInCat = shopState.equippedByCategory.containsKey(category);
          final hasPreviewInCat = shopState.previewByCategory.containsKey(category) &&
              shopState.previewByCategory[category] != shopState.equippedByCategory[category];

          return Padding(
            padding: const EdgeInsets.only(right: AppSpace.s2),
            child: GestureDetector(
              onTap: () => shopNotifier.selectCategory(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.s3,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (context.isDark ? AppColors.darkSky50 : AppColors.sky50)
                      : context.appSurface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: isSelected ? AppColors.sky600 : context.appBorder,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: AppColors.sky700,
                            offset: Offset(0, 2),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      size: 15,
                      color: isSelected
                          ? (context.isDark ? AppColors.darkSky500 : AppColors.sky700)
                          : context.appSubText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.getLabel(strings.isFrench),
                      style: AppText.bodyS.copyWith(
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                        color: isSelected
                            ? (context.isDark ? AppColors.darkSky500 : AppColors.sky700)
                            : context.appSubText,
                        fontSize: 12,
                      ),
                    ),
                    if (hasEquippedInCat || hasPreviewInCat) ...[
                      const SizedBox(width: 5),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: hasPreviewInCat
                              ? AppColors.sky500
                              : AppColors.green500,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- CABINE D'ESSAYAGE EN DIRECT ---
  Widget _buildFittingRoom(
    String? previewId,
    AccessoryItem? previewItem,
    ShopState shopState,
    ShopController shopNotifier,
    dynamic strings,
  ) {
    final activeIds = shopState.activeFittingRoomIds;
    final unequippedPreviews = shopState.unequippedPreviewIds;
    final hasAnyEquipped = shopState.equippedAccessoryIds.isNotEmpty;
    final isPreviewEquipped =
        unequippedPreviews.isEmpty && hasAnyEquipped;

    final activeNames = activeIds
        .map((id) => ShopCatalog.findById(id)?.getName(strings.isFrench))
        .whereType<String>()
        .toList();
    final combinedNamesLabel = activeNames.join(' + ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s3, horizontal: AppSpace.s4),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: context.appBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: context.appShadow,
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Badge titre de la cabine
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: context.isDark ? AppColors.darkSky50 : AppColors.sky50,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.sky500, width: 1),
                ),
                child: Text(
                  _tabMode == ShopTabMode.wardrobe
                      ? strings.dressingTitle.toUpperCase()
                      : strings.fittingRoom.toUpperCase(),
                  style: AppText.bodyS.copyWith(
                    fontWeight: FontWeight.w900,
                    color: context.isDark ? AppColors.darkSky500 : AppColors.sky700,
                    letterSpacing: 0.5,
                    fontSize: 9,
                  ),
                ),
              ),
              if (_tabMode == ShopTabMode.wardrobe) ...[
                if (hasAnyEquipped)
                  GestureDetector(
                    onTap: () {
                      shopNotifier.unequipAccessory(isFrench: strings.isFrench);
                    },
                    child: Text(
                      strings.unequipAll,
                      style: AppText.bodyS.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.coral500,
                        fontSize: 11,
                      ),
                    ),
                  )
                else if (unequippedPreviews.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      shopNotifier.selectAccessory('');
                    },
                    child: Text(
                      strings.cancelPreview,
                      style: AppText.bodyS.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.coral500,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ] else ...[
                if (activeIds.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      if (isPreviewEquipped) {
                        final catId = shopState
                            .equippedByCategory[shopState.selectedCategory];
                        shopNotifier.unequipAccessory(
                          id: catId,
                          isFrench: strings.isFrench,
                        );
                      } else {
                        shopNotifier.selectAccessory(''); // Déselectionne l'essai
                      }
                    },
                    child: Text(
                      isPreviewEquipped ? strings.unequipAction : strings.cancelPreview,
                      style: AppText.bodyS.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.coral500,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ],
          ),

          const SizedBox(height: 6),

          // Pi sur son socle d'essayage avec tous les accessoires combinés superposés
          SizedBox(
            height: 125,
            width: 140,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Socle 3D d'essayage
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 130,
                    height: 24,
                    decoration: BoxDecoration(
                      color: context.isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      borderRadius: const BorderRadius.all(Radius.elliptical(130, 24)),
                      border: Border.all(color: context.isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: context.isDark ? 0.3 : 0.08),
                          offset: const Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),

                // Mascotte Pi animée (queue qui bat, clignement des yeux sous les lunettes et tenues combinées)
                Positioned(
                  bottom: 4,
                  child: AnimatedPiMascot(
                    piSize: 105,
                    equippedAccessoryIds: activeIds,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Libellé de statut d'essayage ou de tenue combinée
          Text(
            activeNames.isNotEmpty
                ? (isPreviewEquipped
                    ? strings.piWears(combinedNamesLabel)
                    : strings.piTries(combinedNamesLabel))
                : strings.piNatural,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodyS.copyWith(
              fontWeight: FontWeight.w800,
              color: context.appText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // --- BANNIÈRE DE FEEDBACK (ACHAT / ÉQUIPEMENT) ---
  Widget _buildFeedbackBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 7),
      decoration: BoxDecoration(
        color: context.isDark ? AppColors.darkSky50 : AppColors.sky50,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.sky500, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.sky600),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              message,
              style: AppText.bodyS.copyWith(
                fontWeight: FontWeight.w800,
                color: context.isDark ? AppColors.darkSky500 : AppColors.sky800,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // --- GRILLE DU CATALOGUE ---
  Widget _buildCatalogGrid(
    ShopState shopState,
    ShopController shopNotifier,
    int userBones,
    SchoolGrade currentGrade,
    dynamic strings,
  ) {
    final items = ShopCatalog.getByCategory(shopState.selectedCategory);

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpace.s3,
        mainAxisSpacing: AppSpace.s3,
        childAspectRatio: 0.82,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = shopState.isOwned(item.id);
        final isEquipped = shopState.isEquipped(item.id);
        final isSelected = shopState.isSelected(item.id);
        final isUnlocked = item.isGradeUnlocked(currentGrade);
        final previewColor = (context.isDark && item.primaryColor.computeLuminance() < 0.2)
            ? item.accentColor
            : item.primaryColor;

        return GestureDetector(
          onTap: () => shopNotifier.selectAccessory(item.id),
          child: Container(
            padding: const EdgeInsets.all(AppSpace.s3),
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: isSelected
                    ? AppColors.sky600
                    : (isEquipped ? AppColors.green500 : context.appBorder),
                width: isSelected || isEquipped ? 2 : 1.5,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: AppColors.sky700,
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: context.appShadow,
                        offset: const Offset(0, 2),
                        blurRadius: 0,
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icône circulaire de prévisualisation
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: previewColor.withValues(alpha: context.isDark ? 0.25 : 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: previewColor.withValues(alpha: context.isDark ? 0.5 : 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    item.previewIcon,
                    size: 26,
                    color: previewColor,
                  ),
                ),

                // Nom de l'article
                Text(
                  item.getName(strings.isFrench),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyS.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.appText,
                    fontSize: 13,
                  ),
                ),

                // Prix ou condition de niveau
                if (!isOwned) ...[
                  if (!isUnlocked)
                    Text(
                      strings.lockedGrade(item.requiredGrade!.label),
                      style: AppText.bodyS.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.appSubText,
                        fontSize: 11,
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stars_rounded, size: 14, color: AppColors.gold600),
                        const SizedBox(width: 4),
                        Text(
                          '${item.price}',
                          style: AppText.bodyS.copyWith(
                            fontWeight: FontWeight.w900,
                            color: context.isDark ? const Color(0xFFFDE68A) : AppColors.amber900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ] else ...[
                  Text(
                    strings.ownedBadge,
                    style: AppText.bodyS.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.green600,
                      fontSize: 11,
                    ),
                  ),
                ],

                // Bouton d'action contextuel
                _buildItemActionButton(
                  item: item,
                  isOwned: isOwned,
                  isEquipped: isEquipped,
                  isUnlocked: isUnlocked,
                  canAfford: userBones >= item.price,
                  shopNotifier: shopNotifier,
                  strings: strings,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- BOUTON D'ACTION SELON L'ÉTAT DU PRODUIT DANS LA BOUTIQUE ---
  Widget _buildItemActionButton({
    required AccessoryItem item,
    required bool isOwned,
    required bool isEquipped,
    required bool isUnlocked,
    required bool canAfford,
    required ShopController shopNotifier,
    required dynamic strings,
  }) {
    // 1. Déjà équipé sur Pi
    if (isEquipped) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: context.isDark ? AppColors.darkSky50 : AppColors.sky50,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.sky600, width: 1.5),
        ),
        child: Text(
          strings.equippedBadge,
          textAlign: TextAlign.center,
          style: AppText.bodyS.copyWith(
            fontWeight: FontWeight.w900,
            color: context.isDark ? AppColors.darkSky500 : AppColors.sky700,
            fontSize: 11,
          ),
        ),
      );
    }

    // 2. Déjà possédé dans l'inventaire -> Bouton « Dans la garde-robe » (redirige vers le dressing)
    if (isOwned) {
      return ChunkyButton(
        label: strings.inWardrobe,
        variant: ChunkyButtonVariant.secondary,
        height: 32,
        onPressed: () {
          setState(() {
            _tabMode = ShopTabMode.wardrobe;
          });
          shopNotifier.selectAccessory(item.id);
        },
      );
    }

    // 3. Verrouillé par le niveau de classe
    if (!isUnlocked) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: context.isDark ? AppColors.darkSurfaceAlt : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: context.isDark ? AppColors.darkInk200 : const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
        child: Text(
          strings.lockedBadge,
          textAlign: TextAlign.center,
          style: AppText.bodyS.copyWith(
            fontWeight: FontWeight.w700,
            color: context.appSubText,
            fontSize: 11,
          ),
        ),
      );
    }

    // 4. Disponible à l'achat avec les Os dorés
    return ChunkyButton(
      label: strings.buyAction(item.price),
      variant: ChunkyButtonVariant.primary,
      height: 32,
      onPressed: () {
        final careNotifier = ref.read(careControllerProvider.notifier);
        shopNotifier.buyAccessory(
          item: item,
          careNotifier: careNotifier,
          isFrench: strings.isFrench,
        );
      },
    );
  }

  // --- CONTENU DE LA GARDE-ROBE (DRESSING) ---
  Widget _buildWardrobeContent(
    ShopState shopState,
    ShopController shopNotifier,
    dynamic strings,
  ) {
    if (shopState.ownedAccessoryIds.isEmpty) {
      return _buildEmptyWardrobe(strings);
    }
    return _buildWardrobeGrid(shopState, shopNotifier, strings);
  }

  // --- ÉTAT VIDE DE LA GARDE-ROBE ---
  Widget _buildEmptyWardrobe(dynamic strings) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.s4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: context.isDark ? AppColors.darkSurfaceAlt : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: context.appBorder, width: 2),
              ),
              child: const Icon(
                Icons.checkroom_rounded,
                size: 34,
                color: AppColors.coral500,
              ),
            ),
            const SizedBox(height: AppSpace.s3),
            Text(
              strings.wardrobeEmptyTitle,
              style: AppText.h3.copyWith(color: context.appText, fontSize: 18),
            ),
            const SizedBox(height: AppSpace.s1),
            Text(
              strings.wardrobeEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppText.bodyS.copyWith(color: context.appSubText, fontSize: 13),
            ),
            const SizedBox(height: AppSpace.s4),
            SizedBox(
              width: 200,
              child: ChunkyButton(
                label: strings.goToShop,
                icon: const Icon(Icons.shopping_bag_rounded, size: 16, color: Colors.white),
                variant: ChunkyButtonVariant.primary,
                height: 40,
                onPressed: () {
                  setState(() {
                    _tabMode = ShopTabMode.shop;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- GRILLE DES ARTICLES DANS LA GARDE-ROBE ---
  Widget _buildWardrobeGrid(
    ShopState shopState,
    ShopController shopNotifier,
    dynamic strings,
  ) {
    final allCategoryItems = ShopCatalog.getByCategory(shopState.selectedCategory);
    final ownedItems = allCategoryItems.where((item) => shopState.isOwned(item.id)).toList();

    if (ownedItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                shopState.selectedCategory.icon,
                size: 40,
                color: context.appSubText.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpace.s2),
              Text(
                strings.noItemsInCategory,
                textAlign: TextAlign.center,
                style: AppText.bodyS.copyWith(
                  color: context.appSubText,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppSpace.s3),
              SizedBox(
                width: 180,
                child: ChunkyButton(
                  label: strings.goToShop,
                  icon: const Icon(Icons.shopping_bag_rounded, size: 16, color: Colors.white),
                  variant: ChunkyButtonVariant.primary,
                  height: 36,
                  onPressed: () {
                    setState(() {
                      _tabMode = ShopTabMode.shop;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpace.s3,
        mainAxisSpacing: AppSpace.s3,
        childAspectRatio: 0.82,
      ),
      itemCount: ownedItems.length,
      itemBuilder: (context, index) {
        final item = ownedItems[index];
        final isEquipped = shopState.isEquipped(item.id);
        final isSelected = shopState.isSelected(item.id);
        final previewColor = (context.isDark && item.primaryColor.computeLuminance() < 0.2)
            ? item.accentColor
            : item.primaryColor;

        return GestureDetector(
          onTap: () => shopNotifier.selectAccessory(item.id),
          child: Container(
            padding: const EdgeInsets.all(AppSpace.s3),
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: isSelected
                    ? AppColors.coral500
                    : (isEquipped ? AppColors.green500 : context.appBorder),
                width: isSelected || isEquipped ? 2 : 1.5,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: AppColors.coral500,
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: context.appShadow,
                        offset: const Offset(0, 2),
                        blurRadius: 0,
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: previewColor.withValues(alpha: context.isDark ? 0.25 : 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: previewColor.withValues(alpha: context.isDark ? 0.5 : 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    item.previewIcon,
                    size: 26,
                    color: previewColor,
                  ),
                ),
                Text(
                  item.getName(strings.isFrench),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyS.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.appText,
                    fontSize: 13,
                  ),
                ),
                Text(
                  isEquipped ? strings.equippedBadge : strings.ownedBadge,
                  style: AppText.bodyS.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isEquipped ? AppColors.green600 : context.appSubText,
                    fontSize: 11,
                  ),
                ),
                if (isEquipped)
                  ChunkyButton(
                    label: strings.unequipAction,
                    variant: ChunkyButtonVariant.secondary,
                    height: 32,
                    onPressed: () => shopNotifier.unequipAccessory(
                      id: item.id,
                      isFrench: strings.isFrench,
                    ),
                  )
                else
                  ChunkyButton(
                    label: strings.wearAction,
                    variant: ChunkyButtonVariant.primary,
                    height: 32,
                    onPressed: () => shopNotifier.equipAccessory(item.id, isFrench: strings.isFrench),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- BARRE DE NAVIGATION INFÉRIEURE (DOCK) ---
  Widget _buildBottomDock(BuildContext context, dynamic strings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 6),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: context.appBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: context.appShadow,
            offset: const Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Soigner
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainShellScreen(initialIndex: 1)),
                (route) => false,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    size: 18,
                    color: context.appSubText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    strings.careDockLabel,
                    style: AppText.bodyS.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.appSubText,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Salon
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainShellScreen(initialIndex: 0)),
                (route) => false,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.home_rounded,
                    size: 18,
                    color: context.appSubText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    strings.salonDockLabel,
                    style: AppText.bodyS.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.appSubText,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Boutique (Actif)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4, vertical: 6),
            decoration: BoxDecoration(
              color: context.isDark ? AppColors.darkSky50 : AppColors.sky50,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.sky500, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.storefront_rounded,
                  size: 18,
                  color: context.isDark ? AppColors.darkSky500 : AppColors.sky600,
                ),
                const SizedBox(width: 6),
                Text(
                  strings.shopDockLabel,
                  style: AppText.bodyS.copyWith(
                    fontWeight: FontWeight.w900,
                    color: context.isDark ? AppColors.darkSky500 : AppColors.sky700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
