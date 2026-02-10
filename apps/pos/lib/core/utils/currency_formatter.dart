import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat('#,###', 'ko_KR');

  /// 원화 포맷: 1000 → "₩1,000"
  static String format(num amount) {
    return '₩${_formatter.format(amount)}';
  }

  /// 숫자만 포맷: 1000 → "1,000"
  static String formatNumber(num amount) {
    return _formatter.format(amount);
  }
}
