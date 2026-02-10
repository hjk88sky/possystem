import 'package:flutter/material.dart';

class PinPad extends StatelessWidget {
  final void Function(String digit) onDigit;
  final VoidCallback onDelete;
  final VoidCallback onClear;

  const PinPad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['C', '0', '⌫'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: row.map((label) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(
                    width: 72,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: label == 'C'
                            ? theme.colorScheme.errorContainer
                            : label == '⌫'
                                ? theme.colorScheme.surfaceContainerHighest
                                : theme.colorScheme.surfaceContainerLow,
                        foregroundColor: label == 'C'
                            ? theme.colorScheme.onErrorContainer
                            : theme.colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                      onPressed: () {
                        if (label == 'C') {
                          onClear();
                        } else if (label == '⌫') {
                          onDelete();
                        } else {
                          onDigit(label);
                        }
                      },
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
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
}
