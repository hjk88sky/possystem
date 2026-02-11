import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/order.dart';
import 'priority_badge.dart';

/// 주문 목록에서 개별 주문을 표시하는 카드 위젯
///
/// priority에 따라 왼쪽 테두리 색상과 배지가 달라집니다.
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: PriorityBorderDecoration(
        priority: order.priority,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: order number + priority badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.orderNumber,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      PriorityBadge(priority: order.priority),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Middle row: status + channel
                  Row(
                    children: [
                      _StatusChip(status: order.status),
                      const SizedBox(width: 8),
                      Text(
                        order.channel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        CurrencyFormatter.format(order.totalAmount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  // Bottom row: time
                  if (order.createdAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(order.createdAt!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateTimeStr;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _getStatusInfo(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  (String, Color) _getStatusInfo(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return ('대기', const Color(0xFFF57C00));
      case 'CONFIRMED':
        return ('확인', const Color(0xFF1565C0));
      case 'PREPARING':
        return ('준비중', const Color(0xFF6A1B9A));
      case 'COMPLETED':
        return ('완료', const Color(0xFF2E7D32));
      case 'CANCELLED':
        return ('취소', const Color(0xFFD32F2F));
      default:
        return (status, const Color(0xFF757575));
    }
  }
}
