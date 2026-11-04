library;

import 'package:flutter/material.dart';

import '../../core/domain/models.dart';
import '../../core/utils/filters.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/task_card.dart' show categoryIcon;

/// Baris 4 kartu kategori — design-reference.html home baris 119–122:
/// kartu pastel rounded-2xl, ikon + label + jumlah tugas (warna ink kategori).
class CategoryRow extends StatelessWidget {
  const CategoryRow({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final category in Category.values) ...[
          if (category != Category.values.first) const SizedBox(width: 8),
          Expanded(
            child: _CategoryCard(
              category: category,
              count: tasks.where((t) => t.category == category).length,
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.count});

  final Category category;
  final int count;

  @override
  Widget build(BuildContext context) {
    final (bg, ink) = categoryColorPairs[category]!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(categoryIcon(category), size: 18, color: ink),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              categoryLabels[category]!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1.0,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              height: 1.0,
              fontWeight: FontWeight.w600,
              color: ink.withValues(alpha: .7),
            ),
          ),
        ],
      ),
    );
  }
}
