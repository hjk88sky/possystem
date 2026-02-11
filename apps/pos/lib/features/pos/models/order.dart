import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'order_item.dart';

part 'order.freezed.dart';
part 'order.g.dart';

/// 주문 중요도
enum OrderPriority {
  @JsonValue('URGENT')
  urgent,
  @JsonValue('HIGH')
  high,
  @JsonValue('NORMAL')
  normal,
  @JsonValue('LOW')
  low,
}

/// OrderPriority 확장 - 한국어 레이블, 색상, API 값
extension OrderPriorityX on OrderPriority {
  String get label {
    switch (this) {
      case OrderPriority.urgent:
        return '긴급';
      case OrderPriority.high:
        return '높음';
      case OrderPriority.normal:
        return '보통';
      case OrderPriority.low:
        return '낮음';
    }
  }

  Color get color {
    switch (this) {
      case OrderPriority.urgent:
        return const Color(0xFFD32F2F);
      case OrderPriority.high:
        return const Color(0xFFF57C00);
      case OrderPriority.normal:
        return const Color(0xFF1565C0);
      case OrderPriority.low:
        return const Color(0xFF757575);
    }
  }

  String get apiValue {
    switch (this) {
      case OrderPriority.urgent:
        return 'URGENT';
      case OrderPriority.high:
        return 'HIGH';
      case OrderPriority.normal:
        return 'NORMAL';
      case OrderPriority.low:
        return 'LOW';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderPriority.urgent:
        return Icons.priority_high;
      case OrderPriority.high:
        return Icons.arrow_upward;
      case OrderPriority.normal:
        return Icons.remove;
      case OrderPriority.low:
        return Icons.arrow_downward;
    }
  }
}

@freezed
class Order with _$Order {
  const factory Order({
    required int id,
    @JsonKey(name: 'order_number') required String orderNumber,
    required String status,
    required String channel,
    @JsonKey(name: 'total_amount') required int totalAmount,
    @JsonKey(name: 'tax_amount') @Default(0) int taxAmount,
    @Default([]) List<OrderItem> items,
    @Default(OrderPriority.normal) OrderPriority priority,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
