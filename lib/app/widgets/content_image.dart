import 'package:flutter/material.dart';

import '../../data/models/content.dart';

class ContentImage extends StatelessWidget {
  const ContentImage({
    required this.content,
    required this.local,
    this.width,
    this.height,
    super.key,
  });
  final Content content;
  final bool local;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    Widget fallback(BuildContext context, Object error, StackTrace? stack) =>
        Container(
          width: width,
          height: height,
          color: const Color(0xFFE3EAE2),
          child: const Center(child: Icon(Icons.restaurant, size: 40)),
        );
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: local
          ? Image.asset(
              'assets/images/${content.id}.webp',
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: fallback,
            )
          : Image.network(
              content.image,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: fallback,
            ),
    );
  }
}
