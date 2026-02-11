import 'package:flutter/material.dart';
import '../models/order.dart';

/// 주문 목록에서 중요도를 시각적으로 표시하는 배지 위젯
///
/// - URGENT: 빨간 배경 + 아이콘
/// - HIGH: 주황 배경
/// - NORMAL: 파란 배경 (compact 모드에서는 표시하지 않을 수 있음)
/// - LOW: 회색 배경
class PriorityBadge extends StatelessWidget {
  final OrderPriority priority;

  /// true이면 아이콘만 표시하는 작은 배지
  final bool compact;

  /// NORMAL일 때 배지를 숨길지 여부
  final bool hideNormal;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.compact = false,
    this.hideNormal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (hideNormal && priority == OrderPriority.normal) {
      return const SizedBox.shrink();
    }

    final color = priority.color;

    if (compact) {
      return _CompactBadge(priority: priority, color: color);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            priority.icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactBadge extends StatelessWidget {
  final OrderPriority priority;
  final Color color;

  const _CompactBadge({
    required this.priority,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          priority.icon,
          size: 12,
          color: color,
        ),
      ),
    );
  }
}

/// 주문 카드에 사용할 수 있는 왼쪽 테두리 데코레이션
///
/// URGENT 주문의 경우 빨간색 왼쪽 테두리를 표시합니다.
class PriorityBorderDecoration extends StatelessWidget {
  final OrderPriority priority;
  final Widget child;

  const PriorityBorderDecoration({
    super.key,
    required this.priority,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUrgent = priority == OrderPriority.urgent;
    final isHigh = priority == OrderPriority.high;
    final showAccent = isUrgent || isHigh;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: showAccent
            ? Border.all(
                color: priority.color.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: showAccent
                ? priority.color.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              left: BorderSide(
                color: showAccent
                    ? priority.color
                    : theme.colorScheme.outlineVariant,
                width: showAccent ? 4 : 1,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
