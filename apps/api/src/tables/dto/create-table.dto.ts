import {
  IsString,
  IsNotEmpty,
  IsUUID,
  IsOptional,
  IsInt,
  IsNumber,
  IsEnum,
  IsBoolean,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';

enum TableShape {
  RECT = 'RECT',
  CIRCLE = 'CIRCLE',
}

export class CreateTableDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsUUID()
  @IsOptional()
  zoneId?: string;

  @IsInt()
  @Min(0)
  @IsOptional()
  @Type(() => Number)
  capacity?: number;

  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  posX?: number;

  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  posY?: number;

  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  width?: number;

  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  height?: number;

  @IsEnum(TableShape)
  @IsOptional()
  shape?: TableShape;
}
