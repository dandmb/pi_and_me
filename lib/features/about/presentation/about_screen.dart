import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../parent/presentation/widgets/parental_gate_dialog.dart';

/// Provider dynamique récupérant les métadonnées officielles de l'application (version, build, etc.)
final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

/// Écran « À propos de MathPup » (About).
/// Présente l'application, sa mission pédagogique, le profil du créateur Dan Bizwa,
/// ainsi que les liens de contact (Email & LinkedIn), protégés par le Parental Gate.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AboutScreen()),
    );
  }

  Future<void> _handleOpenLink(
    BuildContext context,
    WidgetRef ref, {
    required String url,
    required bool isMail,
  }) async {
    final strings = ref.read(stringsProvider);
    final messenger = ScaffoldMessenger.of(context);

    // Contrôle parental obligatoire (Google Play Families Policy)
    final unlocked = await ParentalGateDialog.show(context);
    if (unlocked != true || !context.mounted) return;

    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: isMail
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );

      if (!launched) {
        // En cas d'échec (ex. simulateur sans client mail), copie dans le presse-papier
        final copyText = isMail ? url.replaceFirst('mailto:', '') : url;
        await Clipboard.setData(ClipboardData(text: copyText));
        messenger.showSnackBar(
          SnackBar(
            content: Text('${strings.aboutCopiedFeedback} ($copyText)'),
            backgroundColor: AppColors.sky600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      final copyText = isMail ? url.replaceFirst('mailto:', '') : url;
      await Clipboard.setData(ClipboardData(text: copyText));
      messenger.showSnackBar(
        SnackBar(
          content: Text('${strings.aboutCopiedFeedback} ($copyText)'),
          backgroundColor: AppColors.sky600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _copyToClipboard(
    BuildContext context,
    WidgetRef ref,
    String text,
  ) async {
    final strings = ref.read(stringsProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(strings.aboutCopiedFeedback),
        backgroundColor: AppColors.green600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    await Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final packageInfoAsync = ref.watch(packageInfoProvider);
    final versionDisplay = packageInfoAsync.when(
      data: (info) => strings.versionLabel(info.version, info.buildNumber),
      loading: () => strings.aboutVersionLabel,
      error: (_, _) => strings.aboutVersionLabel,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.darkSurfaceAlt : AppColors.surface;
    final borderColor = isDark ? AppColors.darkInk200 : AppColors.ink200;
    final textColor = isDark ? AppColors.darkInk900 : AppColors.ink900;
    final subtitleColor = isDark ? AppColors.darkInk500 : AppColors.ink600;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: textColor,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          strings.aboutTitle,
          style: AppText.h3.copyWith(
            color: textColor,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpace.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. CARTE HERO / MASCOTTE
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.s5,
                  vertical: AppSpace.s6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF0F2B36), const Color(0xFF0C1F28)]
                        : [const Color(0xFFE0F7FC), const Color(0xFFF0FDFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                        : const Color(0xFFBAE6FD),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar Mascotte Pi
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.sky500,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.sky600.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🐶',
                          style: TextStyle(fontSize: 42),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.s3),

                    // Nom de l'app
                    Text(
                      'MathPup',
                      style: AppText.h1.copyWith(
                        color: textColor,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Slogan
                    Text(
                      strings.aboutTagline,
                      style: AppText.body.copyWith(
                        color: subtitleColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpace.s3),

                    // Badge de version
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.s3,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: isDark ? AppColors.darkInk200 : AppColors.ink200,
                        ),
                      ),
                      child: Text(
                        versionDisplay,
                        style: AppText.bodyS.copyWith(
                          color: AppColors.sky600,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.s4),

                    // Pastilles de points forts (Pills)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFeaturePill(
                          label: strings.aboutPillOffline,
                          icon: Icons.wifi_off_rounded,
                          color: AppColors.green600,
                          isDark: isDark,
                        ),
                        _buildFeaturePill(
                          label: strings.aboutPillNoAds,
                          icon: Icons.verified_user_rounded,
                          color: AppColors.gold600,
                          isDark: isDark,
                        ),
                        _buildFeaturePill(
                          label: strings.aboutPillPrivacy,
                          icon: Icons.lock_rounded,
                          color: AppColors.sky500,
                          isDark: isDark,
                        ),
                        _buildFeaturePill(
                          label: strings.aboutPillCurriculum,
                          icon: Icons.school_rounded,
                          color: const Color(0xFF8B5CF6),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpace.s4),

              // 2. MISSION PÉDAGOGIQUE
              Container(
                padding: const EdgeInsets.all(AppSpace.s5),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpace.s2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : AppColors.sky50,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            color: AppColors.sky600,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpace.s3),
                        Text(
                          strings.aboutMissionTitle,
                          style: AppText.h3.copyWith(
                            color: textColor,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.s3),
                    Text(
                      strings.aboutMissionText,
                      style: AppText.body.copyWith(
                        color: subtitleColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpace.s4),

              // 3. LE CRÉATEUR / DÉVELOPPEUR
              Container(
                padding: const EdgeInsets.all(AppSpace.s5),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpace.s2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.gold600,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpace.s3),
                        Text(
                          strings.aboutDeveloperSectionTitle,
                          style: AppText.h3.copyWith(
                            color: textColor,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.s4),

                    // Profil Dan Bizwa
                    Row(
                      children: [
                        // Initiales Avatar
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF006879), Color(0xFF004E5B)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.sky600.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'DB',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpace.s3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.aboutDeveloperName,
                                style: AppText.h3.copyWith(
                                  color: textColor,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                strings.aboutDeveloperRole,
                                style: AppText.bodyS.copyWith(
                                  color: AppColors.sky600,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.s3),
                    Text(
                      strings.aboutDeveloperBio,
                      style: AppText.body.copyWith(
                        color: subtitleColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpace.s4),

              // 4. CONTACT & RÉSEAUX (LIENS CLIQUABLES AVEC PARENTAL GATE)
              Container(
                padding: const EdgeInsets.all(AppSpace.s5),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpace.s2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(
                            Icons.alternate_email_rounded,
                            color: AppColors.green600,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpace.s3),
                        Text(
                          strings.aboutContactSectionTitle,
                          style: AppText.h3.copyWith(
                            color: textColor,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.s3),

                    // Avertissement de sécurité Google Play Families
                    Container(
                      padding: const EdgeInsets.all(AppSpace.s3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                            : AppColors.sky50,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkInk200
                              : const Color(0xFFBAE6FD),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 16,
                            color: AppColors.sky600,
                          ),
                          const SizedBox(width: AppSpace.s2),
                          Expanded(
                            child: Text(
                              strings.aboutParentalGateNotice,
                              style: AppText.bodyS.copyWith(
                                color: isDark
                                    ? AppColors.darkInk500
                                    : AppColors.sky700,
                                fontSize: 11.5,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpace.s4),

                    // TILE EMAIL
                    _buildContactTile(
                      context,
                      ref,
                      icon: Icons.email_rounded,
                      iconColor: const Color(0xFFEA4335),
                      title: strings.aboutEmailLabel,
                      value: strings.aboutEmailValue,
                      isDark: isDark,
                      onTap: () => _handleOpenLink(
                        context,
                        ref,
                        url: 'mailto:${strings.aboutEmailValue}',
                        isMail: true,
                      ),
                      onCopy: () => _copyToClipboard(
                        context,
                        ref,
                        strings.aboutEmailValue,
                      ),
                    ),

                    const SizedBox(height: AppSpace.s3),

                    // TILE LINKEDIN
                    _buildContactTile(
                      context,
                      ref,
                      icon: Icons.link_rounded,
                      iconColor: const Color(0xFF0A66C2),
                      title: strings.aboutLinkedInLabel,
                      value: strings.aboutLinkedInValue,
                      isDark: isDark,
                      onTap: () => _handleOpenLink(
                        context,
                        ref,
                        url: strings.aboutLinkedInValue,
                        isMail: false,
                      ),
                      onCopy: () => _copyToClipboard(
                        context,
                        ref,
                        strings.aboutLinkedInValue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpace.s6),

              // BOUTON RETOUR
              ChunkyButton(
                label: strings.close,
                variant: ChunkyButtonVariant.secondary,
                height: 48,
                onPressed: () => Navigator.of(context).pop(),
              ),

              const SizedBox(height: AppSpace.s4),

              // FOOTER MENTIONS LÉGALES
              Center(
                child: Column(
                  children: [
                    Text(
                      strings.aboutCopyright,
                      style: AppText.bodyS.copyWith(
                        color: subtitleColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MathPup — ${packageInfoAsync.valueOrNull?.packageName ?? 'com.danbizwa.mathpup'}',
                      style: AppText.bodyS.copyWith(
                        color: subtitleColor.withValues(alpha: 0.6),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.s4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePill({
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppText.bodyS.copyWith(
              color: isDark ? AppColors.darkInk900 : AppColors.ink900,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required bool isDark,
    required VoidCallback onTap,
    required VoidCallback onCopy,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkInk200 : AppColors.ink200,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppRadius.lg),
                ),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.s3,
                    vertical: AppSpace.s3,
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(icon, color: iconColor, size: 22),
                      ),
                      const SizedBox(width: AppSpace.s3),

                      // Labels
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppText.label.copyWith(
                                color: isDark
                                    ? AppColors.darkInk900
                                    : AppColors.ink900,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              value,
                              style: AppText.bodyS.copyWith(
                                color: AppColors.sky600,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Flèche ouvrir
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 18,
                        color: isDark ? AppColors.darkInk500 : AppColors.ink500,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 28,
            width: 1,
            color: isDark ? AppColors.darkInk200 : AppColors.ink200,
          ),
          // Bouton Copier
          IconButton(
            key: Key('copy_$value'),
            tooltip: 'Copier',
            icon: const Icon(Icons.copy_rounded, size: 18),
            color: isDark ? AppColors.darkInk500 : AppColors.ink500,
            onPressed: onCopy,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
