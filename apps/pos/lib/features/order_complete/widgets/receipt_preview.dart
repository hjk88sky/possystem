import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';

class ReceiptPreview extends StatelessWidget {
  final String orderNumber;
  final int totalAmount;
  final String paymentMethod;
  final int changeAmount;

  const ReceiptPreview({
    super.key,
    required this.orderNumber,
    required this.totalAmount,
    required this.paymentMethod,
    required this.changeAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final methodLabel = paymentMethod == 'CARD' ? '카드' : '현금';

    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text('영수증',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(orderNumber,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const Divider(height: 24),

          // Details
          _row(context, '결제 수단', methodLabel),
          const SizedBox(height: 8),
          _row(context, '결제 금액', CurrencyFormatter.format(totalAmount),
              isBold: true),

          if (paymentMethod == 'CASH') ...[
            const SizedBox(height: 8),
            _row(context, '받은 금액',
                CurrencyFormatter.format(totalAmount + changeAmount)),
            const SizedBox(height: 8),
            _row(context, '거스름돈', CurrencyFormatter.format(changeAmount)),
          ],

          const Divider(height: 24),
          Text(
            '감사합니다!',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value,
      {bool isBold = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
