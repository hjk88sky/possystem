import { IsString, IsNotEmpty, IsOptional, IsUUID } from 'class-validator';

export class CreateStoreDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsNotEmpty()
  code: string;

  @IsUUID()
  @IsOptional()
  franchiseId?: string;

  @IsString()
  @IsOptional()
  address?: string;

  @IsString()
  @IsOptional()
  businessNumber?: string;

  @IsString()
  @IsOptional()
  timezone?: string;
}
