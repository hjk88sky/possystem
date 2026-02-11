import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/device_repository.dart';
import '../models/device.dart';

// ─────────────────────────────────────────────────
// 유니크 디바이스 코드 생성/저장 유틸
// ─────────────────────────────────────────────────

const _deviceCodeKey = 'device_code';

/// SharedPreferences에 저장된 device_code를 가져오거나, 없으면 생성
Future<String> _getOrCreateDeviceCode() async {
  final prefs = await SharedPreferences.getInstance();
  var code = prefs.getString(_deviceCodeKey);
  if (code == null || code.isEmpty) {
    // 간단한 UUID v4 생성 (외부 패키지 없이)
    code = _generateUuid();
    await prefs.setString(_deviceCodeKey, code);
  }
  return code;
}

/// UUID v4 생성 (dart:math Random 기반)
String _generateUuid() {
  final rng = Random();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));

  // RFC 4122 version 4: set version and variant bits
  bytes[6] = (bytes[6] & 0x0F) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3F) | 0x80; // variant 1

  String hex(int byte) => byte.toRadixString(16).padLeft(2, '0');

  return '${bytes.sublist(0, 4).map(hex).join()}'
      '-${bytes.sublist(4, 6).map(hex).join()}'
      '-${bytes.sublist(6, 8).map(hex).join()}'
      '-${bytes.sublist(8, 10).map(hex).join()}'
      '-${bytes.sublist(10, 16).map(hex).join()}';
}

/// 현재 OS 감지
DeviceOs _detectOs() {
  if (Platform.isWindows) return DeviceOs.WINDOWS;
  if (Platform.isAndroid) return DeviceOs.ANDROID;
  // 기본값
  return DeviceOs.WINDOWS;
}

// ─────────────────────────────────────────────────
// 디바이스 등록 + 하트비트 상태
// ─────────────────────────────────────────────────

class DeviceRegistrationState {
  final Device? currentDevice;
  final bool isRegistering;
  final String? error;

  const DeviceRegistrationState({
    this.currentDevice,
    this.isRegistering = false,
    this.error,
  });

  DeviceRegistrationState copyWith({
    Device? currentDevice,
    bool? isRegistering,
    String? error,
  }) {
    return DeviceRegistrationState(
      currentDevice: currentDevice ?? this.currentDevice,
      isRegistering: isRegistering ?? this.isRegistering,
      error: error,
    );
  }
}

class DeviceRegistrationNotifier
    extends StateNotifier<DeviceRegistrationState> {
  final DeviceRepository _repository;
  Timer? _heartbeatTimer;

  DeviceRegistrationNotifier(this._repository)
      : super(const DeviceRegistrationState());

  /// 디바이스 등록 (로그인 성공 후 호출)
  Future<void> registerDevice() async {
    if (state.isRegistering) return;
    state = state.copyWith(isRegistering: true, error: null);

    try {
      final deviceCode = await _getOrCreateDeviceCode();
      final os = _detectOs();

      final device = await _repository.register(
        deviceCode: deviceCode,
        type: DeviceType.POS,
        os: os,
        deviceName: 'POS-${deviceCode.substring(0, 8).toUpperCase()}',
        appVersion: '1.0.0',
      );

      state = DeviceRegistrationState(currentDevice: device);
      startHeartbeat();
    } catch (e) {
      state = state.copyWith(
        isRegistering: false,
        error: e.toString(),
      );
    }
  }

  /// 60초 간격 하트비트 시작
  void startHeartbeat() {
    stopHeartbeat();
    final deviceId = state.currentDevice?.id;
    if (deviceId == null) return;

    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _sendHeartbeat(deviceId),
    );
  }

  /// 하트비트 중지
  void stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _sendHeartbeat(String deviceId) async {
    try {
      await _repository.heartbeat(
        deviceId,
        appVersion: '1.0.0',
        isOnline: true,
      );
    } catch (_) {
      // 하트비트 실패는 무시 (네트워크 일시 오류 등)
    }
  }

  @override
  void dispose() {
    stopHeartbeat();
    super.dispose();
  }
}

/// 디바이스 등록/하트비트 프로바이더
final deviceRegistrationProvider = StateNotifierProvider<
    DeviceRegistrationNotifier, DeviceRegistrationState>((ref) {
  final repository = ref.watch(deviceRepositoryProvider);
  return DeviceRegistrationNotifier(repository);
});

// ─────────────────────────────────────────────────
// 디바이스 목록 상태
// ─────────────────────────────────────────────────

class DeviceListState {
  final List<Device> devices;
  final bool isLoading;
  final String? error;

  const DeviceListState({
    this.devices = const [],
    this.isLoading = false,
    this.error,
  });

  DeviceListState copyWith({
    List<Device>? devices,
    bool? isLoading,
    String? error,
  }) {
    return DeviceListState(
      devices: devices ?? this.devices,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DeviceListNotifier extends StateNotifier<DeviceListState> {
  final DeviceRepository _repository;

  DeviceListNotifier(this._repository) : super(const DeviceListState());

  /// 디바이스 목록 조회
  Future<void> fetchDevices() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final devices = await _repository.getDevices();
      state = DeviceListState(devices: devices);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 디바이스 수정
  Future<void> updateDevice(
    String deviceId, {
    String? deviceName,
    DeviceStatus? status,
  }) async {
    try {
      final updated = await _repository.updateDevice(
        deviceId,
        deviceName: deviceName,
        status: status,
      );
      state = state.copyWith(
        devices: state.devices
            .map((d) => d.id == deviceId ? updated : d)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// 디바이스 목록 프로바이더
final deviceListProvider =
    StateNotifierProvider<DeviceListNotifier, DeviceListState>((ref) {
  final repository = ref.watch(deviceRepositoryProvider);
  return DeviceListNotifier(repository);
});
