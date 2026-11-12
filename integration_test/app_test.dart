import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recipe_catalog/app/lab_stage.dart';
import 'package:recipe_catalog/app/router/router.dart';
import 'package:recipe_catalog/di/di.dart';
import 'package:recipe_catalog/recipe_app.dart';
import 'package:recipe_catalog/data/repositories/content_repository.dart';
import 'package:recipe_catalog/data/repositories/content_repository_interface.dart';

/// Нативная проверка только этого этапа; снимки создаются из настоящих кадров Flutter.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final captureKey = GlobalKey();

  Future<void> capture(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary =
          captureKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory(
        const String.fromEnvironment(
          'EVIDENCE_DIR',
          defaultValue: 'test_screenshots',
        ),
      );
      await dir.create(recursive: true);
      await File('${dir.path}/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 150; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) return;
    }
    expect(finder, findsWidgets);
  }

  testWidgets('network failure and retry recover using a real HTTP client', (
    tester,
  ) async {
    await getIt.reset();
    await setupLocator();
    await getIt.unregister<ContentRepositoryInterface>();
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://127.0.0.1:1',
        connectTimeout: const Duration(seconds: 2),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    getIt.registerSingleton<ContentRepositoryInterface>(
      ContentRepository(dio: dio),
    );
    final router = createRouter(LabStage.lab4);
    await tester.pumpWidget(
      RepaintBoundary(
        key: captureKey,
        child: RecipeApp(router: router),
      ),
    );
    await waitFor(tester, find.text('Не удалось загрузить данные'));
    await capture(tester, 'lab4_network_error');
    dio.options.baseUrl = 'https://dummyjson.com';
    await tester.tap(find.text('Повторить'));
    await waitFor(tester, find.text('Что приготовим?'));
    expect(find.text('Chocolate Chip Cookies'), findsOneWidget);
    await capture(tester, 'lab4_retry_success');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    router.dispose();
    dio.close();
    await getIt.reset();
  });

  for (final stage in LabStage.values) {
    testWidgets(
      '${stage.name} screens and navigation on a real Windows device',
      (tester) async {
        await getIt.reset();
        await setupLocator();
        final router = createRouter(stage);
        await tester.pumpWidget(
          RepaintBoundary(
            key: captureKey,
            child: RecipeApp(router: router),
          ),
        );
        await waitFor(tester, find.text('Что приготовим?'));
        expect(find.text('Chocolate Chip Cookies'), findsOneWidget);
        await capture(tester, '${stage.name}_list');

        if (stage.hasDetails) {
          await tester.ensureVisible(find.text('Chocolate Chip Cookies'));
          await tester.tap(find.text('Chocolate Chip Cookies'));
          await waitFor(tester, find.text('Ингредиенты'));
          expect(find.text('Chocolate Chip Cookies'), findsOneWidget);
          await capture(tester, '${stage.name}_detail');
          await tester.drag(
            find.byType(SingleChildScrollView).first,
            const Offset(0, -520),
          );
          await capture(tester, '${stage.name}_steps');
          await tester.tap(find.byTooltip('Назад к списку'));
          await waitFor(tester, find.text('Книга рецептов'));
          expect(find.text('Chocolate Chip Cookies'), findsOneWidget);
        }

        if (stage.usesApiDetails) {
          router.go('/content/9999');
          await waitFor(
            tester,
            find.text('Рецепт не найден. Проверьте его номер.'),
          );
          await capture(tester, 'lab5_error_404');
          router.go('/content/not-a-number');
          await tester.pumpAndSettle();
          expect(
            find.text('Некорректный идентификатор рецепта.'),
            findsOneWidget,
          );
          await capture(tester, 'lab5_invalid_id');
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        router.dispose();
        await getIt.reset();
      },
    );
  }
}
