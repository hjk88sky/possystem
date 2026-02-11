import { IsOptional, IsEnum } from 'class-validator';

enum DeviceType {
  POS = 'POS',
  KIOSK = 'KIOSK',
  CUSTOMER_DISPLAY = 'CUSTOMER_DISPLAY',
  KDS = 'KDS',
}

enum DeviceStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  OFFLINE = 'OFFLINE',
}

export class GetDevicesQueryDto {
  @IsEnum(DeviceType)
  @IsOptional()
  type?: DeviceType;

  @IsEnum(DeviceStatus)
  @IsOptional()
  status?: DeviceStatus;
}
