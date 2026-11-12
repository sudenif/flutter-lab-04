import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/content.dart';
import '../../../di/di.dart';
import '../../widgets/widgets.dart';

class StaticContentScreen extends StatelessWidget {
  const StaticContentScreen({required this.contentId, super.key});
  final int contentId;
  @override
  Widget build(BuildContext context) {
    final content = getIt<List<Content>>()
        .where((item) => item.id == contentId)
        .firstOrNull;
    return Scaffold(
      appBar: detailAppBar(context),
      body: content == null
          ? AppError(
              description: 'Рецепт не найден в учебном наборе.',
              onRetry: () => context.go('/home'),
            )
          : ContentBody(content: content, local: true),
    );
  }
}

AppBar detailAppBar(BuildContext context) => AppBar(
  title: const Text('Рецепт'),
  leading: IconButton(
    tooltip: 'Назад к списку',
    icon: const Icon(Icons.arrow_back),
    onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
  ),
);

class ContentBody extends StatelessWidget {
  const ContentBody({required this.content, required this.local, super.key});
  final Content content;
  final bool local;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 820),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ContentImage(
                content: content,
                local: local,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              content.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              '${content.cuisine} • ${content.difficulty}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 9,
              runSpacing: 8,
              children: [
                _fact(Icons.schedule, '${content.totalMinutes} мин'),
                _fact(Icons.people_outline, '${content.servings} порц.'),
                _fact(
                  Icons.local_fire_department_outlined,
                  '${content.caloriesPerServing} ккал',
                ),
                _fact(Icons.star_outline, content.rating.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 24),
            Text('Ингредиенты', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final ingredient in content.ingredients)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            Text(
              'Приготовление',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < content.instructions.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        content.instructions[i],
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Text(
              'Данные: DummyJSON · Рецепт № ${content.id}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _fact(IconData icon, String text) => Chip(
    avatar: Icon(icon, size: 17),
    label: Text(text),
    visualDensity: VisualDensity.compact,
    side: BorderSide.none,
  );
}
