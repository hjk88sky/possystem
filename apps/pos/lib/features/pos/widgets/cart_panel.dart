import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/order.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import 'cart_item_row.dart';
import 'cart_summary.dart';
import 'priority_selector.dart';

class CartPanel extends ConsumerWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final orderState = ref.watch(orderProvider);
    final selectedPriority = ref.watch(cartPriorityProvider);
    final theme = Theme.of(context);

    ref.listen<OrderState>(orderProvider, (prev, next) {
      if (next.status == OrderStatus.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          left: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.shopping_cart,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('주문 목록', style: theme.textTheme.titleMedium),
                const Spacer(),
                if (cartItems.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      ref.read(cartProvider.notifier).clear();
                      ref.read(cartPriorityProvider.notifier).reset();
                    },
                    child: Text('전체 삭제',
                        style: TextStyle(color: theme.colorScheme.error)),
                  ),
              ],
            ),
          ),

          // Priority selector
          PrioritySelector(
            selected: selectedPriority,
            onChanged: (priority) {
              ref.read(cartPriorityProvider.notifier).setPriority(priority);
            },
          ),

          // Cart items list
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 48,
                            color: theme.colorScheme.outlineVariant),
                        const SizedBox(height: 8),
                        Text(
                          '메뉴를 선택해주세요',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemRow(
                        item: item,
                        onUpdateQuantity: (qty) => ref
                            .read(cartProvider.notifier)
                            .updateQuantity(item.menuItem.id, qty),
                        onRemove: () => ref
                            .read(cartProvider.notifier)
                            .removeItem(item.menuItem.id),
                      );
                    },
                  ),
          ),

          // Summary & Pay button
          if (cartItems.isNotEmpty) ...[
            const CartSummary(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: orderState.status == OrderStatus.loading
                      ? null
                      : () => _createOrder(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: orderState.status == OrderStatus.loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('결제하기'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _createOrder(BuildContext context, WidgetRef ref) async {
    final cartItems = ref.read(cartProvider);
    final total = ref.read(cartTotalProvider);
    final priority = ref.read(cartPriorityProvider);
    final order = await ref
        .read(orderProvider.notifier)
        .createOrder(cartItems, priority: priority);

    if (order != null && context.mounted) {
      ref.read(cartProvider.notifier).clear();
      ref.read(cartPriorityProvider.notifier).reset();
      context.push('/payment', extra: {
        'orderId': order.id,
        'totalAmount': total,
      });
    }
  }
}
