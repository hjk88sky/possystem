import { IsOptional, IsString, IsEnum, IsInt } from 'class-validator';

enum OrderStatus {
  OPEN = 'OPEN',
  PAID = 'PAID',
  CANCELLED = 'CANCELLED',
  VOID = 'VOID',
}

export class UpdateOrderDto {
  @IsEnum(OrderStatus)
  @IsOptional()
  status?: OrderStatus;

  @IsString()
  @IsOptional()
  note?: string;

  @IsInt()
  version: number;
}
