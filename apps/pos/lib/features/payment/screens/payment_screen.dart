import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/payment_request.dart';
import '../providers/payment_provider.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/cash_input_pad.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final int orderId;
  final int totalAmount;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethod _method = PaymentMethod.card;
  int _cashAmount = 0;

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final theme = Theme.of(context);

    ref.listen<PaymentState>(paymentProvider, (prev, next) {
      if (next.status == PaymentStatus.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('결제'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Total amount
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text('결제 금액', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(widget.totalAmount),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Payment method selector
                Text('결제 수단', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                PaymentMethodSelector(
                  selected: _method,
                  onChanged: (method) => setState(() {
                    _method = method;
                    _cashAmount = 0;
                  }),
                ),
                const SizedBox(height: 24),

                // Cash input (only for cash)
                if (_method == PaymentMethod.cash) ...[
                  CashInputPad(
                    totalAmount: widget.totalAmount,
                    cashAmount: _cashAmount,
                    onAmountChanged: (v) => setState(() => _cashAmount = v),
                  ),
                  const SizedBox(height: 24),
                ],

                // Confirm button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _canPay(paymentState) ? _processPayment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: paymentState.status == PaymentStatus.loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_method == PaymentMethod.card
                            ? '카드 결제'
                            : '현금 결제'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _canPay(PaymentState state) {
    if (state.status == PaymentStatus.loading) return false;
    if (_method == PaymentMethod.cash && _cashAmount < widget.totalAmount) {
      return false;
    }
    return true;
  }

  Future<void> _processPayment() async {
    final methodStr = _method == PaymentMethod.card ? 'CARD' : 'CASH';
    final request = PaymentRequest(
      method: methodStr,
      amount: widget.totalAmount,
    );

    final payment = await ref
        .read(paymentProvider.notifier)
        .processPayment(widget.orderId, request);

    if (payment != null && mounted) {
      ref.read(paymentProvider.notifier).reset();
      context.go('/order-complete', extra: {
        'orderNumber': 'ORD-${widget.orderId}',
        'totalAmount': widget.totalAmount,
        'paymentMethod': methodStr,
        'changeAmount':
            _method == PaymentMethod.cash ? _cashAmount - widget.totalAmount : 0,
      });
    }
  }
}
