import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/menu_item.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSoldOut = !item.available;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isSoldOut ? null : onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: item.imageUrl != null
                          ? Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.restaurant,
                                size: 48,
                                color: theme.colorScheme.outlineVariant,
                              ),
                            )
                          : Icon(
                              Icons.restaurant,
                              size: 48,
                              color: theme.colorScheme.outlineVariant,
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(item.price),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (isSoldOut)
              Positioned.fill(
                child: Container(
                  color: Colors.black45,
                  child: const Center(
                    child: Text(
                      '품절',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
