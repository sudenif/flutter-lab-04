import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../di/di.dart';
import '../features/features.dart';
import '../lab_stage.dart';
import '../widgets/app_error.dart';

GoRouter createRouter(LabStage stage) => GoRouter(
  initialLocation: '/home',
  observers: [TalkerRouteObserver(talker)],
  debugLogDiagnostics: true,
  routes: [
    GoRoute(path: '/home', builder: (_, state) => const HomeScreen()),
    GoRoute(
      path: '/content/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null || id <= 0) {
          return Scaffold(
            appBar: AppBar(title: const Text('Рецепт')),
            body: AppError(
              description: 'Некорректный идентификатор рецепта.',
              onRetry: () => context.go('/home'),
            ),
          );
        }
        return StaticContentScreen(contentId: id);
      },
    ),
    GoRoute(
      path: '/logs',
      builder: (_, state) => TalkerScreen(talker: talker),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Страница не найдена')),
    body: AppError(
      description: 'Такого адреса нет в приложении.',
      onRetry: () => context.go('/home'),
    ),
  ),
);
