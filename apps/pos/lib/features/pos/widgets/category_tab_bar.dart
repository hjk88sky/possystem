import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/menu_provider.dart';

class CategoryTabBar extends ConsumerWidget {
  const CategoryTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedId = ref.watch(selectedCategoryProvider);

    return categoriesAsync.when(
      data: (categories) {
        return Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildChip(
                context: context,
                label: '전체',
                isSelected: selectedId == null,
                color: AppTheme.categoryColors[0],
                onTap: () =>
                    ref.read(selectedCategoryProvider.notifier).state = null,
              ),
              ...categories.asMap().entries.map((entry) {
                final i = entry.key;
                final cat = entry.value;
                return _buildChip(
                  context: context,
                  label: cat.name,
                  isSelected: selectedId == cat.id,
                  color: AppTheme.getCategoryColor(i + 1),
                  onTap: () =>
                      ref.read(selectedCategoryProvider.notifier).state =
                          cat.id,
                );
              }),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 52,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox(height: 52),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: color.withValues(alpha: 0.2),
        checkmarkColor: color,
        labelStyle: TextStyle(
          color: isSelected ? color : null,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected ? color : Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}
