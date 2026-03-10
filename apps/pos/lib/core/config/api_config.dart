class ApiConfig {
  static const String baseOrigin = 'http://localhost:3000';
  static const String baseUrl = '$baseOrigin/v1';
  static const String realtimeUrl = '$baseOrigin/realtime';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
