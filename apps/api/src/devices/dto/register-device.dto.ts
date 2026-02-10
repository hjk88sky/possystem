import {
  IsString,
  IsNotEmpty,
  IsEnum,
  IsOptional,
} from 'class-validator';

enum DeviceType {
  POS = 'POS',
  KIOSK = 'KIOSK',
  CUSTOMER_DISPLAY = 'CUSTOMER_DISPLAY',
  KDS = 'KDS',
}

enum DeviceOs {
  WINDOWS = 'WINDOWS',
  ANDROID = 'ANDROID',
}

export class RegisterDeviceDto {
  @IsString()
  @IsNotEmpty()
  deviceCode: string;

  @IsEnum(DeviceType)
  type: DeviceType;

  @IsEnum(DeviceOs)
  os: DeviceOs;

  @IsString()
  @IsOptional()
  deviceName?: string;

  @IsString()
  @IsOptional()
  appVersion?: string;

  @IsString()
  @IsOptional()
  hardwareModel?: string;
}
