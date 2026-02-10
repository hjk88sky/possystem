import { IsString, IsEnum, IsOptional } from 'class-validator';

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
}
