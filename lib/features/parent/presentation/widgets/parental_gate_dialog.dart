import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../domain/parental_gate_challenge.dart';

/// Dialogue modal anti-contournement pour l'accès aux fonctions adultes (Espace Parents).
/// Présente un défi arithmétique écrit en toutes lettres et gère un verrouillage anti-bruteforce.
class ParentalGateDialog extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;
  final ParentalGateChallenge? initialChallenge;
  final ParentalGateChallengeGenerator? generator;
  final ParentalGateLockoutManager? lockoutManager;

  const ParentalGateDialog({
    super.key,
    this.onSuccess,
    this.initialChallenge,
    this.generator,
    this.lockoutManager,
  });

  /// Affiche le dialogue modal de Parental Gate.
  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onSuccess,
    ParentalGateChallenge? testChallenge,
    ParentalGateLockoutManager? testLockoutManager,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ParentalGateDialog(
        onSuccess: onSuccess,
        initialChallenge: testChallenge,
        lockoutManager: testLockoutManager,
      ),
    );
  }

  @override
  ConsumerState<ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends ConsumerState<ParentalGateDialog> {
  late final ParentalGateChallengeGenerator _generator;
  late final ParentalGateLockoutManager _lockoutManager;
  late ParentalGateChallenge _currentChallenge;
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String? _errorMessage;
  Timer? _lockoutTimer;
  int _lockoutSecondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _generator = widget.generator ?? ParentalGateChallengeGenerator();
    _lockoutManager = widget.lockoutManager ?? ParentalGateLockoutManager();
    _currentChallenge = widget.initialChallenge ?? _generator.generate();

    if (_lockoutManager.isLocked) {
      _startLockoutCountdown();
    }
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _regenerateChallenge() {
    if (_lockoutManager.isLocked) return;
    setState(() {
      _currentChallenge = _generator.generate();
      _errorMessage = null;
      _inputController.clear();
    });
  }

  void _startLockoutCountdown() {
    _lockoutTimer?.cancel();
    setState(() {
      _lockoutSecondsRemaining = _lockoutManager.remainingSeconds;
    });

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = _lockoutManager.remainingSeconds;
      if (remaining <= 0) {
        timer.cancel();
        _lockoutManager.reset();
        setState(() {
          _lockoutSecondsRemaining = 0;
          _errorMessage = null;
          _currentChallenge = _generator.generate();
        });
      } else {
        setState(() {
          _lockoutSecondsRemaining = remaining;
        });
      }
    });
  }

  void _submitAnswer() {
    if (_lockoutManager.isLocked) return;

    final strings = ref.read(stringsProvider);
    final input = _inputController.text;

    if (_currentChallenge.verify(input)) {
      _lockoutManager.reset();
      Navigator.of(context).pop(true);
      widget.onSuccess?.call();
    } else {
      final justLocked = _lockoutManager.recordFailure();
      _inputController.clear();

      if (justLocked) {
        _startLockoutCountdown();
      } else {
        setState(() {
          _errorMessage = strings.parentGateAttemptsLeft(
            _lockoutManager.remainingAttempts,
          );
          _currentChallenge = _generator.generate();
        });
        _focusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final isFrench = strings.isFrench;
    final isLocked = _lockoutManager.isLocked || _lockoutSecondsRemaining > 0;

    return Dialog(
      backgroundColor: context.appSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s5,
        vertical: AppSpace.s4,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.s5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. En-tête : Cadenas & Titre
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpace.s2),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? const Color(0xFF1E293B)
                          : AppColors.sky50,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: context.isDark
                            ? const Color(0xFF334155)
                            : context.appBorder,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: AppColors.sky600,
                      size: 24,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 24),
                    color: context.appSubText,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: AppSpace.s3),

              Text(
                strings.parentGateTitle,
                style: AppText.h3.copyWith(color: context.appText),
              ),

              const SizedBox(height: AppSpace.s1),

              Text(
                strings.parentGateSubtitle,
                style: AppText.bodyS.copyWith(
                  color: context.appSubText,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: AppSpace.s4),

              // 2. Défi mathématique textuel
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.s4,
                  vertical: AppSpace.s3,
                ),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF0F172A)
                      : AppColors.bg,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isLocked
                        ? (context.isDark
                              ? const Color(0xFF7F1D1D)
                              : const Color(0xFFFCA5A5))
                        : (context.isDark
                              ? const Color(0xFF334155)
                              : AppColors.ink200),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _currentChallenge.getQuestion(isFrench),
                        style: AppText.label.copyWith(
                          color: context.appText,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    if (!isLocked)
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 22),
                        color: AppColors.sky600,
                        tooltip: 'Nouveau calcul',
                        onPressed: _regenerateChallenge,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpace.s4),

              // 3. Champ de saisie ou état de verrouillage
              if (isLocked) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpace.s4),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? const Color(0xFF450A0A)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: context.isDark
                          ? const Color(0xFF991B1B)
                          : const Color(0xFFF87171),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_off_outlined,
                        color: AppColors.coral500,
                        size: 28,
                      ),
                      const SizedBox(width: AppSpace.s3),
                      Expanded(
                        child: Text(
                          strings.parentGateLockout(_lockoutSecondsRemaining),
                          style: AppText.body.copyWith(
                            color: context.isDark
                                ? const Color(0xFFFCA5A5)
                                : AppColors.coral500,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  strings.parentGateInstruction,
                  style: AppText.bodyS.copyWith(
                    color: context.appText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpace.s2),
                TextField(
                  key: const Key('parental_gate_input'),
                  controller: _inputController,
                  focusNode: _focusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                  ],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submitAnswer(),
                  style: AppText.mathL.copyWith(
                    color: context.appText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: InputDecoration(
                    hintText: strings.parentGatePlaceholder,
                    hintStyle: AppText.mathL.copyWith(
                      color: context.appSubText.withValues(alpha: 0.5),
                      fontSize: 20,
                    ),
                    filled: true,
                    fillColor: context.isDark
                        ? const Color(0xFF0F172A)
                        : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.s4,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide(
                        color: _errorMessage != null
                            ? AppColors.coral500
                            : context.appBorder,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide(
                        color: _errorMessage != null
                            ? AppColors.coral500
                            : context.appBorder,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: const BorderSide(
                        color: AppColors.sky600,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpace.s2),
                  Text(
                    _errorMessage!,
                    style: AppText.bodyS.copyWith(
                      color: AppColors.coral500,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],

              const SizedBox(height: AppSpace.s5),

              // 4. Bouton de validation
              ChunkyButton(
                key: const Key('parental_gate_submit_button'),
                label: strings.parentGateValidate,
                variant: ChunkyButtonVariant.primary,
                height: 50,
                onPressed: isLocked ? null : _submitAnswer,
              ),

              const SizedBox(height: AppSpace.s2),

              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  strings.cancel,
                  style: AppText.buttonM.copyWith(color: context.appSubText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
