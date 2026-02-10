import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/cart_item.dart';

class CartItemRow extends StatelessWidget {
  final CartItem item;
  final void Function(int quantity) onUpdateQuantity;
  final VoidCallback onRemove;

  const CartItemRow({
    super.key,
    required this.item,
    required this.onUpdateQuantity,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          // Item name & price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menuItem.name,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  CurrencyFormatter.format(item.menuItem.price),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Quantity controls
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 22),
            onPressed: () => onUpdateQuantity(item.quantity - 1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 22),
            onPressed: () => onUpdateQuantity(item.quantity + 1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          const SizedBox(width: 4),
          // Subtotal
          SizedBox(
            width: 72,
            child: Text(
              CurrencyFormatter.format(item.subtotal),
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Remove button
          IconButton(
            icon: Icon(Icons.close, size: 18, color: theme.colorScheme.error),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }
}
