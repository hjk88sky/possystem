import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';

class CashInputPad extends StatelessWidget {
  final int totalAmount;
  final int cashAmount;
  final ValueChanged<int> onAmountChanged;

  const CashInputPad({
    super.key,
    required this.totalAmount,
    required this.cashAmount,
    required this.onAmountChanged,
  });

  int get change =>
      cashAmount >= totalAmount ? cashAmount - totalAmount : 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Amount display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text('받은 금액', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                CurrencyFormatter.format(cashAmount),
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              if (cashAmount >= totalAmount) ...[
                const SizedBox(height: 8),
                Text(
                  '거스름돈: ${CurrencyFormatter.format(change)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick amount buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _quickBtn(context, '정확히', totalAmount),
            _quickBtn(context, '+₩1,000', cashAmount + 1000),
            _quickBtn(context, '+₩5,000', cashAmount + 5000),
            _quickBtn(context, '+₩10,000', cashAmount + 10000),
            _quickBtn(context, '+₩50,000', cashAmount + 50000),
          ],
        ),
        const SizedBox(height: 16),

        // Number pad
        for (final row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['C', '0', '00'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((label) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(
                    width: 80,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: label == 'C'
                            ? theme.colorScheme.errorContainer
                            : theme.colorScheme.surfaceContainerLow,
                        foregroundColor: label == 'C'
                            ? theme.colorScheme.onErrorContainer
                            : theme.colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (label == 'C') {
                          onAmountChanged(0);
                        } else {
                          final str = cashAmount == 0
                              ? label
                              : '$cashAmount$label';
                          final value = int.tryParse(str) ?? 0;
                          onAmountChanged(value);
                        }
                      },
                      child: Text(
                        label,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _quickBtn(BuildContext context, String label, int value) {
    return OutlinedButton(
      onPressed: () => onAmountChanged(value),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(label),
    );
  }
}
