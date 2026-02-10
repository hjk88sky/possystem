import { IsString, IsOptional, IsEnum } from 'class-validator';

enum EntityStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
}

export class UpdateStoreDto {
  @IsString()
  @IsOptional()
  name?: string;

  @IsString()
  @IsOptional()
  address?: string;

  @IsString()
  @IsOptional()
  businessNumber?: string;

  @IsString()
  @IsOptional()
  vanProvider?: string;

  @IsString()
  @IsOptional()
  vanMerchantId?: string;

  @IsString()
  @IsOptional()
  timezone?: string;

  @IsEnum(EntityStatus)
  @IsOptional()
  status?: EntityStatus;
}
