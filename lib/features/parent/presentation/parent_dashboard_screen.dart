import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../profile/domain/child_profile.dart';
import '../../profile/domain/school_grade.dart';
import '../../profile/presentation/profile_controller.dart';
import 'daily_limit_controller.dart';
import 'parent_dashboard_controller.dart';

/// Écran complet du Tableau de Bord Parental (Espace Parents).
/// Structuré en 3 onglets thématiques :
/// 1. Enfants & Quotas (Profils, classes, mode sans chrono, bonus sessions)
/// 2. Statistiques de Maths (Maîtrise par domaine officiel, taux de réussite)
/// 3. Données & RGPD (Engagement zéro pub, export JSON Art. 20, suppression Art. 17)
class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: context.appBg,
      appBar: AppBar(
        backgroundColor: context.appSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: context.appText,
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: AppColors.sky600,
                ),
                const SizedBox(width: AppSpace.s1),
                Flexible(
                  child: Text(
                    strings.parentDashboardTitle,
                    style: AppText.h3.copyWith(
                      color: context.appText,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              strings.parentDashboardBadge,
              style: AppText.bodyS.copyWith(
                color: context.appSubText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.sky600,
          unselectedLabelColor: context.appSubText,
          indicatorColor: AppColors.sky600,
          indicatorWeight: 3,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          labelStyle: AppText.label.copyWith(fontSize: 12),
          unselectedLabelStyle: AppText.bodyS.copyWith(fontSize: 12),
          tabs: [
            Tab(
              icon: const Icon(Icons.groups_rounded, size: 20),
              text: strings.parentTabChildren,
            ),
            Tab(
              icon: const Icon(Icons.insights_rounded, size: 20),
              text: strings.parentTabStats,
            ),
            Tab(
              icon: const Icon(Icons.shield_rounded, size: 20),
              text: strings.parentTabPrivacy,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_ChildrenTab(), _StatsTab(), _PrivacyTab()],
      ),
    );
  }
}

// ==========================================
// ONGLET 1 : ENFANTS & QUOTAS
// ==========================================
class _ChildrenTab extends ConsumerWidget {
  const _ChildrenTab();

  void _showAddChildDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    SchoolGrade selectedGrade = SchoolGrade.cm1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final strings = ref.watch(stringsProvider);
          return AlertDialog(
            backgroundColor: context.appSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            title: Text(
              strings.parentAddChild,
              style: AppText.h3.copyWith(color: context.appText),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: strings.nameLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.s3),
                  Text(
                    strings.selectGrade,
                    style: AppText.label.copyWith(color: context.appText),
                  ),
                  const SizedBox(height: AppSpace.s1),
                  DropdownButtonFormField<SchoolGrade>(
                    initialValue: selectedGrade,
                    items: SchoolGrade.values.map((grade) {
                      return DropdownMenuItem(
                        value: grade,
                        child: Text(
                          '${grade.label} (${grade.fullName})',
                          style: AppText.body.copyWith(color: context.appText),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedGrade = val);
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  strings.cancel,
                  style: AppText.buttonM.copyWith(color: context.appSubText),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sky600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    final newProfile = ChildProfile(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      avatar: 'avatar_dog',
                      grade: selectedGrade,
                      createdAt: DateTime.now(),
                    );
                    await ref
                        .read(activeProfileProvider.notifier)
                        .saveProfile(newProfile);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  }
                },
                child: Text(strings.save, style: AppText.buttonM),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditGradeDialog(
    BuildContext context,
    WidgetRef ref,
    ChildProfile profile,
  ) {
    SchoolGrade selected = profile.grade;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final strings = ref.watch(stringsProvider);
          return AlertDialog(
            backgroundColor: context.appSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            title: Text(
              '${strings.parentEditGradeTitle} - ${profile.name}',
              style: AppText.h3.copyWith(color: context.appText, fontSize: 18),
            ),
            content: DropdownButtonFormField<SchoolGrade>(
              initialValue: selected,
              items: SchoolGrade.values.map((g) {
                return DropdownMenuItem(
                  value: g,
                  child: Text(
                    '${g.label} - ${g.fullName}',
                    style: AppText.body.copyWith(color: context.appText),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setDialogState(() => selected = val);
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  strings.cancel,
                  style: AppText.buttonM.copyWith(color: context.appSubText),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sky600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                onPressed: () async {
                  final updated = profile.copyWith(grade: selected);
                  await ref
                      .read(activeProfileProvider.notifier)
                      .saveProfile(updated);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
                child: Text(strings.save, style: AppText.buttonM),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final profilesAsync = ref.watch(allProfilesProvider);
    final dashboardState = ref.watch(parentDashboardControllerProvider);
    final limitState = ref.watch(dailyLimitControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bannière recommandation Santé Publique
          Container(
            padding: const EdgeInsets.all(AppSpace.s4),
            decoration: BoxDecoration(
              color: context.isDark ? const Color(0xFF0F2537) : AppColors.sky50,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: context.isDark
                    ? const Color(0xFF1E3A8A)
                    : AppColors.sky500.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.health_and_safety_rounded,
                  color: AppColors.sky600,
                  size: 24,
                ),
                const SizedBox(width: AppSpace.s3),
                Expanded(
                  child: Text(
                    strings.parentSupervisionHeader,
                    style: AppText.bodyS.copyWith(
                      color: context.isDark
                          ? const Color(0xFF93C5FD)
                          : AppColors.ink900,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpace.s4),

          // Liste des profils enfants
          profilesAsync.when(
            data: (profiles) {
              if (profiles.isEmpty) {
                return Center(
                  child: Text(
                    strings.noProfiles,
                    style: AppText.body.copyWith(color: context.appSubText),
                  ),
                );
              }

              return Column(
                children: [
                  for (final profile in profiles)
                    _buildChildProfileCard(
                      context,
                      ref,
                      profile: profile,
                      strings: strings,
                      limitState: limitState,
                      isTimerFree: dashboardState.isTimerFree(profile.id),
                    ),
                  const SizedBox(height: AppSpace.s3),
                  if (profiles.length < 4)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: AppSpace.s4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          side: const BorderSide(
                            color: AppColors.sky600,
                            width: 2,
                          ),
                          backgroundColor: context.isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.surface,
                        ),
                        icon: const Icon(
                          Icons.add_rounded,
                          color: AppColors.sky600,
                          size: 20,
                        ),
                        label: Text(
                          strings.parentAddChild,
                          style: AppText.buttonM.copyWith(
                            color: AppColors.sky600,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        onPressed: () => _showAddChildDialog(context, ref),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpace.s5),
                child: CircularProgressIndicator(color: AppColors.sky600),
              ),
            ),
            error: (err, _) => Center(
              child: Text(
                'Erreur : $err',
                style: AppText.body.copyWith(color: AppColors.coral500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildProfileCard(
    BuildContext context,
    WidgetRef ref, {
    required ChildProfile profile,
    required dynamic strings,
    required dynamic limitState,
    required bool isTimerFree,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.s4),
      padding: const EdgeInsets.all(AppSpace.s4),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête de la carte : Avatar, Nom, Classe & Modifier
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.amber50,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🐾', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: AppText.h3.copyWith(
                        color: context.appText,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${profile.grade.label} • ${profile.grade.fullName}',
                      style: AppText.bodyS.copyWith(
                        color: context.appSubText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _showEditGradeDialog(context, ref, profile),
                child: Text(
                  strings.parentEditGrade,
                  style: AppText.bodyS.copyWith(
                    color: AppColors.sky600,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: AppSpace.s4),

          // 1. Réglage de la limite quotidienne : Stepper [ - ]  X / jour  [ + ]
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  strings.parentDailyLimitSetting,
                  style: AppText.label.copyWith(color: context.appText),
                ),
              ),
              const SizedBox(width: AppSpace.s2),
              // Stepper [-] X [+]
              Container(
                decoration: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF1E293B)
                      : AppColors.bg,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: context.appBorder, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouton DIMINUER [-]
                    IconButton(
                      key: Key('daily_limit_decrease_${profile.id}'),
                      icon: const Icon(Icons.remove_rounded, size: 18),
                      color: limitState.maxDailySessions > 1
                          ? AppColors.sky600
                          : context.appSubText.withValues(alpha: 0.3),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      tooltip: 'Diminuer la limite',
                      onPressed: limitState.maxDailySessions > 1
                          ? () => ref
                                .read(
                                  parentDashboardControllerProvider.notifier,
                                )
                                .setDailyLimit(limitState.maxDailySessions - 1)
                          : null,
                    ),
                    // Valeur actuelle (Lexend)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        strings.parentSessionsPerDay(
                          limitState.maxDailySessions,
                        ),
                        style: AppText.mathM.copyWith(
                          color: context.appText,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    // Bouton AUGMENTER [+]
                    IconButton(
                      key: Key('daily_limit_increase_${profile.id}'),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      color: limitState.maxDailySessions < 12
                          ? AppColors.sky600
                          : context.appSubText.withValues(alpha: 0.3),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      tooltip: 'Augmenter la limite',
                      onPressed: limitState.maxDailySessions < 12
                          ? () => ref
                                .read(
                                  parentDashboardControllerProvider.notifier,
                                )
                                .setDailyLimit(limitState.maxDailySessions + 1)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            strings.parentDailyLimitDesc,
            style: AppText.bodyS.copyWith(
              color: context.appSubText,
              fontSize: 11.5,
            ),
          ),

          const SizedBox(height: AppSpace.s3),

          // 2. Progression d'aujourd'hui & Déblocage / Reset
          Container(
            padding: const EdgeInsets.all(AppSpace.s3),
            decoration: BoxDecoration(
              color: context.isDark ? const Color(0xFF0F172A) : AppColors.bg,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.appBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        strings.parentTodayProgress,
                        style: AppText.bodyS.copyWith(
                          color: context.appSubText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpace.s2),
                    Text(
                      '${limitState.usedSessionsToday} / ${limitState.maxDailySessions} terminés',
                      style: AppText.mathM.copyWith(
                        color: limitState.isLimitReached
                            ? AppColors.night700
                            : AppColors.green600,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: limitState.progress,
                    minHeight: 6,
                    backgroundColor: context.isDark
                        ? AppColors.darkInk200
                        : AppColors.ink200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      limitState.isLimitReached
                          ? AppColors.night700
                          : AppColors.green500,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.s2),
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpace.s2,
                  runSpacing: AppSpace.s2,
                  children: [
                    // Bouton Remettre à zéro aujourd'hui
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(
                        Icons.refresh_rounded,
                        size: 14,
                        color: AppColors.ink500,
                      ),
                      label: Text(
                        strings.parentResetQuotaToday,
                        style: AppText.bodyS.copyWith(
                          color: AppColors.ink500,
                          fontSize: 11,
                        ),
                      ),
                      onPressed: limitState.usedSessionsToday > 0
                          ? () async {
                              await ref
                                  .read(
                                    parentDashboardControllerProvider.notifier,
                                  )
                                  .resetTodayQuota();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      strings.parentQuotaResetSuccess,
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColors.sky600,
                                  ),
                                );
                              }
                            }
                          : null,
                    ),
                    // Bouton +1 session bonus
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sky50,
                        foregroundColor: AppColors.sky700,
                        elevation: 0,
                        side: const BorderSide(
                          color: AppColors.sky500,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 15,
                      ),
                      label: Text(
                        strings.parentBonusSession,
                        style: AppText.bodyS.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                      onPressed: () async {
                        await ref
                            .read(parentDashboardControllerProvider.notifier)
                            .grantBonusSession();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(strings.parentBonusSessionSuccess),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.green600,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: AppSpace.s4),

          // Switch "Mode sans chrono"
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.parentTimerFreeMode,
                      style: AppText.label.copyWith(color: context.appText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      strings.parentTimerFreeDesc,
                      style: AppText.bodyS.copyWith(
                        color: context.appSubText,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.s2),
              Switch.adaptive(
                value: isTimerFree,
                activeTrackColor: AppColors.sky600,
                onChanged: (enabled) {
                  ref
                      .read(parentDashboardControllerProvider.notifier)
                      .toggleTimerFreeMode(profile.id, enabled);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// ONGLET 2 : STATISTIQUES DE MATHS
// ==========================================
class _StatsTab extends ConsumerWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final state = ref.watch(parentDashboardControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.totalQuizzesCompleted == 0) ...[
            Container(
              padding: const EdgeInsets.all(AppSpace.s3),
              decoration: BoxDecoration(
                color: AppColors.sky500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.sky500.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.sky600,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpace.s2),
                  Expanded(
                    child: Text(
                      strings.parentNoStatsYet,
                      style: AppText.bodyS.copyWith(
                        color: context.appText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.s4),
          ],

          // Résumé général : 2 cartes métriques côte à côte
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  icon: Icons.checklist_rounded,
                  value: '${state.totalQuizzesCompleted}',
                  label: strings.parentQuizzesCompletedTotal,
                  color: AppColors.sky600,
                ),
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: _buildMetricCard(
                  context,
                  icon: Icons.auto_graph_rounded,
                  value: '${(state.averageAccuracyRate * 100).toInt()}%',
                  label: strings.parentAverageSuccessRate,
                  color: AppColors.green600,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpace.s4),

          // Carte détaillée de la maîtrise par domaine mathématique
          Container(
            padding: const EdgeInsets.all(AppSpace.s4),
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.school_rounded,
                      color: AppColors.sky600,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpace.s2),
                    Text(
                      strings.parentMasteryRate,
                      style: AppText.h3.copyWith(
                        color: context.appText,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.s4),
                _buildDomainProgressBar(
                  context,
                  domain: strings.parentMathDomainNumbers,
                  rate: state.domainMastery['numbers'] ?? 0.0,
                  color: AppColors.sky600,
                ),
                const SizedBox(height: AppSpace.s3),
                _buildDomainProgressBar(
                  context,
                  domain: strings.parentMathDomainGeometry,
                  rate: state.domainMastery['geometry'] ?? 0.0,
                  color: AppColors.green600,
                ),
                const SizedBox(height: AppSpace.s3),
                _buildDomainProgressBar(
                  context,
                  domain: strings.parentMathDomainMeasures,
                  rate: state.domainMastery['measures'] ?? 0.0,
                  color: AppColors.gold600,
                ),
                const SizedBox(height: AppSpace.s3),
                _buildDomainProgressBar(
                  context,
                  domain: strings.parentMathDomainProblems,
                  rate: state.domainMastery['problems'] ?? 0.0,
                  color: AppColors.coral500,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpace.s4),

          // Carte de conformité programmes officiels Éducation Nationale
          Container(
            padding: const EdgeInsets.all(AppSpace.s4),
            decoration: BoxDecoration(
              color: context.isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: context.isDark
                    ? const Color(0xFF334155)
                    : AppColors.ink200,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.green600,
                  size: 26,
                ),
                const SizedBox(width: AppSpace.s3),
                Expanded(
                  child: Text(
                    strings.parentCurriculumNotice,
                    style: AppText.bodyS.copyWith(
                      color: context.isDark
                          ? const Color(0xFFCBD5E1)
                          : AppColors.ink900,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.s4),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: AppSpace.s2),
          Text(
            value,
            style: AppText.mathL.copyWith(
              color: context.appText,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppText.bodyS.copyWith(
              color: context.appSubText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainProgressBar(
    BuildContext context, {
    required String domain,
    required double rate,
    required Color color,
  }) {
    final percent = (rate * 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              domain,
              style: AppText.label.copyWith(
                color: context.appText,
                fontSize: 13,
              ),
            ),
            Text(
              '$percent%',
              style: AppText.mathM.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: rate,
            minHeight: 8,
            backgroundColor: context.isDark
                ? AppColors.darkInk200
                : AppColors.ink200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// ONGLET 3 : DONNÉES & RGPD
// ==========================================
class _PrivacyTab extends ConsumerWidget {
  const _PrivacyTab();

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final strings = ref.read(stringsProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          strings.parentDeleteDialogTitle,
          style: AppText.h3.copyWith(color: AppColors.coral500, fontSize: 18),
        ),
        content: Text(
          strings.parentDeleteDialogMessage,
          style: AppText.body.copyWith(color: context.appSubText, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              strings.parentDeleteDialogCancel,
              style: AppText.buttonM.copyWith(color: context.appSubText),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(parentDashboardControllerProvider.notifier)
                  .deleteEntireHouseholdData();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  (route) => false,
                );
              }
            },
            child: Text(
              strings.parentDeleteDialogConfirm,
              style: AppText.buttonM,
            ),
          ),
        ],
      ),
    );
  }

  void _showExportPreview(
    BuildContext context,
    String jsonText,
    dynamic strings,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                strings.parentExportTitle,
                style: AppText.h3.copyWith(
                  color: context.appText,
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              jsonText,
              style: AppText.mathXS.copyWith(
                color: context.appText,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sky600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(strings.parentExportCopied),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonText));
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Engagement Vie Privée & Zéro Pub
          Container(
            padding: const EdgeInsets.all(AppSpace.s4),
            decoration: BoxDecoration(
              color: context.isDark
                  ? const Color(0xFF064E3B)
                  : const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: context.isDark
                    ? const Color(0xFF059669)
                    : const Color(0xFFA7F3D0),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.green600,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpace.s2),
                    Expanded(
                      child: Text(
                        strings.parentPrivacyPledgeTitle,
                        style: AppText.label.copyWith(
                          color: context.isDark
                              ? const Color(0xFF6EE7B7)
                              : const Color(0xFF065F46),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.s2),
                Text(
                  strings.parentPrivacyPledgePoints,
                  style: AppText.bodyS.copyWith(
                    color: context.isDark
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFF047857),
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpace.s4),

          // 2. Portabilité des données (Art. 20 RGPD)
          Container(
            padding: const EdgeInsets.all(AppSpace.s4),
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.parentExportTitle,
                  style: AppText.h3.copyWith(
                    color: context.appText,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpace.s1),
                Text(
                  strings.parentExportDesc,
                  style: AppText.bodyS.copyWith(
                    color: context.appSubText,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppSpace.s3),
                ChunkyButton(
                  key: const Key('parent_export_json_button'),
                  label: strings.parentExportButton,
                  variant: ChunkyButtonVariant.secondary,
                  height: 48,
                  onPressed: () async {
                    final jsonText = await ref
                        .read(parentDashboardControllerProvider.notifier)
                        .exportHouseholdDataJson();
                    await Clipboard.setData(ClipboardData(text: jsonText));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            strings.parentExportCopied,
                            style: AppText.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.sky600,
                        ),
                      );
                      _showExportPreview(context, jsonText, strings);
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpace.s4),

          // 3. Zone Dangereuse : Droit à l'oubli (Art. 17 RGPD)
          Container(
            padding: const EdgeInsets.all(AppSpace.s4),
            decoration: BoxDecoration(
              color: context.isDark
                  ? const Color(0xFF450A0A)
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: context.isDark
                    ? const Color(0xFF991B1B)
                    : const Color(0xFFFCA5A5),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.delete_forever_rounded,
                      color: AppColors.coral500,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpace.s2),
                    Text(
                      strings.parentDangerZoneTitle,
                      style: AppText.h3.copyWith(
                        color: AppColors.coral500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.s2),
                Text(
                  strings.parentDangerZoneDesc,
                  style: AppText.bodyS.copyWith(
                    color: context.isDark
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFF991B1B),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppSpace.s3),
                ElevatedButton.icon(
                  key: const Key('parent_delete_household_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.coral500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: AppSpace.s4,
                    ),
                  ),
                  icon: const Icon(Icons.warning_amber_rounded, size: 20),
                  label: Text(
                    strings.parentDeleteHouseholdButton,
                    style: AppText.buttonM.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onPressed: () => _showDeleteConfirmation(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
