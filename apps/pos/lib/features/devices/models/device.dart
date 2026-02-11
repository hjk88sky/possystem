// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// 디바이스 타입
enum DeviceType {
  POS,
  KIOSK,
  CUSTOMER_DISPLAY,
  KDS,
}

extension DeviceTypeX on DeviceType {
  String get label {
    switch (this) {
      case DeviceType.POS:
        return 'POS';
      case DeviceType.KIOSK:
        return '키오스크';
      case DeviceType.CUSTOMER_DISPLAY:
        return '고객 디스플레이';
      case DeviceType.KDS:
        return 'KDS';
    }
  }

  IconData get icon {
    switch (this) {
      case DeviceType.POS:
        return Icons.point_of_sale;
      case DeviceType.KIOSK:
        return Icons.tablet_android;
      case DeviceType.CUSTOMER_DISPLAY:
        return Icons.monitor;
      case DeviceType.KDS:
        return Icons.kitchen;
    }
  }
}

/// 디바이스 OS
enum DeviceOs {
  WINDOWS,
  ANDROID,
}

extension DeviceOsX on DeviceOs {
  String get label {
    switch (this) {
      case DeviceOs.WINDOWS:
        return 'Windows';
      case DeviceOs.ANDROID:
        return 'Android';
    }
  }

  IconData get icon {
    switch (this) {
      case DeviceOs.WINDOWS:
        return Icons.desktop_windows;
      case DeviceOs.ANDROID:
        return Icons.phone_android;
    }
  }
}

/// 디바이스 상태
enum DeviceStatus {
  ACTIVE,
  INACTIVE,
  OFFLINE,
}

extension DeviceStatusX on DeviceStatus {
  String get label {
    switch (this) {
      case DeviceStatus.ACTIVE:
        return '활성';
      case DeviceStatus.INACTIVE:
        return '비활성';
      case DeviceStatus.OFFLINE:
        return '오프라인';
    }
  }

  Color get color {
    switch (this) {
      case DeviceStatus.ACTIVE:
        return const Color(0xFF2E7D32);
      case DeviceStatus.INACTIVE:
        return const Color(0xFF757575);
      case DeviceStatus.OFFLINE:
        return const Color(0xFFC62828);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case DeviceStatus.ACTIVE:
        return const Color(0xFFE8F5E9);
      case DeviceStatus.INACTIVE:
        return const Color(0xFFF5F5F5);
      case DeviceStatus.OFFLINE:
        return const Color(0xFFFFEBEE);
    }
  }

  IconData get icon {
    switch (this) {
      case DeviceStatus.ACTIVE:
        return Icons.check_circle;
      case DeviceStatus.INACTIVE:
        return Icons.pause_circle;
      case DeviceStatus.OFFLINE:
        return Icons.cancel;
    }
  }
}

/// 디바이스 모델
class Device {
  final String id;
  final String storeId;
  final DeviceType type;
  final DeviceOs os;
  final String deviceCode;
  final String? deviceName;
  final String? appVersion;
  final String? hardwareModel;
  final DateTime? lastSeenAt;
  final DeviceStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Device({
    required this.id,
    required this.storeId,
    required this.type,
    required this.os,
    required this.deviceCode,
    this.deviceName,
    this.appVersion,
    this.hardwareModel,
    this.lastSeenAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      storeId: json['store_id'] as String? ?? json['storeId'] as String,
      type: DeviceType.values.firstWhere(
        (e) => e.name == (json['type'] as String),
        orElse: () => DeviceType.POS,
      ),
      os: DeviceOs.values.firstWhere(
        (e) => e.name == (json['os'] as String),
        orElse: () => DeviceOs.WINDOWS,
      ),
      deviceCode:
          json['device_code'] as String? ?? json['deviceCode'] as String,
      deviceName:
          json['device_name'] as String? ?? json['deviceName'] as String?,
      appVersion:
          json['app_version'] as String? ?? json['appVersion'] as String?,
      hardwareModel: json['hardware_model'] as String? ??
          json['hardwareModel'] as String?,
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'] as String)
          : json['lastSeenAt'] != null
              ? DateTime.parse(json['lastSeenAt'] as String)
              : null,
      status: DeviceStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String),
        orElse: () => DeviceStatus.OFFLINE,
      ),
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? json['createdAt'] as String),
      updatedAt: DateTime.parse(
          json['updated_at'] as String? ?? json['updatedAt'] as String),
    );
  }

  Device copyWith({
    String? deviceName,
    DeviceStatus? status,
  }) {
    return Device(
      id: id,
      storeId: storeId,
      type: type,
      os: os,
      deviceCode: deviceCode,
      deviceName: deviceName ?? this.deviceName,
      appVersion: appVersion,
      hardwareModel: hardwareModel,
      lastSeenAt: lastSeenAt,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
