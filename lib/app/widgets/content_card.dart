import 'package:flutter/material.dart';

import '../../data/models/content.dart';
import 'content_image.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({
    required this.content,
    required this.local,
    this.onTap,
    super.key,
  });
  final Content content;
  final bool local;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContentImage(
              content: content,
              local: local,
              width: 94,
              height: 108,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    content.cuisine,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Text(
                        '${content.totalMinutes} мин',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        '★ ${content.rating.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Padding(
                padding: EdgeInsets.only(top: 42, left: 4),
                child: Icon(Icons.chevron_right, size: 20),
              ),
          ],
        ),
      ),
    ),
  );
}
