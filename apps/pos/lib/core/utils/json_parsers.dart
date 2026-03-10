String parseStringId(Object? value) {
  if (value == null) {
    return '';
  }

  return value.toString();
}

String? parseNullableStringId(Object? value) {
  if (value == null) {
    return null;
  }

  final normalized = value.toString();
  return normalized.isEmpty ? null : normalized;
}

int parseMoneyToInt(Object? value) {
  if (value == null) {
    return 0;
  }

  if (value is num) {
    return value.round();
  }

  return num.tryParse(value.toString())?.round() ?? 0;
}

String? parseNullableString(Object? value) {
  if (value == null) {
    return null;
  }

  final normalized = value.toString();
  return normalized.isEmpty ? null : normalized;
}
