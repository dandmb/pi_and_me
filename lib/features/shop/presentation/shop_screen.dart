import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../care/presentation/care_controller.dart';
import '../../care/presentation/care_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../profile/domain/school_grade.dart';
import '../../profile/presentation/profile_controller.dart';
import '../domain/accessory_category.dart';
import '../domain/accessory_item.dart';
import '../domain/shop_state.dart';
import 'shop_controller.dart';
import 'widgets/accessory_overlay_widget.dart';

/// Écran 5 : La Boutique de Pi le chiot (Bilingue FR/EN).
/// Permet à l'enfant de dépenser ses Os dorés gagnés lors des quiz
/// pour débloquer, essayer et équiper des chapeaux, lunettes, colliers et capes.
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
      backgroundColor: AppColors.bg,
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

              // 2. Sélecteur de catégories d'accessoires (Chapeaux, Lunettes, Colliers, Capes)
              _buildCategorySelector(shopState.selectedCategory, shopNotifier, strings),

              const SizedBox(height: AppSpace.s2),

              // 3. Cabine d'essayage en direct avec Pi sur son socle
              _buildFittingRoom(previewId, previewItem, shopState, shopNotifier, strings),

              // 4. Message de retour / notification d'achat ou d'équipement
              if (shopState.feedbackMessage != null) ...[
                const SizedBox(height: AppSpace.s2),
                _buildFeedbackBanner(shopState.feedbackMessage!),
              ],

              const SizedBox(height: AppSpace.s2),

              // 5. Grille du catalogue d'articles
              Expanded(
                child: _buildCatalogGrid(
                  shopState,
                  shopNotifier,
                  companion.bones,
                  currentGrade,
                  strings,
                ),
              ),

              // 6. Barre de navigation inférieure (si non embarqué)
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
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink200, width: 1.5),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: AppColors.ink600,
            ),
          ),
        ),
        const SizedBox(width: AppSpace.s2),
        Expanded(
          child: Text(
            strings.shopTitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.h3.copyWith(color: AppColors.ink900, fontSize: 18),
          ),
        ),
        const SizedBox(width: AppSpace.s2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.amber50,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
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
                  color: AppColors.amber900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- SÉLECTEUR DE CATÉGORIES ---
  Widget _buildCategorySelector(
    AccessoryCategory selectedCategory,
    ShopController shopNotifier,
    dynamic strings,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AccessoryCategory.values.map((category) {
          final isSelected = category == selectedCategory;
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
                  color: isSelected ? AppColors.sky50 : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: isSelected ? AppColors.sky600 : AppColors.ink200,
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
                      color: isSelected ? AppColors.sky700 : AppColors.ink600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.getLabel(strings.isFrench),
                      style: AppText.bodyS.copyWith(
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                        color: isSelected ? AppColors.sky700 : AppColors.ink600,
                        fontSize: 12,
                      ),
                    ),
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
    final isPreviewEquipped = previewId != null && shopState.isEquipped(previewId);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s3, horizontal: AppSpace.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.ink200, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.ink100,
            offset: Offset(0, 3),
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
                  color: AppColors.sky50,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.sky500, width: 1),
                ),
                child: Text(
                  strings.fittingRoom.toUpperCase(),
                  style: AppText.bodyS.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.sky700,
                    letterSpacing: 0.5,
                    fontSize: 9,
                  ),
                ),
              ),
              if (previewId != null)
                GestureDetector(
                  onTap: () {
                    if (isPreviewEquipped) {
                      shopNotifier.unequipAccessory(isFrench: strings.isFrench);
                    } else {
                      shopNotifier.selectAccessory(''); // Déselectionne l'essai
                    }
                  },
                  child: Text(
                    isPreviewEquipped ? strings.unequipAction : 'Annuler l\'essai',
                    style: AppText.bodyS.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.coral500,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          // Pi sur son socle d'essayage avec l'accessoire superposé
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
                      color: const Color(0xFFE2E8F0),
                      borderRadius: const BorderRadius.all(Radius.elliptical(130, 24)),
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          offset: const Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),

                // Ombre douce de contact au sol
                Positioned(
                  bottom: 6,
                  child: Container(
                    width: 85,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.12),
                      borderRadius: const BorderRadius.all(Radius.elliptical(85, 12)),
                    ),
                  ),
                ),

                // Mascotte Pi
                Positioned(
                  bottom: 8,
                  child: Image.asset(
                    'assets/images/pi_transparent.png',
                    height: 105,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.pets,
                      size: 70,
                      color: AppColors.sky600,
                    ),
                  ),
                ),

                // Superposition de l'accessoire
                Positioned(
                  bottom: 8,
                  child: AccessoryOverlayWidget(
                    accessoryId: previewId,
                    piSize: 105,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Libellé de statut d'essayage
          Text(
            previewItem != null
                ? (isPreviewEquipped
                    ? strings.piWears(previewItem.getName(strings.isFrench))
                    : strings.piTries(previewItem.getName(strings.isFrench)))
                : strings.piNatural,
            style: AppText.bodyS.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.ink900,
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
        color: AppColors.sky50,
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
                color: AppColors.sky800,
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

        return GestureDetector(
          onTap: () => shopNotifier.selectAccessory(item.id),
          child: Container(
            padding: const EdgeInsets.all(AppSpace.s3),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: isSelected
                    ? AppColors.sky600
                    : (isEquipped ? AppColors.green500 : AppColors.ink200),
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
                  : const [
                      BoxShadow(
                        color: AppColors.ink100,
                        offset: Offset(0, 2),
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
                    color: item.primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: item.primaryColor.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    item.previewIcon,
                    size: 26,
                    color: item.primaryColor,
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
                    color: AppColors.ink900,
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
                        color: AppColors.ink500,
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
                            color: AppColors.amber900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ] else ...[
                  Text(
                    'Possédé',
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

  // --- BOUTON D'ACTION SELON L'ÉTAT DU PRODUIT ---
  Widget _buildItemActionButton({
    required AccessoryItem item,
    required bool isOwned,
    required bool isEquipped,
    required bool isUnlocked,
    required bool canAfford,
    required ShopController shopNotifier,
    required dynamic strings,
  }) {
    // 1. Déjà équipé
    if (isEquipped) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.sky50,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.sky600, width: 1.5),
        ),
        child: Text(
          strings.equippedBadge,
          textAlign: TextAlign.center,
          style: AppText.bodyS.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.sky700,
            fontSize: 11,
          ),
        ),
      );
    }

    // 2. Déjà possédé dans l'inventaire -> Bouton Équiper
    if (isOwned) {
      return ChunkyButton(
        label: strings.equipAction,
        variant: ChunkyButtonVariant.secondary,
        height: 32,
        onPressed: () => shopNotifier.equipAccessory(item.id, isFrench: strings.isFrench),
      );
    }

    // 3. Verrouillé par le niveau de classe
    if (!isUnlocked) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
        ),
        child: Text(
          'Verrouillé',
          textAlign: TextAlign.center,
          style: AppText.bodyS.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.ink500,
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

  // --- BARRE DE NAVIGATION INFÉRIEURE (DOCK) ---
  Widget _buildBottomDock(BuildContext context, dynamic strings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.ink200, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.ink100,
            offset: Offset(0, 2),
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
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const CareScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    size: 18,
                    color: AppColors.ink500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    strings.careDockLabel,
                    style: AppText.bodyS.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink500,
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
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.home_rounded,
                    size: 18,
                    color: AppColors.ink500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    strings.salonDockLabel,
                    style: AppText.bodyS.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink500,
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
              color: AppColors.sky50,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.sky500, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  size: 18,
                  color: AppColors.sky600,
                ),
                const SizedBox(width: 6),
                Text(
                  strings.shopDockLabel,
                  style: AppText.bodyS.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.sky700,
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
