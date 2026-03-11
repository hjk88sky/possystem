class ApiConfig {
  static const String _defaultOrigin = 'http://localhost:3000';
  static const String _rawBaseOrigin = String.fromEnvironment(
    'POS_API_ORIGIN',
    defaultValue: _defaultOrigin,
  );

  static String get baseOrigin {
    if (_rawBaseOrigin.endsWith('/')) {
      return _rawBaseOrigin.substring(0, _rawBaseOrigin.length - 1);
    }
    return _rawBaseOrigin;
  }

  static String get baseUrl => '$baseOrigin/v1';
  static String get realtimeUrl => '$baseOrigin/realtime';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
