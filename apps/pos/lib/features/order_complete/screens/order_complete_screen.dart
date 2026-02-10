import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/receipt_preview.dart';

class OrderCompleteScreen extends StatelessWidget {
  final String orderNumber;
  final int totalAmount;
  final String paymentMethod;
  final int changeAmount;

  const OrderCompleteScreen({
    super.key,
    required this.orderNumber,
    required this.totalAmount,
    required this.paymentMethod,
    required this.changeAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '결제 완료!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 32),

              // Receipt
              ReceiptPreview(
                orderNumber: orderNumber,
                totalAmount: totalAmount,
                paymentMethod: paymentMethod,
                changeAmount: changeAmount,
              ),
              const SizedBox(height: 32),

              // New order button
              SizedBox(
                width: 240,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/pos'),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('새 주문'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
