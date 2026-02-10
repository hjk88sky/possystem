import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/cart_provider.dart';

class CartSummary extends ConsumerWidget {
  const CartSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = ref.watch(cartSubtotalProvider);
    final tax = ref.watch(cartTaxProvider);
    final total = ref.watch(cartTotalProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const Divider(),
          _row(context, '소계', CurrencyFormatter.format(subtotal)),
          const SizedBox(height: 4),
          _row(context, '부가세 (10%)', CurrencyFormatter.format(tax)),
          const Divider(height: 16),
          _row(
            context,
            '합계',
            CurrencyFormatter.format(total),
            isBold: true,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {bool isBold = false, Color? color}) {
    final style = isBold
        ? Theme.of(context).textTheme.titleLarge?.copyWith(color: color)
        : Theme.of(context).textTheme.bodyLarge;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
