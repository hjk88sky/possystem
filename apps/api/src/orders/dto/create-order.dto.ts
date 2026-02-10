import {
  IsOptional,
  IsString,
  IsUUID,
  IsEnum,
  IsArray,
  ValidateNested,
  IsNumber,
  IsInt,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';

enum OrderChannel {
  POS = 'POS',
  KIOSK = 'KIOSK',
  QR = 'QR',
  DELIVERY = 'DELIVERY',
}

class CreateOrderOptionDto {
  @IsUUID()
  optionId: string;
}

class CreateOrderItemDto {
  @IsUUID()
  @IsOptional()
  itemId?: string;

  @IsUUID()
  @IsOptional()
  setId?: string;

  @IsInt()
  @Min(1)
  qty: number;

  @IsString()
  @IsOptional()
  note?: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateOrderOptionDto)
  @IsOptional()
  options?: CreateOrderOptionDto[];
}

export class CreateOrderDto {
  @IsUUID()
  @IsOptional()
  tableId?: string;

  @IsUUID()
  @IsOptional()
  customerId?: string;

  @IsEnum(OrderChannel)
  @IsOptional()
  channel?: OrderChannel;

  @IsString()
  @IsOptional()
  note?: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateOrderItemDto)
  items: CreateOrderItemDto[];
}
