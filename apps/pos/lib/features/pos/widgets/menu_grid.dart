import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import 'menu_item_card.dart';

class MenuGrid extends ConsumerWidget {
  const MenuGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(filteredMenuItemsProvider);

    return itemsAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Text('메뉴가 없습니다.', style: TextStyle(fontSize: 16)),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 0.85,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return MenuItemCard(
              item: item,
              onTap: () => ref.read(cartProvider.notifier).addItem(item),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('메뉴를 불러올 수 없습니다.\n$err',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(menuItemsProvider),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
