import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app/theme/theme.dart';

class RecipeApp extends StatelessWidget {
  const RecipeApp({required this.router, super.key});
  final GoRouter router;
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Книга рецептов',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    routerConfig: router,
  );
}
