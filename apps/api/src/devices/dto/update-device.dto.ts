import { IsString, IsEnum, IsOptional, IsObject } from 'class-validator';

enum DeviceStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  OFFLINE = 'OFFLINE',
}

export class UpdateDeviceDto {
  @IsString()
  @IsOptional()
  deviceName?: string;

  @IsEnum(DeviceStatus)
  @IsOptional()
  status?: DeviceStatus;

  @IsString()
  @IsOptional()
  appVersion?: string;

  @IsString()
  @IsOptional()
  hardwareModel?: string;

  @IsObject()
  @IsOptional()
  configJson?: Record<string, any>;
}
