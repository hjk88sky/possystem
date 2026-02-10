import { IsString, IsBoolean, IsOptional } from 'class-validator';

export class HeartbeatDto {
  @IsString()
  @IsOptional()
  appVersion?: string;

  @IsBoolean()
  @IsOptional()
  isOnline?: boolean;
}
