import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/device.dart';

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepository(ref.watch(dioProvider));
});

class DeviceRepository {
  final Dio _dio;

  DeviceRepository(this._dio);

  /// 디바이스 등록 (POST /v1/devices/register)
  Future<Device> register({
    required String deviceCode,
    required DeviceType type,
    required DeviceOs os,
    String? deviceName,
    String? appVersion,
    String? hardwareModel,
  }) async {
    final response = await _dio.post('/devices/register', data: {
      'deviceCode': deviceCode,
      'type': type.name,
      'os': os.name,
      if (deviceName != null) 'deviceName': deviceName,
      if (appVersion != null) 'appVersion': appVersion,
      if (hardwareModel != null) 'hardwareModel': hardwareModel,
    });
    final data = response.data['data'] ?? response.data;
    return Device.fromJson(data);
  }

  /// 디바이스 목록 조회 (GET /v1/devices)
  Future<List<Device>> getDevices({
    DeviceType? type,
    DeviceStatus? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (type != null) queryParams['type'] = type.name;
    if (status != null) queryParams['status'] = status.name;

    final response =
        await _dio.get('/devices', queryParameters: queryParams);
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data
          .map((e) => Device.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// 디바이스 수정 (PATCH /v1/devices/:id)
  Future<Device> updateDevice(
    String deviceId, {
    String? deviceName,
    DeviceStatus? status,
    String? appVersion,
    String? hardwareModel,
  }) async {
    final response = await _dio.patch('/devices/$deviceId', data: {
      if (deviceName != null) 'deviceName': deviceName,
      if (status != null) 'status': status.name,
      if (appVersion != null) 'appVersion': appVersion,
      if (hardwareModel != null) 'hardwareModel': hardwareModel,
    });
    final data = response.data['data'] ?? response.data;
    return Device.fromJson(data);
  }

  /// 하트비트 전송 (POST /v1/devices/:id/heartbeat)
  Future<void> heartbeat(
    String deviceId, {
    String? appVersion,
    bool isOnline = true,
  }) async {
    await _dio.post('/devices/$deviceId/heartbeat', data: {
      'isOnline': isOnline,
      if (appVersion != null) 'appVersion': appVersion,
    });
  }
}
