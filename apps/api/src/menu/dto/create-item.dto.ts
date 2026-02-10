import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsNumber,
  IsInt,
  IsBoolean,
  IsEnum,
  IsUUID,
} from 'class-validator';
import { Type } from 'class-transformer';

enum TaxType {
  TAXABLE = 'TAXABLE',
  ZERO = 'ZERO',
  EXEMPT = 'EXEMPT',
}

export class CreateItemDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsUUID()
  @IsOptional()
  categoryId?: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsString()
  @IsOptional()
  sku?: string;

  @IsString()
  @IsOptional()
  barcode?: string;

  @IsNumber()
  @Type(() => Number)
  price: number;

  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  costPrice?: number;

  @IsEnum(TaxType)
  @IsOptional()
  taxType?: TaxType;

  @IsString()
  @IsOptional()
  imageUrl?: string;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @IsInt()
  @IsOptional()
  sortOrder?: number;
}
