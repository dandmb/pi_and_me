import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi_et_moi/core/audio/audio_service.dart';
import 'package:pi_et_moi/core/localization/locale_controller.dart';
import 'package:pi_et_moi/features/care/presentation/care_screen.dart';
import 'package:pi_et_moi/features/home/presentation/home_screen.dart';
import 'package:pi_et_moi/features/parent/presentation/parent_dashboard_screen.dart';
import 'package:pi_et_moi/features/profile/data/profile_repository.dart';
import 'package:pi_et_moi/features/profile/domain/child_profile.dart';
import 'package:pi_et_moi/features/profile/domain/school_grade.dart';
import 'package:pi_et_moi/features/profile/presentation/profile_controller.dart';
import 'package:pi_et_moi/features/quiz/data/quiz_stats_repository.dart';
import 'package:pi_et_moi/features/quiz/domain/quiz_session_record.dart';
import 'package:pi_et_moi/features/quiz/presentation/quiz_screen.dart';
import 'package:pi_et_moi/features/shop/presentation/shop_screen.dart';
import 'package:pi_et_moi/main.dart';

class _NoOpAudioPlayerClient implements AudioPlayerClient {
  @override
  Future<void> playAsset(String assetPath) async {}
  @override
  void dispose() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> saveScreenshot(WidgetTester tester, String filename) async {
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('capture_root')),
      );
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final file = File('android/store_assets/$filename');
        file.writeAsBytesSync(byteData.buffer.asUint8List());
        print('SAVED: $filename (${file.lengthSync()} bytes)');
      }
    });
  }

  testWidgets('Generate 5 Clean Android Store Screenshots', (tester) async {
    // Exact phone portrait resolution: 1080 x 2400 (aspect ratio 9:20)
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());

    await prefs.setBool('has_seen_onboarding_v1', true);
    await prefs.setBool('has_completed_care_showcase_v1', true);

    final child = ChildProfile.defaultProfile(
      name: 'Léa',
      grade: SchoolGrade.cm1,
    );
    final profileRepo = ProfileRepository(prefs: prefs);
    await profileRepo.saveProfile(child);

    final statsRepo = QuizStatsRepository(prefs: prefs);
    await statsRepo.recordSession(
      QuizSessionRecord(
        id: 'session_1',
        profileId: child.id,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        grade: SchoolGrade.cm1,
        totalQuestions: 6,
        correctAnswers: 5,
        totalByDomain: {
          'nombres_calculs': 2,
          'geometrie_espace': 2,
          'grandeurs_mesures': 1,
          'resolution_problemes': 1,
        },
        correctByDomain: {
          'nombres_calculs': 2,
          'geometrie_espace': 2,
          'grandeurs_mesures': 0,
          'resolution_problemes': 1,
        },
      ),
    );

    Widget buildApp({Widget? customHome}) {
      return ProviderScope(
        overrides: [
          languageProvider.overrideWith(
            (ref) => LanguageNotifier(systemLocaleCodeOverride: 'fr'),
          ),
          audioServiceProvider.overrideWithValue(
            AudioService(client: _NoOpAudioPlayerClient(), isSoundEnabled: false),
          ),
          profileRepositoryProvider.overrideWithValue(profileRepo),
          quizStatsRepositoryProvider.overrideWithValue(statsRepo),
        ],
        child: RepaintBoundary(
          key: const Key('capture_root'),
          child: customHome != null
              ? MaterialApp(home: customHome)
              : const MathPupApp(),
        ),
      );
    }

    // --- SCREEN 1 : LE SALON INTERACTIF AVEC PI ---
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    await saveScreenshot(tester, 'screenshot_1_salon.png');

    // --- SCREEN 2 : LES SOINS (DOUCHE & BIEN-ÊTRE) ---
    await tester.tap(find.byKey(const Key('nav_item_1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byType(CareScreen), findsOneWidget);
    await saveScreenshot(tester, 'screenshot_2_soins.png');

    // --- SCREEN 3 : LA BOUTIQUE & DRESSING ---
    await tester.tap(find.byKey(const Key('nav_item_2')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byType(ShopScreen), findsOneWidget);
    await saveScreenshot(tester, 'screenshot_3_dressing.png');

    // --- SCREEN 4 : UN QUIZ DE MATHS EN ACTION ---
    await tester.tap(find.byKey(const Key('nav_item_0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    final quizBtn = find.text('Jouer au Quiz');
    expect(quizBtn, findsOneWidget);
    await tester.tap(quizBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.byType(QuizScreen), findsOneWidget);
    await saveScreenshot(tester, 'screenshot_4_quiz.png');

    // --- SCREEN 5 : L'ESPACE PARENTS & STATISTIQUES ---
    await tester.pumpWidget(buildApp(customHome: const ParentDashboardScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byType(ParentDashboardScreen), findsOneWidget);
    await saveScreenshot(tester, 'screenshot_5_parents.png');
  });
}
