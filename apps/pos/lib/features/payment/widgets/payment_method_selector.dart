import 'package:flutter/material.dart';

enum PaymentMethod { card, cash }

class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _MethodCard(
            icon: Icons.credit_card,
            label: '카드',
            isSelected: selected == PaymentMethod.card,
            onTap: () => onChanged(PaymentMethod.card),
            theme: theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _MethodCard(
            icon: Icons.money,
            label: '현금',
            isSelected: selected == PaymentMethod.cash,
            onTap: () => onChanged(PaymentMethod.cash),
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _MethodCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
